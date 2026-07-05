/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-24 12:44:19
 * @LastEditTime: 2025-10-10 12:37:19
 * @FilePath: /mu-music/lib/common/api/recommend-songs.dart
 * @Description: 推荐歌曲api
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:mu_music/common/index.dart';
import 'package:get/get.dart';

class RecommendSongsApi {
  static const String recommendSongs = '/recommend/songs';

  // 推荐歌单
  static Future<Recommend> getRecommendSongs() async {
    final tokenStore = Get.find<TokenStore>();
    final response = await HttpUtil().get(recommendSongs, params: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'cookie': tokenStore.token.isNotEmpty ? tokenStore.token : null
    });
    return Recommend.fromJson(response.data);
  }
}
