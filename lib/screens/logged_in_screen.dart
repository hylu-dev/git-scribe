import 'package:flutter/material.dart';
import '../services/github_service.dart';
import '../models/github_repository.dart';
import '../widgets/app_header.dart';
import '../widgets/breadcrumbs.dart';
import '../widgets/repository_card.dart';

/// Screen shown after successful authentication
class LoggedInScreen extends StatefulWidget {
  const LoggedInScreen({super.key});

  @override
  State<LoggedInScreen> createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen>
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
  final ScrollController _scrollController = ScrollController();
  List<GitHubRepository> _repositories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
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
    _scrollController.addListener(_onScroll);
    _loadRepositories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreRepositories();
    }
  }

  Future<void> _loadRepositories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showItems = false;
      _currentPage = 1;
      _hasMore = true;
      _repositories = [];
    });
    _animationController.reset();

    try {
      final repos = await _githubService.getUserRepositories(
        page: 1,
        perPage: 10,
      );
      setState(() {
        _repositories = repos;
        _isLoading = false;
        _hasMore = repos.length == 10; // If we got 10, there might be more
        _currentPage = 1;
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
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _showItems = false;
      });
    }
  }

  Future<void> _loadMoreRepositories() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final repos = await _githubService.getUserRepositories(
        page: nextPage,
        perPage: 10,
      );

      setState(() {
        _repositories.addAll(repos);
        _isLoadingMore = false;
        _hasMore = repos.length == 10; // If we got 10, there might be more
        _currentPage = nextPage;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _loadRepositories,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.refresh),
        label: Text(_isLoading ? 'Loading...' : 'Refresh'),
        tooltip: 'Refresh repositories',
      ),
      body: Column(
        children: [
          // Shared header
          AppHeader(
            breadcrumbs: const [
              BreadcrumbItem(label: 'Repositories', route: '/home'),
            ],
            trailingAction: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadRepositories,
              tooltip: 'Refresh',
            ),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

    return ListView.builder(
      controller: _scrollController,
      itemCount: _repositories.length + (_hasMore ? 1 : 0),
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        80,
      ), // Extra bottom padding for FAB
      itemBuilder: (context, index) {
        if (index >= _repositories.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final repo = _repositories[index];
        return _buildAnimatedRepositoryCard(repo, index);
      },
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
