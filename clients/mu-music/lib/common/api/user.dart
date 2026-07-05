/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-25 15:04:15
 * @LastEditTime: 2025-10-03 12:46:01
 * @FilePath: /mu-music/lib/common/api/user.dart
 * @Description:  用户api
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:mu_music/common/index.dart';
import 'package:get/get.dart';

class UserApi {
  static const String login = '/login/status';
  static const String userPlaylist = '/user/playlist';
  // 获取登录状态与用户信息
  static Future<Login> getLoginStatus() async {
    final tokenStore = Get.find<TokenStore>();
    final response = await HttpUtil().get(login, params: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'cookie': tokenStore.token.isNotEmpty ? tokenStore.token : null
    });
    return Login.fromJson(response.data);
  }

  // 获取用户歌单信息
  static Future<Userplaylist> getUserPlaylist(int id,
      {int limit = 40, int offset = 0}) async {
    final tokenStore = Get.find<TokenStore>();
    final response = await HttpUtil().get(userPlaylist, params: {
      'uid': id,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'cookie': tokenStore.token.isNotEmpty ? tokenStore.token : null
    });
    return Userplaylist.fromJson(response.data);
  }
}
