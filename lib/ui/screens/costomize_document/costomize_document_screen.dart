import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
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
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
      ),
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        backgroundColor: AppColors.backgroundDark,
        child: ProImageEditor.file(
          File(image),
          imageBack: AppImages.mainBack,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {
              final file = File(image);
              await file.writeAsBytes(bytes);
              Navigator.of(context).pop(file.path);
            },
          ),
          buttonsHistory: (onPrev, onNext, activePrev, activeNext) =>
              ButtonsHistoryCustomize(
                onNext: onNext,
                onPrev: onPrev,
                activeNext: activeNext,
                activePrev: activePrev,
              ),
          bottomNavigationBarHeight: 125,
          bottomNavigationBarButtonsHeight: 90,
          appBarWidget: (onClose, onFinish) => PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: AppBarCustomize(
              onClose: onClose,
              onFinish: onFinish,
            ),
          ),
          appBarWidgetCrop: const CustomizeWidget(
            title: 'Cut',
            icon: CupertinoIcons.scissors,
          ),
          bottomTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          configs: ProImageEditorConfigs(
            tuneEditorConfigs: const TuneEditorConfigs(enabled: false),
            blurEditorConfigs: const BlurEditorConfigs(enabled: false),
            emojiEditorConfigs: const EmojiEditorConfigs(enabled: false),
            stickerEditorConfigs: StickerEditorConfigs(
              enabled: true,
              buildStickers: (Function(Widget) setLayer) => StickerEditorWidget(
                setLayer: setLayer,
              ),
            ),
            filterEditorConfigs: const FilterEditorConfigs(),
            icons: ImageEditorIcons(
              stickerEditor: IconsStickerEditor(
                bottomNavBar: _buildEditorButton(
                  icon: CupertinoIcons.smiley,
                ),
              ),
              cropRotateEditor: IconsCropRotateEditor(
                bottomNavBar: _buildEditorButton(
                  icon: CupertinoIcons.crop,
                ),
              ),
              filterEditor: IconsFilterEditor(
                bottomNavBar: _buildEditorButton(
                  icon: CupertinoIcons.wand_rays,
                ),
              ),
              textEditor: IconsTextEditor(
                bottomNavBar: _buildEditorButton(
                  icon: CupertinoIcons.text_cursor,
                ),
              ),
              paintingEditor: IconsPaintingEditor(
                bottomNavBar: _buildEditorButton(
                  icon: CupertinoIcons.paintbrush_fill,
                ),
              ),
            ),
            customWidgets: ImageEditorCustomWidgets(
              filterEditor: appFilerEditor,
              cropRotateEditor: cropEditor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorButton({
    required IconData icon,
  }) {
    return CustomizeButton(icon: icon);
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
              color: isActive ? AppColors.primary : AppColors.surfaceDark.withOpacity(0.5),
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