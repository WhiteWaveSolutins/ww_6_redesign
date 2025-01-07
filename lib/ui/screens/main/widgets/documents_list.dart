import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gaimon/gaimon.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:scan_doc/data/models/document.dart';
import 'package:scan_doc/data/models/folder.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/resurses/text.dart';
import 'package:scan_doc/ui/state_manager/document/state.dart';
import 'package:scan_doc/ui/state_manager/store.dart';
import 'package:scan_doc/ui/widgets/modal/add_document_in_folder_modal.dart';
import 'package:share_plus/share_plus.dart';

class DocumentsList extends StatelessWidget {
  final Folder? folder;
  final bool sortByDate;
  final String search;

  const DocumentsList({
    super.key,
    this.folder,
    this.sortByDate = true,
    this.search = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoreConnector<AppState, DocumentListState>(
          converter: (store) => store.state.documentListState,
          builder: (context, state) {
            if (state.isLoading) {
              return const _State(
                isLoading: true,
                isSearch: false,
              );
            }
            if (state.isError) return Text(state.errorMessage);
            final documents = state.documents.where((e) {
              if (folder == null) return e.folders.isEmpty;
              return e.folders.contains(folder!.id);
            }).toList();

            if (search.isNotEmpty) {
              documents.removeWhere((e) => !e.name.startsWith(search));
            }

            if (sortByDate) {
              documents.sort((a, b) => a.created.compareTo(b.created));
            } else {
              documents.sort((a, b) => a.name.compareTo(b.name));
            }

            if (documents.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (folder != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        '0 docs',
                        style: AppText.text16.copyWith(
                          color: Colors.white.withOpacity(.3),
                        ),
                      ),
                    ),
                  ],
                  _State(
                    isLoading: false,
                    isSearch: search.isNotEmpty,
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (folder != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${documents.length} docs',
                    style: AppText.text16.copyWith(
                      color: Colors.white.withOpacity(.3),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                const SizedBox(height: 8),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 50,
                    mainAxisExtent: 125,
                    mainAxisSpacing: 8,
                    crossAxisCount: 3,
                    crossAxisSpacing: 21,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) => DocumentCard(
                    document: documents[index],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => getItService.navigatorService.onDocument(
        document: document,
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 86,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.memory(
                      File(document.paths.first).readAsBytesSync(),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  document.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small,
                ),
                Text(
                  '${document.paths.length} pg',
                  textAlign: TextAlign.center,
                  style: AppText.small.copyWith(
                    color: Colors.white.withOpacity(.3),
                  ),
                ),
              ],
            ),
          ),
          _More(document: document),
        ],
      ),
    );
  }
}

class _More extends StatelessWidget {
  final Document document;

  const _More({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          title: 'Export',
          itemTheme: PullDownMenuItemTheme(
            textStyle: AppText.text16.copyWith(
              color: AppColors.black,
            ),
          ),
          onTap: () {
            Gaimon.selection();
            Share.shareXFiles(
              document.paths.map((e) => XFile(e)).toList(),
            );
          },
        ),
        PullDownMenuItem(
          title: 'Move',
          itemTheme: PullDownMenuItemTheme(
            textStyle: AppText.text16.copyWith(
              color: AppColors.black,
            ),
          ),
          onTap: () {
            Gaimon.selection();
            showCupertinoModalPopup(
              context: context,
              builder: (context) =>
                  AddDocumentInFolderModal(document: document),
            );
          },
        ),
        PullDownMenuItem(
          title: 'Delete',
          itemTheme: PullDownMenuItemTheme(
            textStyle: AppText.text16.copyWith(
              color: AppColors.red,
            ),
          ),
          onTap: () {
            Gaimon.selection();
            getItService.documentUseCase
                .deleteDocument(documentId: document.id);
          },
        ),
      ],
      buttonBuilder: (context, showMenu) => GestureDetector(
        onTap: showMenu,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withOpacity(.3),
          ),
          child: const Center(
            child: Icon(
              Icons.more_horiz_outlined,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _State extends StatelessWidget {
  final bool isLoading;
  final bool isSearch;

  const _State({
    super.key,
    required this.isLoading,
    required this.isSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        if (isLoading)
          const Center(
            child: CupertinoActivityIndicator(color: Colors.white),
          )
        else
          EmptyStateWidget(
            isSearch: isSearch,
          ),
        const SizedBox(height: 180),
      ],
    );
  }
}

class EmptyStateWidget extends StatefulWidget {
  final bool isSearch;
  final String? customMessage;

  const EmptyStateWidget({
    super.key,
    this.isSearch = false,
    this.customMessage,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;

  final List<ParticleModel> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -12.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 0.6), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.2), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
  }

  void _generateParticles() {
    for (int i = 0; i < 12; i++) {
      _particles.add(ParticleModel(
        angle: _random.nextDouble() * 2 * math.pi,
        radius: _random.nextDouble() * 30 + 20,
        speed: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isSearch ? AppColors.info : AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(_particles.length, (index) {
                return AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    final particle = _particles[index];
                    final offset = Offset(
                      math.cos(particle.angle) *
                          particle.radius *
                          _scaleAnimation.value,
                      math.sin(particle.angle) *
                          particle.radius *
                          _scaleAnimation.value,
                    );

                    return Transform.translate(
                      offset: offset,
                      child: Opacity(
                        opacity: _glowAnimation.value * 0.5,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Main glow effect
              AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(_glowAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Icon with animations
              AnimatedBuilder(
                animation: Listenable.merge([
                  _mainController,
                  _rotationController,
                  _bounceController,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 0.1,
                      child: Transform.scale(
                        scale: 1 + (_bounceAnimation.value * 0.1),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            widget.isSearch
                                ? CupertinoIcons.search
                                : CupertinoIcons.doc,
                            color: primaryColor,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Message
        const Text(
          'No Documents Yet',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Scan your first document',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class ParticleModel {
  final double angle;
  final double radius;
  final double speed;

  ParticleModel({
    required this.angle,
    required this.radius,
    required this.speed,
  });
}
