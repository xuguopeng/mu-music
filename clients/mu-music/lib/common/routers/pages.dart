/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-12 07:42:28
 * @LastEditTime: 2025-10-02 00:22:52
 * @FilePath: /mu-music/lib/common/routers/pages.dart
 * @Description: 路由页面配置
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';

import './index.dart';
import 'package:mu_music/pages/index.dart';

class RoutePages {
  // 列表
  static List<GetPage> list = [
    GetPage(
      name: RouteNames.home,
      page: () => HomePage(),
    ),
    // 移除音乐页面路由，现在使用全局弹框
    GetPage(
      name: RouteNames.musicList,
      page: () => MusicListPage(id: 0),
    ),
    GetPage(
      name: RouteNames.recommend,
      page: () => RecommendPage(),
    ),
    GetPage(
      name: RouteNames.searchPage,
      page: () => SearchPagePage(),
    ),
    GetPage(
      name: RouteNames.user,
      page: () => UserPage(),
    ),
    GetPage(
      name: RouteNames.singer,
      page: () => SingerPage(),
    ),
  ];
}
