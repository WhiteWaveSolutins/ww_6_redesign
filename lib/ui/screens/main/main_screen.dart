import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scan_doc/data/models/document.dart';
import 'package:scan_doc/data/models/folder.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/screens/main/widgets/documents_list.dart';
import 'package:scan_doc/ui/screens/main/widgets/folders_list.dart';
import 'package:scan_doc/ui/state_manager/document/action.dart';
import 'package:scan_doc/ui/state_manager/folder/action.dart';
import 'package:scan_doc/ui/state_manager/store.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late Store<AppState> _store;
  bool byDate = true;
  final searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _store = StoreProvider.of<AppState>(context, listen: false);
    if (_store.state.folderListState.folders.isEmpty) {
      _store.dispatch(LoadFolderListAction());
    }
    if (_store.state.documentListState.documents.isEmpty) {
      _store.dispatch(LoadDocumentListAction());
    }

    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _searchAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            _buildSearch(),
            _buildFoldersSection(),
            _buildRecentDocumentsSection(),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: _AnimatedHeaderText(
          title: 'Your Documents',
          subtitle: 'All your files in one place',
        ),
      ).animate().fadeIn(duration: 800.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildSearch() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: _AnimatedSearchField(
          controller: searchController,
          animation: _searchAnimation,
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildFoldersSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverToBoxAdapter(
        child: StoreConnector<AppState, List<Folder>>(
          converter: (store) => store.state.folderListState.folders,
          builder: (context, folders) {
            return _AnimatedSection(
              title: 'Folders',
              delay: 400.ms,
              child: FoldersList(search: searchController.text),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentDocumentsSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverToBoxAdapter(
        child: StoreConnector<AppState, List<Document>>(
          converter: (store) => store.state.documentListState.documents,
          builder: (context, documents) {
            return _AnimatedSection(
              title: 'Recent Documents',
              delay: 600.ms,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSortControl(),
                  const SizedBox(height: 16),
                  DocumentsList(
                    search: searchController.text,
                    sortByDate: byDate,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSortControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGrad1.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.sort_down,
            color: AppColors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Sort by:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSlidingSegmentedControl<bool>(
            backgroundColor: AppColors.surfaceDark,
            thumbColor: AppColors.primary,
            groupValue: byDate,
            children: const {
              true: Text(
                'Date',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              false: Text(
                'Name',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            },
            onValueChanged: (value) => setState(() => byDate = value ?? true),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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

  @override
  void dispose() {
    _animController.dispose();
    searchController.dispose();
    super.dispose();
  }
}

class _AnimatedHeaderText extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AnimatedHeaderText({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 40,
            height: 1.2,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 17,
            height: 1.4,
            color: AppColors.textPrimary.withOpacity(0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideX(begin: -0.1, end: 0),
      ],
    );
  }
}

class _AnimatedSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Animation<double> animation;
  final ValueChanged<String> onChanged;

  const _AnimatedSearchField({
    required this.controller,
    required this.animation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(animation),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGrad1.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: CupertinoSearchTextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                ),
                placeholder: 'Search documents...',
                placeholderStyle: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.5),
                  fontSize: 17,
                ),
                backgroundColor: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Duration delay;

  const _AnimatedSection({
    required this.title,
    required this.child,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGrad1.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2, end: 0);
  }
}
