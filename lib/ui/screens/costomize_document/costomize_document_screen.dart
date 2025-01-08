import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:scan_doc/ui/resurses/colors.dart';

import 'package:scan_doc/ui/resurses/images.dart';

import 'package:scan_doc/ui/screens/costomize_document/widgets/costomize_widget.dart';
import 'package:scan_doc/ui/screens/costomize_document/widgets/crop_editor.dart';
import 'package:scan_doc/ui/screens/costomize_document/widgets/filter_editor.dart';
import 'package:scan_doc/ui/screens/costomize_document/widgets/sticker_editor.dart';

class CustomizeDocumentScreen extends StatelessWidget {
  final String image;

  const CustomizeDocumentScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: _AnimatedHeaderText(
                  title: 'Edit Document',
                  subtitle: 'Customize your document appearance',
                ),
              ).animate().fadeIn(duration: 800.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildEditingGroup(
                    title: 'Tools',
                    child: ProImageEditor.file(
                      File(image),
                      callbacks: ProImageEditorCallbacks(
                        onImageEditingComplete: (bytes) async {
                          final file = File(image);
                          await file.writeAsBytes(bytes);
                          Navigator.of(context).pop(file.path);
                        },
                      ),
                      bottomNavigationBarHeight: 90,
                      bottomNavigationBarButtonsHeight: 90,
                      appBarWidget: (onClose, onFinish) => PreferredSize(
                        preferredSize: const Size.fromHeight(44),
                        child: _buildToolbar(
                          context,
                          onClose: onClose,
                          onFinish: onFinish,
                        ),
                      ),
                      appBarWidgetCrop: const CustomizeWidget(
                        title: 'Cut',
                        icon: CupertinoIcons.scissors,
                      ),
                      configs: ProImageEditorConfigs(
                        tuneEditorConfigs:
                            const TuneEditorConfigs(enabled: false),
                        blurEditorConfigs:
                            const BlurEditorConfigs(enabled: false),
                        emojiEditorConfigs:
                            const EmojiEditorConfigs(enabled: false),
                        stickerEditorConfigs: StickerEditorConfigs(
                          enabled: true,
                          buildStickers: (setLayer) =>
                              StickerEditorWidget(setLayer: setLayer),
                        ),
                        filterEditorConfigs: const FilterEditorConfigs(),
                        icons: ImageEditorIcons(
                          cropRotateEditor: IconsCropRotateEditor(
                            bottomNavBar: _buildToolButton(CupertinoIcons.crop),
                          ),
                          textEditor: IconsTextEditor(
                            bottomNavBar:
                                _buildToolButton(CupertinoIcons.text_cursor),
                          ),
                        ),
                        customWidgets: ImageEditorCustomWidgets(
                          cropRotateEditor: cropEditor,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditingGroup({
    required String title,
    required Widget child,
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
        Expanded(
          child: ClipRRect(
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
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(
    BuildContext context, {
    required VoidCallback onClose,
    required VoidCallback onFinish,
  }) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.surfaceDark.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToolButton(CupertinoIcons.xmark, onPressed: onClose),
              _buildToolButton(
                CupertinoIcons.checkmark,
                onPressed: onFinish,
                isActive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
    IconData icon, {
    VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return CustomizeButton(
      icon: icon,
      onPressed: onPressed,
      isActive: isActive,
    );
  }
}

class CustomizeButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onPressed;

  const CustomizeButton({
    super.key,
    required this.icon,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.surfaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.textPrimary.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonsHistoryCustomize extends StatelessWidget {
  final Function() onPrev;
  final Function() onNext;
  final bool activePrev;
  final bool activeNext;

  const ButtonsHistoryCustomize({
    super.key,
    required this.onNext,
    required this.onPrev,
    required this.activeNext,
    required this.activePrev,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomizeButton(
          icon: CupertinoIcons.arrow_counterclockwise,
          onPressed: activePrev ? onPrev : null,
          isActive: activePrev,
        ),
        const SizedBox(width: 16),
        CustomizeButton(
          icon: CupertinoIcons.arrow_clockwise,
          onPressed: activeNext ? onNext : null,
          isActive: activeNext,
        ),
      ],
    );
  }
}

class AppBarCustomize extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onFinish;

  const AppBarCustomize({
    super.key,
    required this.onClose,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.surfaceDark.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomizeButton(
                  icon: CupertinoIcons.xmark,
                  onPressed: onClose,
                ),
                const Text(
                  'Edit Document',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomizeButton(
                  icon: CupertinoIcons.checkmark,
                  onPressed: onFinish,
                  isActive: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final bool isPrimary;

  const FilterActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomizeButton(
      icon: icon,
      onPressed: onPressed,
      isActive: isPrimary,
    );
  }
}

class ButtonCloseFilter extends StatelessWidget {
  final VoidCallback onTap;

  const ButtonCloseFilter({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomizeButton(
      icon: CupertinoIcons.xmark,
      onPressed: onTap,
    );
  }
}

class ButtonCheckFilter extends StatelessWidget {
  final VoidCallback onTap;

  const ButtonCheckFilter({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomizeButton(
      icon: CupertinoIcons.check_mark,
      onPressed: onTap,
      isActive: true,
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
