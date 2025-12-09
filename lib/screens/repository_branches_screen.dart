import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/github_service.dart';
import '../models/github_branch.dart';
import '../widgets/navigation/app_header.dart';
import '../widgets/navigation/breadcrumbs.dart';
import '../widgets/cards/branch_card.dart';
import '../widgets/common/refresh_button.dart';

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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final branches = await _githubService.getRepositoryBranches(
        widget.owner,
        widget.repoName,
        forceRefresh: forceRefresh,
      );
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      final errorMessage = e.toString();

      // Check if it's a token-related error
      if (errorMessage.contains('No GitHub access token') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('sign in again')) {
        // Redirect directly to login without showing error
        if (mounted) {
          context.go('/login');
        }
        return;
      }

      // For other errors, show the error message as before
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
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

    if (isWideLayout) {
      return _buildWideBranchesList();
    } else {
      return _buildMobileBranchesList();
    }
  }

  Widget _buildMobileBranchesList() {
    return ListView.builder(
      itemCount: _branches.length,
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        80,
      ), // Extra bottom padding for FAB
      itemBuilder: (context, index) {
        final branch = _branches[index];
        return BranchCard(
          branch: branch,
          owner: widget.owner,
          repoName: widget.repoName,
        );
      },
    );
  }

  Widget _buildWideBranchesList() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate columns: 2 for tablets (800-1200px), 3 for larger screens
    final crossAxisCount = screenWidth >= 1200 ? 3 : 2;

    return GridView.builder(
      itemCount: _branches.length,
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        80,
      ), // Extra bottom padding for FAB
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final branch = _branches[index];
        return BranchCard(
          branch: branch,
          owner: widget.owner,
          repoName: widget.repoName,
        );
      },
    );
  }
}
