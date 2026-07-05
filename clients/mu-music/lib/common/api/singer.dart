/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-27 13:59:02
 * @LastEditTime: 2025-10-01 19:06:04
 * @FilePath: /mu-music/lib/common/api/singer.dart
 * @Description: 歌手相关api
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:mu_music/common/index.dart';

class SingerApi {
  static const String singer = '/artist/detail';

  // 获取歌手详情
  static Future<Singer> getSinger(int id) async {
    final response = await HttpUtil().get(singer, params: {
      'id': id,
    });
    return Singer.fromJson(response.data);
  }
}
