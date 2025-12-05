import 'package:flutter/material.dart';

/// Generic lazy loading list view widget
/// Automatically loads more items as user scrolls
class LazyLoadListView<T> extends StatefulWidget {
  /// Initial list of items
  final List<T> items;

  /// Function to build each item widget
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Function to load more items (returns next page of items)
  final Future<List<T>> Function(int page) loadMore;

  /// Whether there are more items to load
  final bool hasMore;

  /// Whether currently loading more items
  final bool isLoadingMore;

  /// Padding around the list
  final EdgeInsets padding;

  /// Scroll controller (optional, will create one if not provided)
  final ScrollController? controller;

  /// Called when scroll position changes
  final void Function(ScrollController controller)? onScroll;

  /// Threshold for loading more (0.0 to 1.0, where 1.0 is bottom)
  /// Default is 0.8 (80% scrolled)
  final double loadMoreThreshold;

  /// Widget to show at the bottom while loading more
  final Widget? loadingMoreWidget;

  /// Widget to show when there are no more items
  final Widget? endOfListWidget;

  const LazyLoadListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.loadMore,
    required this.hasMore,
    this.isLoadingMore = false,
    this.padding = const EdgeInsets.all(8),
    this.controller,
    this.onScroll,
    this.loadMoreThreshold = 0.8,
    this.loadingMoreWidget,
    this.endOfListWidget,
  });

  @override
  State<LazyLoadListView<T>> createState() => _LazyLoadListViewState<T>();
}

class _LazyLoadListViewState<T> extends State<LazyLoadListView<T>> {
  late ScrollController _scrollController;
  int _nextPage = 2; // Start at page 2 since page 1 is loaded initially

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(LazyLoadListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset page counter if items were reset (e.g., on refresh)
    if (widget.items.length < oldWidget.items.length) {
      _nextPage = 2;
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (widget.onScroll != null) {
      widget.onScroll!(_scrollController);
    }

    // Check if we should load more
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent *
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (widget.isLoadingMore || !widget.hasMore) return;

    try {
      final page = _nextPage;
      await widget.loadMore(page);
      setState(() {
        _nextPage = page + 1;
      });
    } catch (e) {
      // Error handling is done in the parent's loadMore function
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount =
        widget.items.length +
        (widget.hasMore && widget.isLoadingMore ? 1 : 0) +
        (!widget.hasMore && widget.items.isNotEmpty ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      padding: widget.padding,
      itemBuilder: (context, index) {
        // Show items
        if (index < widget.items.length) {
          return widget.itemBuilder(context, widget.items[index], index);
        }

        // Show loading indicator
        if (index == widget.items.length &&
            widget.hasMore &&
            widget.isLoadingMore) {
          return widget.loadingMoreWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }

        // Show end of list indicator
        if (index == widget.items.length && !widget.hasMore) {
          return widget.endOfListWidget ?? const SizedBox.shrink();
        }

        return const SizedBox.shrink();
      },
    );
  }
}
