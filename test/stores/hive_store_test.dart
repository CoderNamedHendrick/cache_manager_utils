import 'package:cache_manager_plus/cache_manager_plus.dart';
import 'package:cache_manager_plus_utils/cache_manager_plus_utils.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final storePath = const bool.fromEnvironment('CI_TEST')
      ? '/Users/runner/work/cache_manager/CacheManagerPlusTest'
      : '/Users/sebastine/Desktop/CacheManagerPlusTest';

  group('Hive cache store test suite', () {
    setUp(() async {
      await CacheManager.init(store: HiveCacheStore(path: storePath));
    });

    tearDown(() {
      CacheManager.close();
    });

    test('hive cache store hello world test', () async {
      await CacheManager.instance
          .set(CacheItem.ephemeral(key: 'k', data: 'Hello world'));

      final item = await CacheManager.instance.get('k');
      expect(item?.data, 'Hello world');
    });

    test('composeKeyFromUrl cache manager util test', () async {
      final urlPath = 'https://test-url-path.com';

      final key = CacheManagerUtils.composeKeyFromUrl(
        urlPath,
        requestMethod: 'get',
        queryParams: {'user': 'doe', 'key': 'test-key'},
      );

      expect(key, 'get:https://test-url-path.com?user=doe&key=test-key');

      await CacheManager.instance
          .set(CacheItem.ephemeral(key: key, data: 'user-id=doe'));

      final item = await CacheManager.instance.get(key);
      expect(item?.data, 'user-id=doe');
    });

    test('cache store operations', () async {
      expect(await CacheManager.instance.cacheVersion(), -1);

      await CacheManager.instance.updateCacheVersion(1);

      expect(await CacheManager.instance.cacheVersion(), 1);

      await CacheManager.instance
          .set(CacheItem.ephemeral(key: 'test-key', data: 'Hello Test'));

      expect(CacheManager.instance.contains('test-key'), true);

      expect((await CacheManager.instance.get('test-key'))?.data, 'Hello Test');

      await CacheManager.instance.invalidateCacheItem('test-key');

      expect(CacheManager.instance.contains('test-key'), true);
      expect(await CacheManager.instance.isCacheItemExpired('test-key'), true);

      await CacheManager.instance.invalidateCache();

      expect(CacheManager.instance.contains('test-key'), false);
    });

    test('close store verification', () async {
      await CacheManager.instance
          .set(CacheItem.ephemeral(key: 'test-key', data: 'Hello Test'));

      expect(CacheManager.instance.contains('test-key'), true);

      expect((await CacheManager.instance.get('test-key'))?.data, 'Hello Test');

      await CacheManager.close();

      await CacheManager.init(store: HiveCacheStore(path: storePath));

      expect((await CacheManager.instance.get('test-key'))?.data, 'Hello Test');
    });
  });
}
