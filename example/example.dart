import 'package:cache_manager_plus/cache_manager_plus.dart';
import 'package:cache_manager_plus_utils/cache_manager_plus_utils.dart';

void main() async {
  await CacheManager.init(
    store: HiveCacheStore(path: '/Users/sebastine/Downloads'),
  );

  await CacheManager.instance.set(
    CacheItem.ephemeral(key: 'key', data: 'Hello World'),
  );

  print((await CacheManager.instance.get('key'))?.data); // prints hello world
}
