import 'package:flutter/material.dart';
import '../services/github/github_service.dart';
import '../models/github_repository.dart';
import '../services/github/github_access_guard.dart';
import '../widgets/navigation/app_header.dart';
import '../widgets/navigation/breadcrumbs.dart';
import '../widgets/cards/repository_card.dart';
import '../widgets/common/lazy_load_list_view.dart';
import '../widgets/common/refresh_button.dart';

/// Home screen shown after successful authentication
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Animation timing properties
  static const Duration _animationDuration = Duration(milliseconds: 600);
  static const Duration _animationStartDelay = Duration(milliseconds: 100);
  static const double _itemDelayMultiplier = 0.05;
  static const int _maxItemsForDelay = 20;
  static const double _itemAnimationDuration = 0.5;
  static const double _maxStartPosition = 0.85;
  static const double _slideOffset = 30.0;

  final GitHubService _githubService = GitHubService();
  List<GitHubRepository> _repositories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  late AnimationController _animationController;
  bool _showItems = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _loadRepositories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRepositories({bool forceRefresh = false}) async {
    if (!await GitHubAccessGuard.ensureAccess(context)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showItems = false;
      _hasMore = true;
      if (forceRefresh) {
        _repositories = [];
      }
    });
    if (forceRefresh) {
      _animationController.reset();
    }

    try {
      final repos = await _githubService.getUserRepositories(
        page: 1,
        perPage: 10,
        forceRefresh: forceRefresh,
      );
      setState(() {
        _repositories = repos;
        _isLoading = false;
        _hasMore = repos.length == 10; // If we got 10, there might be more
      });
      // Start cascade animation after a brief delay
      Future.delayed(_animationStartDelay, () {
        if (mounted) {
          setState(() {
            _showItems = true;
          });
          _animationController.forward();
        }
      });
    } catch (e) {
      final errorMessage = e.toString();

      // For other errors, show the error message as before
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
        _showItems = false;
      });
    }
  }

  Future<List<GitHubRepository>> _loadMoreRepositories(int page) async {
    if (!await GitHubAccessGuard.ensureAccess(context)) {
      return [];
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final repos = await _githubService.getUserRepositories(
        page: page,
        perPage: 10,
      );

      setState(() {
        _repositories.addAll(repos);
        _hasMore = repos.length == 10; // If we got 10, there might be more
        _isLoadingMore = false;
      });

      return repos;
    } catch (e) {
      final errorMessage = e.toString();

      // For other errors, show the error message
      setState(() {
        _errorMessage = errorMessage;
        _isLoadingMore = false;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: RefreshButton(
        isLoading: _isLoading,
        onPressed: () => _loadRepositories(forceRefresh: true),
        tooltip: 'Refresh repositories',
      ),
      body: Column(
        children: [
          // Shared header
          AppHeader(
            breadcrumbs: const [
              BreadcrumbItem(label: 'Repositories', route: '/home'),
            ],
          ),
          // Repositories list
          Expanded(child: _buildRepositoriesList()),
        ],
      ),
    );
  }

  Widget _buildRepositoriesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading repositories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRepositories,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_repositories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No repositories found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any repositories yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Check if we should use wide layout (tablet/desktop)
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideLayout = screenWidth >= 800;

    return LazyLoadListView<GitHubRepository>(
      items: _repositories,
      itemBuilder: (context, repo, index) {
        return _buildAnimatedRepositoryCard(repo, index);
      },
      loadMore: _loadMoreRepositories,
      hasMore: _hasMore,
      isLoadingMore: _isLoadingMore,
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        80,
      ), // Extra bottom padding for FAB
      gridDelegate: isWideLayout
          ? const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 160, // Fixed height to prevent stretching
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            )
          : null,
    );
  }

  Widget _buildAnimatedRepositoryCard(GitHubRepository repo, int index) {
    // Calculate delay for cascade effect
    final itemDelay = (index % _maxItemsForDelay) * _itemDelayMultiplier;
    final start = itemDelay.clamp(0.0, _maxStartPosition);
    final end = (itemDelay + _itemAnimationDuration).clamp(0.0, 1.0);

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideOffset * (1 - animation.value)),
          child: Opacity(
            opacity: _showItems ? animation.value : 0.0,
            child: RepositoryCard(repo: repo),
          ),
        );
      },
    );
  }
}
