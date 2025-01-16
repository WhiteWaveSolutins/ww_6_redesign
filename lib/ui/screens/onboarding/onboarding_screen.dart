import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gaimon/gaimon.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/state_manager/store.dart';
import 'package:scan_doc/ui/state_manager/subscription/action.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      emoji: '📑',
      title: 'PDF SCANNER',
      subtitle: 'Scan your documents and convert them to a PDF',
      color: AppColors.primary,
      animation: _buildFloatingAnimation,
    ),
    const OnboardingPage(
      emoji: '🙏',
      title: 'We value\nyour feedback',
      subtitle: "That's what helps us improve our work",
      color: AppColors.primary,
      animation: _buildPulseAnimation,
    ),
    const OnboardingPage(
      emoji: '✏️',
      title: 'Editing\ndocuments',
      subtitle: 'Change filters, add text and captions and more',
      color: AppColors.primary,
      animation: _buildRotateAnimation,
    ),
    const OnboardingPage(
      emoji: '🚀',
      title: 'Unlimited\naccess',
      subtitle: 'Try 3 days free, Then \$4.99/week',
      color: AppColors.primary,
      finish: true,
      animation: _buildFloatingAnimation,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  static Widget _buildFloatingAnimation(Animation<double> animation, Widget child) {
    return Transform.translate(
      offset: Offset(0, 20 * animation.value),
      child: child,
    );
  }

  static Widget _buildPulseAnimation(Animation<double> animation, Widget child) {
    return Transform.scale(
      scale: 0.8 + (0.4 * animation.value),
      child: Opacity(
        opacity: 0.6 + (0.4 * animation.value),
        child: child,
      ),
    );
  }

  static Widget _buildRotateAnimation(Animation<double> animation, Widget child) {
    return Transform.rotate(
      angle: 0.1 * animation.value,
      child: Transform.scale(
        scale: 0.9 + (0.2 * animation.value),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _OnboardingPageView(
              page: _pages[index],
              animation: _animController,
              isActive: _currentPage == index,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PageIndicator(
                        count: _pages.length,
                        currentPage: _currentPage,
                        activeColor: _pages[_currentPage].color,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            );
                          } else {
                            final store = StoreProvider.of<AppState>(context, listen: false);
                            final productId = store.state.paywallListState.paywalls.first.productId;
                            store.dispatch(
                              PurchaseSubscriptionAction(
                                onFinish: getItService.navigatorService.onMain,
                                onError: (e) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => CupertinoAlertDialog(
                                      title: const Text("Some Error"),
                                      content: Text(e),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed: Navigator.of(context).pop,
                                          isDefaultAction: true,
                                          child: const Text(
                                            "Ok",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onLoad: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const Center(
                                      child: CupertinoActivityIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                                productId: productId,
                              ),
                            );
                          }
                        },
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].color,
                            _pages[_currentPage].color.withOpacity(0.8),
                          ],
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Try free & subscribe' : 'Continue',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButtonOnbg(
                            text: 'Terms of Use',
                            onTap: () => launchUrl(
                              Uri.parse(getItService.configService.termsLink),
                              mode: LaunchMode.inAppWebView,
                            ),
                          ),
                          TextButtonOnbg(
                            text: 'Privacy Policy',
                            onTap: () => launchUrl(
                              Uri.parse(getItService.configService.privacyLink),
                              mode: LaunchMode.inAppWebView,
                            ),
                          ),
                          TextButtonOnbg(
                            text: 'Restore',
                            onTap: () {
                              final store = StoreProvider.of<AppState>(context, listen: false);
                              store.dispatch(RestoreSubscriptionAction(
                                onFinish: Navigator.of(context).pop,
                                onError: (e) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => CupertinoAlertDialog(
                                      title: const Text("Some Error"),
                                      content: Text(e),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed: Navigator.of(context).pop,
                                          isDefaultAction: true,
                                          child: const Text(
                                            "Ok",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onLoad: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const Center(
                                      child: CupertinoActivityIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String emoji;
  final String title;
  final bool finish;
  final String subtitle;
  final Color color;
  final Widget Function(Animation<double>, Widget) animation;

  const OnboardingPage({
    required this.emoji,
    required this.title,
    this.finish = false,
    required this.subtitle,
    required this.color,
    required this.animation,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;
  final Animation<double> animation;
  final bool isActive;

  const _OnboardingPageView({
    required this.page,
    required this.animation,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.8),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AnimatedEmoji(
                  emoji: page.emoji,
                  color: page.color,
                  animation: animation,
                  animationBuilder: page.animation,
                ),
                const SizedBox(height: 48),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildSubtitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      page.title,
      style: const TextStyle(
        fontSize: 40,
        height: 1.2,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          page.subtitle,
          style: const TextStyle(fontSize: 17, height: 1.4, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (page.finish) ...[
          GestureDetector(
            onTap: getItService.navigatorService.onMain,
            child: const Text(
              'Or proceed with limited version',
              style: TextStyle(
                fontSize: 17,
                height: 1.4,
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimatedEmoji extends StatelessWidget {
  final String emoji;
  final Color color;
  final Animation<double> animation;
  final Widget Function(Animation<double>, Widget) animationBuilder;

  const _AnimatedEmoji({
    required this.emoji,
    required this.color,
    required this.animation,
    required this.animationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => animationBuilder(
        animation,
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 80),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentPage;
  final Color activeColor;

  const _PageIndicator({
    required this.count,
    required this.currentPage,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 0.0,
            end: currentPage == index ? 1.0 : 0.0,
          ),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, _) {
            return Container(
              width: 8.0 + (20.0 * value),
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Color.lerp(
                  CupertinoColors.systemGrey,
                  activeColor,
                  value,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Gradient gradient;
  final Widget child;

  const GradientButton({super.key,
    required this.onPressed,
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Gaimon.selection();
        onPressed();
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class TextButtonOnbg extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const TextButtonOnbg({super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Gaimon.selection();
        onTap();
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
