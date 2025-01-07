import 'dart:ui';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gaimon/gaimon.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';

import 'package:scan_doc/ui/resurses/utils.dart';
import 'package:scan_doc/ui/screens/save_document/widgets/documents_columns.dart';
import 'package:scan_doc/ui/screens/save_document/widgets/documents_grid.dart';
import 'package:scan_doc/ui/screens/save_document/widgets/rename_modal.dart';
import 'package:scan_doc/ui/state_manager/store.dart';

class SaveDocumentScreen extends StatefulWidget {
  final String image;

  const SaveDocumentScreen({
    super.key,
    required this.image,
  });

  @override
  State<SaveDocumentScreen> createState() => _SaveDocumentScreenState();
}

class _SaveDocumentScreenState extends State<SaveDocumentScreen> {
  bool isColumn = true;
  bool isDeleting = false;
  bool isLoading = false;
  late String name;

  List<String> docs = [];
  List<String> deleting = [];

  @override
  void initState() {
    super.initState();
    docs.add(widget.image);
    final store = StoreProvider.of<AppState>(context, listen: false);
    final len = store.state.documentListState.documents.length + 1;
    name = '${convertDate(date: DateTime.now())}. Document $len';
  }

  Future<String?> onScan() async {
    final image = await CunningDocumentScanner.getPictures(
      noOfPages: 1,
      isGalleryImportAllowed: true,
    );
    return image?.firstOrNull;
  }

  void onAdd() async {
    final image = await onScan();
    if (image != null) {
      docs.add(image);
      setState(() {});
    }
  }

  void onReplace(index) async {
    final image = await onScan();
    if (image != null) {
      docs[index] = image;
      setState(() {});
    }
  }

  void onDelete(index) {
    if (docs.length == 1) {
      onClose();
      return;
    }
    docs.removeAt(index);
    setState(() {});
  }

  void onRename() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => RenameModal(
        name: name,
        onRename: (val) => setState(() => name = val),
      ),
    );
  }

  void onClose() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Do you really want to get out?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'The current file will not be saved',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        actions: [
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
              Navigator.of(context).pop();
              getItService.navigatorService.onPop();
            },
            isDestructiveAction: true,
            child: const Text(
              "Yes",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void onSave() async {
    setState(() => isLoading = true);
    final paths = docs.map((e) => e).toList();
    final document = await getItService.documentUseCase.addDocument(
      name: name,
      paths: paths,
    );
    setState(() => isLoading = false);
    if (document != null) {
      Gaimon.success();
      getItService.navigatorService.onPop();
      getItService.navigatorService.onSuccessfullyDocument(document: document);
    } else {
      Gaimon.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: isDeleting
                  ? _buildDeleteButton()
                  : _buildHeader(),
            ),
            Expanded(
              child: isColumn
                  ? DocumentsColumns(
                      onRename: onRename,
                      onUpdateState: () => setState(() {}),
                      images: docs,
                      nameDoc: name,
                      onAdd: onAdd,
                      onDelete: onDelete,
                      onReplace: onReplace,
                    ).animate().fadeIn(duration: 300.ms)
                  : DocumentsGrid(
                      images: docs,
                      deleting: deleting,
                      onAdd: onAdd,
                      isDelete: isDeleting,
                      onSelectDelete: (image) {
                        if (deleting.contains(image)) {
                          deleting.remove(image);
                        } else {
                          deleting.add(image);
                        }
                        setState(() {});
                      },
                      onSwitchDelete: () {
                        deleting = [];
                        setState(() => isDeleting = !isDeleting);
                      },
                      scrollController: ScrollController(),
                      reorder: (list) => setState(() => docs = list),
                    ).animate().fadeIn(duration: 300.ms),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Opacity(
      opacity: deleting.isEmpty ? 0.5 : 1,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          if (deleting.isEmpty) return;
          if (deleting.length == docs.length) {
            onClose();
            return;
          }
          docs.removeWhere((e) => deleting.contains(e));
          isDeleting = false;
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
            ),
          ),
          child: const Icon(
            CupertinoIcons.delete,
            color: AppColors.error,
            size: 24,
          ),
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
              onPressed: onClose,
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
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSave,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
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
                child: isLoading
                    ? const CupertinoActivityIndicator(
                        color: AppColors.textPrimary,
                        radius: 8,
                      )
                    : const Text(
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
        _ViewToggle(
          isColumn: isColumn,
          onSet: (v) {
            if (v != isColumn) {
              Gaimon.selection();
              isDeleting = false;
              setState(() => isColumn = v);
            }
          },
        ),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isColumn;
  final Function(bool) onSet;

  const _ViewToggle({
    required this.isColumn,
    required this.onSet,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(
                isSelected: isColumn,
                icon: CupertinoIcons.rectangle_grid_1x2,
                onTap: () => onSet(true),
              ),
              const SizedBox(width: 16),
              _buildToggleButton(
                isSelected: !isColumn,
                icon: CupertinoIcons.square_grid_2x2,
                onTap: () => onSet(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withOpacity(0.2) 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? AppColors.primary.withOpacity(0.3)
              : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected
            ? AppColors.primary
            : AppColors.textPrimary.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }
}