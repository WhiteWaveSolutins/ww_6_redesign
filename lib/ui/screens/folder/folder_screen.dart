import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scan_doc/data/models/folder.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/screens/main/widgets/documents_list.dart';
import 'package:scan_doc/ui/widgets/modal/add_folder_modal.dart';

class FolderScreen extends StatefulWidget {
  final Folder folder;

  const FolderScreen({
    super.key,
    required this.folder,
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen>
    with SingleTickerProviderStateMixin {
  late Folder folder;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    folder = widget.folder;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showDeleteDialog() {
    showCupertinoDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CupertinoAlertDialog(
          title: const Text(
            'Do you really want to delete this folder?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Her files will also be deleted',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: Navigator.of(context).pop,
              isDefaultAction: true,
              child: const Text(
                "No",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                getItService.folderUseCase.deleteFolder(folderId: folder.id);
                Navigator.of(context).pop();
              },
              isDestructiveAction: true,
              child: const Text(
                "Yes",
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddFolderModal(
        folder: folder,
        setFolder: (n) => setState(() => folder = n),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: Stack(
        children: [
          // Background Animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_scaleAnimation.value * 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.surfaceDark.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildHeader()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.2, end: 0),
                  ),
                ),

                // Folder Icon and Name
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: _buildFolderInfo()
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.easeOutBack,
                        ),
                  ),
                ),

                // Documents List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.textPrimary.withOpacity(0.1),
                            ),
                          ),
                          child: DocumentsList(folder: folder)
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(10),
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

        // Action Buttons
        Row(
          children: [
            _buildActionButton(
              onPressed: _showEditModal,
              icon: CupertinoIcons.pencil,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              onPressed: _showDeleteDialog,
              icon: CupertinoIcons.delete,
              color: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFolderInfo() {
    return Column(
      children: [
        // Folder Icon
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.surfaceDark.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/folders/folder${folder.imageIndex}.png',
            width: 60,
            height: 60,
          ),
        ),
        const SizedBox(height: 20),

        // Folder Name
        Text(
          folder.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
