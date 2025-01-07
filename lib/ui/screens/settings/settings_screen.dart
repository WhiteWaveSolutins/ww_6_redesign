import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';

import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _configService = getItService.configService;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final version = AppInfo.of(context).package.version;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: _AnimatedHeaderText(
                  title: 'Settings',
                  subtitle: 'All your files in one place',
                ),
              ).animate().fadeIn(duration: 800.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildSettingsGroup(
                      title: 'Security',
                      items: [
                        _buildSettingsTile(
                          icon: CupertinoIcons.lock_shield_fill,
                          title: 'Password',
                          color: AppColors.info,
                          onTap: () =>
                              getItService.navigatorService.onInfoPassword(
                            onOpen:
                                getItService.navigatorService.onSettingPassword,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(
                      title: 'Legal',
                      items: [
                        _buildSettingsTile(
                          icon: CupertinoIcons.doc_text_fill,
                          title: 'Terms of Use',
                          color: AppColors.success,
                          onTap: () =>
                              launchUrlString(_configService.termsLink),
                        ),
                        _buildSettingsTile(
                          icon: CupertinoIcons.shield_fill,
                          title: 'Privacy Policy',
                          color: AppColors.secondary,
                          onTap: () =>
                              launchUrlString(_configService.privacyLink),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(
                      title: 'About',
                      items: [
                        _buildSettingsTile(
                          icon: CupertinoIcons.info_circle_fill,
                          title: 'Version',
                          color: AppColors.warning,
                          trailing: Text(
                            '${version.major}.${version.minor}.${version.patch}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        _buildSettingsTile(
                          icon: CupertinoIcons.question_circle_fill,
                          title: 'Support',
                          color: AppColors.primaryGrad1,
                          onTap: () => FlutterEmailSender.send(Email(
                            recipients: ['support@example.com'],
                            subject: 'Support Request',
                            body: 'Hello, I need help with...',
                          )),
                        ),
                        _buildSettingsTile(
                          icon: CupertinoIcons.star_fill,
                          title: 'Rate us',
                          color: AppColors.accentGrad1,
                          onTap: () => InAppReview.instance.requestReview(),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildAnimatedHeader()
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scale(
              duration: 2.seconds,
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              curve: Curves.easeInOut,
            ),
        const Icon(
          CupertinoIcons.settings,
          color: AppColors.surfaceLight,
          size: 40,
        )
            .animate(
              onPlay: (controller) => controller.repeat(period: 3.seconds),
            )
            .rotate(
              duration: 3.seconds,
              begin: 0,
              end: 2,
              curve: Curves.easeInOutCubic,
            ),
      ],
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGrad1.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    items[i],
                    if (i != items.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 68),
                        child: Divider(
                          height: 1,
                          color: AppColors.textMuted.withOpacity(0.1),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.surfaceLight.withOpacity(0.5),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedHeaderText extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AnimatedHeaderText({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 40,
            height: 1.2,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }
}
