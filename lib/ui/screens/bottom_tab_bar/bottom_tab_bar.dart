import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gaimon/gaimon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/resurses/icons.dart';
import 'package:scan_doc/ui/screens/main/main_screen.dart';
import 'package:scan_doc/ui/screens/settings/settings_screen.dart';
import 'package:scan_doc/ui/widgets/svg_icon.dart';
import 'package:flutter_open_app_settings/flutter_open_app_settings.dart';

class BottomTabBar extends StatefulWidget {
  const BottomTabBar({super.key});

  @override
  State<BottomTabBar> createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  int _currentIndex = 0;

  void goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IndexedStack(
          index: _currentIndex,
          children: [
            const MainScreen(),
            Container(),
            const SettingsScreen(),
          ],
        ),
        _GlassBottomBar(
          currentIndex: _currentIndex,
          onTap: goToTab,
        ),
      ],
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _GlassBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 30),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TabItem(
              icon: AppIcons.file,
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            const SizedBox(width: 8),
            const _Scanner(),
            const SizedBox(width: 8),
            _TabItem(
              icon: AppIcons.settings,
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.isSelected,
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? null : Colors.transparent,
        ),
        child: SvgIcon(
          icon: icon,
          size: 24,
          color: isSelected ? Colors.white : AppColors.textMuted,
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: 200.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Gaimon.selection();
        onTap();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: SvgIcon(
            icon: AppIcons.scan,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          duration: 2.seconds,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          curve: Curves.easeInOut,
        );
  }
}

class _Scanner extends StatefulWidget {
  const _Scanner({super.key});

  @override
  State<_Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<_Scanner> {
  Future<bool> _getPermission() async {
    try {
      var status = await Permission.camera.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        final newStatus = await Permission.camera.request();
        if (newStatus.isDenied || status.isPermanentlyDenied) return false;
      }

      if (Platform.isIOS) {
        var statusPhotos = await Permission.photos.request();
        if (statusPhotos.isDenied || status.isPermanentlyDenied) {
          final newStatusPhotos = await Permission.photos.request();
          if (newStatusPhotos.isDenied || status.isPermanentlyDenied) {
            return false;
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void _scanner() async {
    final status = await _getPermission();
    if (!status && Platform.isIOS) {
      FlutterOpenAppSettings.openAppsSettings(
        settingsCode: SettingsCode.APP_SETTINGS,
        onCompletion: () {},
      );
      return;
    }

    Gaimon.selection();
    final image = await CunningDocumentScanner.getPictures(
      noOfPages: 1,
      isGalleryImportAllowed: true,
    );
    if ((image ?? []).isNotEmpty) {
      getItService.navigatorService.onSaveDocument(image: image!.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _scanner,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(10),
        child: const SvgIcon(
          icon: AppIcons.scan,
          size: 50,
        ),
      ),
    );
  }
}
