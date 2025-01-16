import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:scan_doc/ui/resurses/colors.dart';

class DocumentsGrid extends StatelessWidget {
  final List<String> images;
  final Function() onAdd;
  final ScrollController scrollController;
  final Function(List<String>) reorder;
  final bool isDelete;
  final List<String> deleting;
  final Function() onSwitchDelete;
  final Function(String) onSelectDelete;

  const DocumentsGrid({
    super.key,
    required this.images,
    required this.deleting,
    required this.scrollController,
    required this.onAdd,
    required this.reorder,
    required this.isDelete,
    required this.onSwitchDelete,
    required this.onSelectDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ReorderableBuilder(
          lockedIndices: const [3],
          nonDraggableIndices: isDelete ? List.generate(images.length, (v) => v) : [],
          scrollController: scrollController,
          onReorder: (ReorderedListFunction reorderedListFunction) {
            final newImages = reorderedListFunction(images) as List<String>;
            reorder(newImages);
          },
          builder: (children) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView(
                controller: scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 230,
                ),
                children: children,
              ),
            );
          },
          children: [
            // Изображения с уникальными ключами
            ...images.asMap().entries.map((entry) {
              final index = entry.key;
              final imagePath = entry.value;
              return CustomDraggable(
                key: ValueKey('image_$index'),
                data: index,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (isDelete) onSelectDelete(imagePath);
                  },
                  child: _GridItem(
                    data: imagePath,
                    isDeleting: deleting.contains(imagePath),
                    index: index + 1,
                  ),
                ),
              );
            }),
            // Кнопка добавления с уникальным ключом
            CustomDraggable(
              key: const ValueKey('add_button'),
              data: images.length,
              child: _buildAddGridItem(),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onSwitchDelete,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDelete ? AppColors.error : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDelete 
                    ? AppColors.error.withOpacity(0.3)
                    : AppColors.textPrimary.withOpacity(0.1),
                ),
              ),
              child: Icon(
                isDelete ? CupertinoIcons.delete : CupertinoIcons.checkmark_circle,
                color: isDelete ? AppColors.textPrimary : AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddGridItem() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onAdd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(25),
                child: const Icon(
                  CupertinoIcons.plus,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      curve: Curves.easeOutBack,
    );
  }
}

class _GridItem extends StatelessWidget {
  final String data;
  final int index;
  final bool isDeleting;

  const _GridItem({
    required this.data,
    required this.index,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDeleting 
                    ? AppColors.error
                    : AppColors.textPrimary.withOpacity(0.1),
                  width: isDeleting ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.surfaceDark.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      File(data).readAsBytesSync(),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isDeleting)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.surfaceDark.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            index.toString(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2, end: 0),
      ],
    ).animate().fadeIn(delay: (index * 100).ms).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      curve: Curves.easeOutBack,
    );
  }
}
