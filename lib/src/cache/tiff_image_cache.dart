class TiffImageCache<K, V> {
  final int _maxSize;
  final Map<K, V> _cache = {};

  TiffImageCache(this._maxSize);

  void put(K key, V value) {
    if (_cache.length >= _maxSize) {
      _removeOldest();
    }

    _cache[key] = value;
  }

  V? get(K key) {
    return _cache[key];
  }

  void _removeOldest() {
    if (_cache.isNotEmpty) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
  }

  int get cacheSize => _cache.length;
}
