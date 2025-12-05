import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/github_service.dart';
import '../models/github_repository.dart';
import '../widgets/theme_selector.dart';

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

  final AuthService _authService = AuthService();
  final GitHubService _githubService = GitHubService();
  List<GitHubRepository> _repositories = [];
  bool _isLoading = true;
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

  Future<void> _loadRepositories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showItems = false;
    });
    _animationController.reset();

    try {
      final repos = await _githubService.getUserRepositories();
      setState(() {
        _repositories = repos;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final displayName = _authService.userDisplayName ?? 'User';
    final avatarUrl = _authService.userAvatarUrl;
    final email = _authService.userEmail;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('GitScribe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => ThemeSelector.show(context),
            tooltip: 'Select Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
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
          // User profile header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (avatarUrl != null)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(avatarUrl),
                  )
                else
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (email != null)
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
      itemCount: _repositories.length,
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        80,
      ), // Extra bottom padding for FAB
      itemBuilder: (context, index) {
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
            child: _buildRepositoryCard(repo),
          ),
        );
      },
    );
  }

  Widget _buildRepositoryCard(GitHubRepository repo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          repo.isPrivate ? Icons.lock : Icons.code,
          color: repo.isPrivate
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          repo.fullName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repo.description != null && repo.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                repo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (repo.language != null) ...[
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _getLanguageColor(repo.language!),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repo.language!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.star_border,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  repo.stars.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.call_split,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  repo.forks.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: () {
          // TODO: Navigate to repository details or open in browser
          // You can use url_launcher to open the repo URL
        },
      ),
    );
  }

  Color _getLanguageColor(String language) {
    // Simple color mapping for common languages
    final colors = {
      'Dart': Colors.blue,
      'JavaScript': Colors.yellow,
      'TypeScript': Colors.blue,
      'Python': Colors.green,
      'Java': Colors.orange,
      'C++': Colors.pink,
      'C': Colors.grey,
      'Go': Colors.cyan,
      'Rust': Colors.orange,
      'Swift': Colors.orange,
      'Kotlin': Colors.purple,
    };
    return colors[language] ?? Colors.grey;
  }
}
