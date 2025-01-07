import 'package:flutter/cupertino.dart';

import 'package:local_auth/local_auth.dart';
import 'package:scan_doc/data/services/shared_preferences_service.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/resurses/icons.dart';
import 'package:scan_doc/ui/screens/password/widgets/pin_code.dart';
import 'package:scan_doc/ui/widgets/svg_icon.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import 'package:flutter_animate/flutter_animate.dart';

class PasswordScreen extends StatefulWidget {
  final Function() onOpen;
  final String? password;
  final String? title;

  const PasswordScreen({
    super.key,
    required this.onOpen,
    this.password,
    this.title,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool faceIdHave = false;

  @override
  void initState() {
    super.initState();
    if (widget.title != null) load();
  }

  void load() async {
    final auth = LocalAuthentication();
    final availableBiometrics = await auth.getAvailableBiometrics();
    if (availableBiometrics.contains(BiometricType.face)) {
      final status = await SharedPreferencesService.getFaceId();
      faceIdHave = status;
      if (mounted) setState(() {});
      authorization();
    }
  }

  void authorization() async {
    final auth = LocalAuthentication();
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Oops! Biometric authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
      );
      if (didAuthenticate) widget.onOpen();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 60),
                  _buildIcon().animate().fadeIn(delay: 200.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 40),
                  Text(
                    widget.title ??
                        (widget.password == null
                            ? 'Keep the passcode'
                            : 'Repeat the passcode'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                  PinCode(
                    onSubmit: widget.onOpen,
                    password: widget.password,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  if (widget.title != null && faceIdHave) ...[
                    const SizedBox(height: 40),
                    _buildFaceIdButton().animate().fadeIn(delay: 800.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGrad1.withOpacity(0.1),
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'Password Protection',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info,
            AppColors.info.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        CupertinoIcons.lock_shield_fill,
        color: AppColors.textPrimary,
        size: 40,
      ),
    );
  }

  Widget _buildFaceIdButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: authorization,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success,
              AppColors.success.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const SvgIcon(
          icon: AppIcons.faceId,
          size: 30,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
