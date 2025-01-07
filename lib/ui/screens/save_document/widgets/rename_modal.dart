import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gaimon/gaimon.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/widgets/toast/app_toast.dart';

class RenameModal extends StatefulWidget {
  final String name;
  final Function(String) onRename;

  const RenameModal({
    super.key,
    required this.name,
    required this.onRename,
  });

  @override
  State<RenameModal> createState() => _RenameModalState();
}

class _RenameModalState extends State<RenameModal> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.name;
  }

  void onRename() {
    Gaimon.selection();
    if (controller.text.isEmpty) {
      showAppToast('Enter name document');
      return;
    }
    widget.onRename(controller.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.black.withOpacity(0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: AppColors.textPrimary.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDark.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.textPrimary.withOpacity(0.1),
                                ),
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                          const Text(
                            'Rename Document',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: onRename,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Text Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.textPrimary.withOpacity(0.1),
                              ),
                            ),
                            child: CupertinoTextField(
                              controller: controller,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                              ),
                              placeholder: 'Document name',
                              placeholderStyle: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.5),
                                fontSize: 17,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: null,
                              onSubmitted: (_) => onRename(),
                              autofocus: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}
