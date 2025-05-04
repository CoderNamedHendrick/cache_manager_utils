import 'package:cache_manager_plus_utils/cache_manager_plus_utils.dart';
import 'package:test/test.dart';

void main() {
  group('cache manager plus utils test suite', () {
    test('composeKeyFromUrl cache manager util test', () async {
      final urlPath = 'https://test-url-path.com';

      final key = CacheManagerUtils.composeKeyFromUrl(
        urlPath,
        requestMethod: 'get',
        queryParams: {'user': 'doe', 'key': 'test-key'},
      );

      expect(key, 'get:https://test-url-path.com?user=doe&key=test-key');
    });
  });
}
