import 'package:flutter/material.dart';
import '../services/github_service.dart';
import '../models/github_branch.dart';
import '../widgets/navigation/app_header.dart';
import '../widgets/navigation/breadcrumbs.dart';
import '../widgets/cards/branch_card.dart';

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

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final branches = await _githubService.getRepositoryBranches(
        widget.owner,
        widget.repoName,
      );
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              onPressed: _loadBranches,
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

    return ListView.builder(
      itemCount: _branches.length,
      padding: const EdgeInsets.all(8),
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
