import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:gaimon/gaimon.dart';
import 'package:scan_doc/data/models/folder.dart';
import 'package:scan_doc/data/services/shared_preferences_service.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:scan_doc/ui/widgets/toast/app_toast.dart';

class AddFolderModal extends StatefulWidget {
  final Folder? folder;
  final Function(Folder)? setFolder;

  const AddFolderModal({
    super.key,
    this.folder,
    this.setFolder,
  });

  @override
  State<AddFolderModal> createState() => _AddFolderModalState();
}

class _AddFolderModalState extends State<AddFolderModal> {
  int folder = 1;
  bool usePassword = false;
  final nameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.folder != null) {
      folder = widget.folder!.imageIndex;
      nameController.text = widget.folder!.name;
      usePassword = widget.folder!.havePassword;
    }
  }

  void save() async {
    if (nameController.text.isEmpty) {
      showAppToast('Enter name');
      return;
    }
    setState(() => isLoading = true);

    Folder? newFolder;
    if (widget.folder != null) {
      newFolder = await getItService.folderUseCase.editFolder(
        name: nameController.text,
        image: folder,
        havePassword: usePassword,
        folderId: widget.folder!.id,
      );
    } else {
      newFolder = await getItService.folderUseCase.addFolder(
        name: nameController.text,
        image: folder,
        havePassword: usePassword,
      );
    }

    setState(() => isLoading = false);
    if (newFolder != null) {
      Gaimon.success();
      widget.setFolder?.call(newFolder);
      Navigator.of(context).pop();
    } else {
      Gaimon.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                Text(
                  widget.folder == null ? 'New Folder' : 'Edit Folder',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: isLoading ? null : save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGrad1.withOpacity(0.3),
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
          ),
          const SizedBox(height: 30),
          // Folder Carousel
          SizedBox(
            height: 150,
            child: CarouselSlider(
              items: [
                for (int i = 0; i < 9; i++)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGrad1.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.surfaceDark.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          child: Image.asset(
                            'assets/images/folders/folder${i + 1}.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
              options: CarouselOptions(
                height: 150,
                viewportFraction: 0.4,
                initialPage: folder - 1,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                onPageChanged: (index, _) {
                  Gaimon.selection();
                  setState(() => folder = index + 1);
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Form Fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Name Field
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGrad1.withOpacity(0.1),
                        ),
                      ),
                      child: CupertinoTextField(
                        controller: nameController,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                        ),
                        placeholder: 'Folder Name',
                        placeholderStyle: TextStyle(
                          color: AppColors.textPrimary.withOpacity(0.5),
                          fontSize: 17,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password Toggle
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGrad1.withOpacity(0.1),
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
                                  gradient: AppGradients.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  CupertinoIcons.lock_shield_fill,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Password Protection',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          CupertinoSwitch(
                            activeColor: AppColors.primaryGrad1,
                            trackColor: AppColors.surfaceLight.withOpacity(0.2),
                            value: usePassword,
                            onChanged: (_) async {
                              if (!usePassword) {
                                final password = await SharedPreferencesService.getPassword();
                                if (password == null) {
                                  getItService.navigatorService.onInfoPassword(
                                    onOpen: () {
                                      setState(() => usePassword = true);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                  return;
                                }
                              }
                              setState(() => usePassword = !usePassword);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}