import 'dart:async';

import 'package:cache_manager_plus/cache_manager_plus.dart';
import 'package:hive_ce/hive.dart';

/// [Hive] based implementation for a [CacheStore] for dart apps; To run on flutter apps
/// set path variable using the below code copied from hive_ce_flutter[flutterInit] method
/// ```dart
/// import 'package:path/path.dart' as path_helper;
///
/// WidgetsFlutterBinding.ensureInitialized();
///
/// String? path;
/// if (!kIsWeb) {
///   final appDir = await getApplicationDocumentsDirectory();
///   path = path_helper.join(appDir.path, subDir);
/// }
///
/// HiveCacheStore(path: path);
///
/// ```
final class HiveCacheStore implements CacheStore {
  final String? path;
  final HiveStorageBackendPreference backendPreference;
  final String boxName;

  late final Box<String> _store;

  HiveCacheStore({
    this.path,
    this.backendPreference = HiveStorageBackendPreference.native,
    this.boxName = kDefaultBoxName,
  });

  static const versionKey = 'store-version';
  static const kDefaultBoxName = 'cache-store';

  @override
  Future<int> get cacheVersion async {
    final version = _store.get(versionKey);
    if (version == null) return -1;

    return int.parse(version);
  }

  @override
  Future<void> updateCacheVersion(int version) async {
    return await _store.put(versionKey, version.toString());
  }

  @override
  bool containsKey(String key) {
    return _store.containsKey(key);
  }

  @override
  Future<CacheItem?> getCacheItem(String key) async {
    final item = _store.get(key);
    if (item == null) return null;

    return CacheItem.fromCacheEntryString(item, key: key);
  }

  @override
  Future<void> initialiseStore() async {
    Hive.init(path, backendPreference: backendPreference);

    _store = await Hive.openBox(boxName);
  }

  @override
  Future<void> invalidateCache() async {
    await _store.clear();
  }

  @override
  Future<void> invalidateCacheItem(String key) async {
    final item = await getCacheItem(key);
    if (item == null) return;

    return await saveCacheItem(
      item.copyWith(persistenceDuration: const Duration(minutes: -5)),
    );
  }

  @override
  Future<void> saveCacheItem(CacheItem item) async {
    return await _store.put(item.key, item.toCacheEntryString());
  }

  @override
  FutureOr<void> close() async {
    await _store.close();
  }
}
