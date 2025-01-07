import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scan_doc/data/models/folder.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/resurses/text.dart';
import 'package:scan_doc/ui/state_manager/document/state.dart';
import 'package:scan_doc/ui/state_manager/folder/state.dart';
import 'package:scan_doc/ui/state_manager/store.dart';

class FoldersList extends StatelessWidget {
  final String search;

  const FoldersList({super.key, required this.search});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FolderListState>(
      converter: (store) => store.state.folderListState,
      builder: (context, state) {
        if (state.isLoading) {
          return const EmptyFoldersState(isLoading: true);
        }

        final folders = state.folders.toList();
        if (search.isNotEmpty) {
          folders.removeWhere((e) => !e.name.startsWith(search));
        }

        if (folders.isEmpty) {
          return EmptyFoldersState(
            isSearch: search.isNotEmpty,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 50,
                mainAxisExtent: 120,
                mainAxisSpacing: 8,
                crossAxisCount: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) => FolderCard(
                folder: folders[index],
              ),
            ),
          ],
        );
      },
    );
  }
}

class FolderCard extends StatelessWidget {
  final Folder folder;

  const FolderCard({
    super.key,
    required this.folder,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (folder.havePassword) {
          getItService.navigatorService.onInfoPassword(
            onOpen: () {
              getItService.navigatorService.onFirst();
              getItService.navigatorService.onFolder(folder: folder);
            },
          );
        } else {
          getItService.navigatorService.onFolder(folder: folder);
        }
      },
      child: Column(
        children: [
          Image.asset(
            folder.image,
            height: 70,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: Text(
              folder.name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppText.small,
            ),
          ),
          StoreConnector<AppState, DocumentListState>(
            converter: (store) => store.state.documentListState,
            builder: (context, state) {
              final count = state.documents
                  .where((e) => e.folders.contains(folder.id))
                  .toList();
              return Text(
                state.isLoading || state.isError
                    ? ''
                    : count.isEmpty
                        ? '0 docs'
                        : '${count.length} docs',
                style: AppText.small.copyWith(
                  color: Colors.white.withOpacity(.3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EmptyFoldersState extends StatefulWidget {
  final bool isSearch;
  final bool isLoading;
  final String? customMessage;

  const EmptyFoldersState({
    super.key,
    this.isSearch = false,
    this.isLoading = false,
    this.customMessage,
  });

  @override
  State<EmptyFoldersState> createState() => _EmptyFoldersStateState();
}

class _EmptyFoldersStateState extends State<EmptyFoldersState>
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
  final _random = math.Random();

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
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80.0),
          child: CupertinoActivityIndicator(
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    final primaryColor = widget.isSearch ? AppColors.info : AppColors.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textPrimary.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Particles
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

                // Glow
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
                            color:
                                primaryColor.withOpacity(_glowAnimation.value),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Icon
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
                                  : CupertinoIcons.folder_fill,
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
          const Text(
            'No Folders Yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first folder to organize documents',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
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
