import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scan_doc/data/models/document.dart';
import 'package:scan_doc/data/models/folder.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/state_manager/folder/state.dart';
import 'package:scan_doc/ui/state_manager/store.dart';
import 'package:scan_doc/ui/widgets/modal/add_document_in_folder_modal.dart';
import 'package:share_plus/share_plus.dart';

class SuccessfullyAddDocumentScreen extends StatefulWidget {
  final Document document;

  const SuccessfullyAddDocumentScreen({
    super.key,
    required this.document,
  });

  @override
  State<SuccessfullyAddDocumentScreen> createState() =>
      _SuccessfullyAddDocumentScreenState();
}

class _SuccessfullyAddDocumentScreenState
    extends State<SuccessfullyAddDocumentScreen> {
  List<int> folderIds = [];

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
              child: Row(
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
                ],
              ),
            ),

            SizedBox(
              height: 230,
              child: CarouselSlider(
                items: [
                  for (var path in widget.document.paths)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 168,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.textPrimary.withOpacity(0.1),
                              ),
                            ),
                            child: Image.memory(
                              File(path).readAsBytesSync(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                options: CarouselOptions(
                  height: double.infinity,
                  initialPage: 0,
                  viewportFraction: 0.4,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Success Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    widget.document.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.check_mark,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Files saved successfully',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Want to add them to a folder?',
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Folder Selection
            if (folderIds.isEmpty)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => AddDocumentInFolderModal(
                      document: widget.document,
                      onReturnFolders: (v) => setState(() => folderIds = v),
                    ),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.folder_badge_plus,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              )
            else
              StoreConnector<AppState, FolderListState>(
                converter: (store) => store.state.folderListState,
                builder: (context, state) {
                  final folders = state.folders
                      .where((e) => folderIds.contains(e.id))
                      .toList();
                  return SizedBox(
                    height: 100,
                    child: CarouselSlider(
                      items: [
                        for (var folder in folders)
                          _buildFolderItem(folder, () {
                            getItService.documentUseCase.deleteFolderDocument(
                              documentId: widget.document.id,
                              folderId: folder.id,
                            );
                            folders.remove(folder);
                            setState(() {});
                          }),
                      ],
                      options: CarouselOptions(
                        height: double.infinity,
                        initialPage: 0,
                        viewportFraction: 0.35,
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  );
                },
              ),

            const Spacer(),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                onPressed: () {
                  Share.shareXFiles(
                    widget.document.paths.map((e) => XFile(e)).toList(),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.share,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem(Folder folder, VoidCallback onDelete) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.textPrimary.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    folder.image,
                    height: 50,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    folder.name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onDelete,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              CupertinoIcons.xmark,
              color: AppColors.error,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }
}
