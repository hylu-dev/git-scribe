import 'package:flutter/material.dart';
import '../services/github/github_access_guard.dart';
import '../services/github/github_service.dart';
import '../models/github_branch.dart';
import '../widgets/navigation/app_header.dart';
import '../widgets/navigation/breadcrumbs.dart';
import '../widgets/cards/branch_card.dart';
import '../widgets/common/refresh_button.dart';
import '../widgets/common/lazy_load_list_view.dart';

/// Screen that displays branches for a repository
class RepositoryBranchesScreen extends StatefulWidget {
  final String owner;
  final String repoName;

  const RepositoryBranchesScreen({
    super.key,
    required this.owner,
    required this.repoName,
  });

  @override
  State<RepositoryBranchesScreen> createState() =>
      _RepositoryBranchesScreenState();
}

class _RepositoryBranchesScreenState extends State<RepositoryBranchesScreen> {
  final GitHubService _githubService = GitHubService();
  List<GitHubBranch> _branches = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  /// Sort branches by most recent commit date (descending)
  void _sortBranchesByCommitDate() {
    _branches.sort((a, b) {
      // Branches with no commit date go to the end
      if (a.commitDate == null && b.commitDate == null) {
        return 0;
      }
      if (a.commitDate == null) {
        return 1; // a goes after b
      }
      if (b.commitDate == null) {
        return -1; // a goes before b
      }
      // Most recent first (descending order)
      return b.commitDate!.compareTo(a.commitDate!);
    });
  }

  Future<void> _loadBranches({bool forceRefresh = false}) async {
    if (!await GitHubAccessGuard.ensureAccess(context)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasMore = true;
      if (forceRefresh) {
        _branches = [];
      }
    });

    try {
      final branches = await _githubService.getRepositoryBranches(
        widget.owner,
        widget.repoName,
        page: 1,
        perPage: 10,
        forceRefresh: forceRefresh,
      );
      setState(() {
        _branches = branches;
        _sortBranchesByCommitDate();
        _isLoading = false;
        _hasMore = branches.length == 10; // If we got 10, there might be more
      });
    } catch (e) {
      final errorMessage = e.toString();

      // For other errors, show the error message as before
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<List<GitHubBranch>> _loadMoreBranches(int page) async {
    if (!await GitHubAccessGuard.ensureAccess(context)) {
      return [];
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final branches = await _githubService.getRepositoryBranches(
        widget.owner,
        widget.repoName,
        page: page,
        perPage: 10,
      );

      setState(() {
        _branches.addAll(branches);
        _sortBranchesByCommitDate();
        _hasMore = branches.length == 10; // If we got 10, there might be more
        _isLoadingMore = false;
      });

      return branches;
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
        onPressed: () => _loadBranches(forceRefresh: true),
        tooltip: 'Refresh branches',
      ),
      body: Column(
        children: [
          // Shared header with breadcrumbs
          AppHeader(
            breadcrumbs: [
              const BreadcrumbItem(label: 'Repositories', route: '/home'),
              BreadcrumbItem(
                label: widget.repoName,
                route: null, // Current page, not clickable
              ),
            ],
          ),
          // Main content
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
              'Error loading branches',
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
              onPressed: () => _loadBranches(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_branches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No branches found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This repository doesn\'t have any branches yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Check if we should use wide layout (tablet/desktop)
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideLayout = screenWidth >= 800;

    return LazyLoadListView<GitHubBranch>(
      items: _branches,
      itemBuilder: (context, branch, index) {
        return BranchCard(
          branch: branch,
          owner: widget.owner,
          repoName: widget.repoName,
        );
      },
      loadMore: _loadMoreBranches,
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
              mainAxisExtent: 160,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            )
          : null,
    );
  }
}
