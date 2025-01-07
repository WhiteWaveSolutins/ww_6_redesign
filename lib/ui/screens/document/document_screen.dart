import 'dart:io';
import 'dart:ui';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaimon/gaimon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan_doc/data/models/document.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/resurses/icons.dart';
import 'package:scan_doc/ui/screens/save_document/widgets/documents_columns.dart';
import 'package:scan_doc/ui/screens/save_document/widgets/documents_grid.dart';
import 'package:scan_doc/ui/screens/save_document/widgets/rename_modal.dart';
import 'package:scan_doc/ui/widgets/svg_icon.dart';
import 'package:path/path.dart' as p;

class DocumentScreen extends StatefulWidget {
  final Document document;
  
  const DocumentScreen({
    super.key,
    required this.document,
  });

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  bool isColumn = true;
  bool isDeleting = false;
  bool isEdit = false;
  bool isLoading = false;
  late Directory? directory;
  late String name;
  List<String> docs = [];
  List<String> deleting = [];

  @override
  void initState() {
    super.initState();
    docs.addAll(widget.document.paths);
    directory = null;
    name = widget.document.name;
    getApplicationDocumentsDirectory().then((v) {
      directory = v;
      if (mounted) setState(() {});
    });
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
    showModalBottomSheet(
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: MediaQuery.of(context).size.height - 100,
      ),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => RenameModal(
        name: name,
        onRename: (val) => setState(() => name = val),
      ),
    );
  }

  void onClose() {
    if (!isEdit) {
      Navigator.of(context).pop();
      return;
    }

    showCupertinoDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CupertinoAlertDialog(
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
      ),
    );
  }

  void onSave() async {
    if (directory == null) return;
    if (!isEdit) {
      setState(() => isEdit = true);
      return;
    }
    setState(() => isLoading = true);
    final paths = docs.map((e) => p.join(directory!.path, e)).toList();
    final document = await getItService.documentUseCase.editDocument(
      id: widget.document.id,
      name: name,
      paths: paths,
    );
    setState(() => isLoading = false);
    if (document) {
      Gaimon.success();
      getItService.navigatorService.onPop();
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
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: isDeleting
                  ? _buildDeleteButton()
                  : _buildHeader(),
            ),
            
            // Content
            Expanded(
              child: isColumn
                  ? DocumentsColumns(
                      onRename: onRename,
                      images: docs,
                      nameDoc: name,
                      isEdit: isEdit,
                      onAdd: onAdd,
                      onUpdateState: () => setState(() {}),
                      onDelete: onDelete,
                      onReplace: onReplace,
                    )
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
                    ),
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
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            CupertinoIcons.delete_solid,
            color: AppColors.textPrimary,
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
            // Close Button
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
            
            // Save Button
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
                ),
                child: isLoading
                    ? const CupertinoActivityIndicator(
                        color: AppColors.textPrimary,
                        radius: 8,
                      )
                    : Text(
                        !isEdit ? 'Edit' : 'Save',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (isEdit) _buildViewToggle(),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
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
          _buildViewToggleButton(
            isSelected: isColumn,
            onPressed: () => onSet(true),
            icon: AppIcons.columns,
          ),
          const SizedBox(width: 16),
          _buildViewToggleButton(
            isSelected: !isColumn,
            onPressed: () => onSet(false),
            icon: AppIcons.grid,
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required bool isSelected,
    required VoidCallback onPressed,
    required String icon,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: SvgIcon(
        icon: icon,
        size: 24,
        color: AppColors.textPrimary.withOpacity(isSelected ? 1 : 0.3),
      ),
    );
  }

  void onSet(bool value) {
    if (value != isColumn) {
      Gaimon.selection();
      isDeleting = false;
      setState(() => isColumn = value);
    }
  }
}
