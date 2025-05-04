import 'package:cache_manager_plus/cache_manager_plus.dart'
    hide CacheManagerUtils;
import 'package:cache_manager_plus_utils/cache_manager_plus_utils.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Hive cache store test suite', () {
    setUp(() async {
      await CacheManager.init(
        store: HiveCacheStore(
            path: '/Users/sebastine/Desktop/CacheManagerPlusTest'),
      );
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
  });
}
