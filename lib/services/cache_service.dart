/// Service for caching API responses
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, _CacheEntry> _cache = {};
  static const Duration defaultTTL = Duration(minutes: 5);

  /// Get a cached value if it exists and hasn't expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  /// Store a value in cache with optional TTL
  void set<T>(String key, T value, {Duration? ttl}) {
    final expiresAt = DateTime.now().add(ttl ?? defaultTTL);
    _cache[key] = _CacheEntry(value: value, expiresAt: expiresAt);
  }

  /// Remove a specific cache entry
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache entries
  void clear() {
    _cache.clear();
  }

  /// Clear cache entries matching a prefix (useful for clearing all repos or branches)
  void clearByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  /// Check if a key exists and is valid
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    // Check if expired
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }
}

/// Internal cache entry with expiration
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});
}
