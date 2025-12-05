import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/github_service.dart';
import '../models/github_branch.dart';
import '../widgets/breadcrumbs.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: 'Back',
        ),
        title: Text(widget.repoName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBranches,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumbs
          Breadcrumbs(
            items: [
              const BreadcrumbItem(label: 'Repositories', route: '/home'),
              BreadcrumbItem(
                label: widget.repoName,
                route: null, // Current page, not clickable
              ),
            ],
          ),
          const Divider(height: 1),
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
        return _buildBranchCard(branch);
      },
    );
  }

  Widget _buildBranchCard(GitHubBranch branch) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          branch.isProtected ? Icons.lock : Icons.account_tree,
          color: branch.isProtected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          branch.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: branch.sha != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'SHA: ${branch.sha!.substring(0, 7)}...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )
            : null,
        trailing: branch.isProtected
            ? Chip(
                label: const Text('Protected'),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              )
            : null,
      ),
    );
  }
}

