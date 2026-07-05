/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-10-01 23:14:48
 * @LastEditTime: 2025-10-10 13:30:08
 * @FilePath: /mu-music/lib/common/api/search.dart
 * @Description: 搜索api
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */

import 'package:mu_music/common/index.dart';

class SearchApi {
  static const String search = '/cloudsearch';

  // 搜索歌曲
  static Future<Search> getSearch(String keyword, int limit, int offset) async {
    final songs = await NasMusicApi.listTracks(
      keyword: keyword,
      limit: limit,
      offset: offset,
    );
    return Search.fromJson({
      'code': 200,
      'result': {
        'songs': songs,
        'songCount': songs.length,
      },
    });
  }
}
