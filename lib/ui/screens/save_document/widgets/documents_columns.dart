import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:gaimon/gaimon.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';

class DocumentsColumns extends StatefulWidget {
  final List<String> images;
  final Function() onAdd;
  final Function(int) onDelete;
  final Function(int) onReplace;
  final Function() onRename;
  final Function() onUpdateState;
  final String nameDoc;
  final bool isEdit;

  const DocumentsColumns({
    super.key,
    required this.images,
    required this.onRename,
    required this.onUpdateState,
    required this.onAdd,
    required this.onDelete,
    required this.onReplace,
    required this.nameDoc,
    this.isEdit = true,
  });

  @override
  State<DocumentsColumns> createState() => _DocumentsColumnsState();
}

class _DocumentsColumnsState extends State<DocumentsColumns> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider(
            items: [
              for (var image in widget.images)
                _buildImageItem(image),
              if (widget.isEdit)
                _buildAddButton(),
            ],
            options: CarouselOptions(
              height: double.infinity,
              initialPage: 0,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              onPageChanged: (index, _) {
                Gaimon.selection();
                setState(() => selectedIndex = index);
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildDocumentInfo(),
        const SizedBox(height: 20),
        if (widget.isEdit)
          Opacity(
            opacity: selectedIndex == widget.images.length ? 0 : 1,
            child: _Buttons(
              onDelete: () => widget.onDelete(selectedIndex),
              onReplace: () => widget.onReplace(selectedIndex),
              onEdit: () async {
                final image = await getItService.navigatorService.onCostomizeDocument(
                  image: widget.images[selectedIndex],
                );
                widget.onUpdateState();
                setState(() {});
              },
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildImageItem(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 370,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.surfaceDark.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              File(image).readAsBytesSync(),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildAddButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: widget.onAdd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 370,
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
                padding: const EdgeInsets.all(30),
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

  Widget _buildDocumentInfo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.doc_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.nameDoc,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Opacity(
                opacity: widget.isEdit ? 1 : 0,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.isEdit ? widget.onRename : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.pencil,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }
}

class _Buttons extends StatelessWidget {
  final Function() onDelete;
  final Function() onReplace;
  final Function() onEdit;

  const _Buttons({
    required this.onDelete,
    required this.onReplace,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          onPressed: onReplace,
          icon: CupertinoIcons.arrow_2_circlepath,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          onPressed: onEdit,
          icon: CupertinoIcons.pencil,
          color: AppColors.info,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          onPressed: onDelete,
          icon: CupertinoIcons.delete,
          color: AppColors.error,
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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
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
}
