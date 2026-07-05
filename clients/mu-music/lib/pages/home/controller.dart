/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-23 13:13:54
 * @LastEditTime: 2025-09-26 18:13:13
 * @FilePath: /mu-music/lib/pages/home/controller.dart
 * @Description: 首页控制器
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

class HomeController extends GetxController {
  HomeController();
  bool isLoading = true; // 添加加载状态
  List<Map<String, dynamic>> recommendListModel = []; // 添加推荐列表
  List<dynamic> personalizedListModel = []; // 添加个性化推荐列表
  List<dynamic> singersListModel = []; // 添加热门歌手列表
  Map<String, dynamic> playlistPrivateModel = {}; // 添加私人雷达歌单 - 3136952023-私人雷达
  Map<String, dynamic> playlistTimeModel = {}; // 添加时光雷达歌单 - 5320167908-时光雷达
  Map<String, dynamic> playlistNewModel = {}; // 添加新歌雷达歌单 - 5300458264-新歌雷达

  /// 加载推荐歌曲数据
  Future<void> _initData() async {
    try {
      // 推荐歌曲
      recommendListModel = await NasMusicApi.listTracks(limit: 20);

      // 个性化推荐
      final personalized = await SongsApi.getPersonalized();
      personalizedListModel = personalized.result;

      // 热门歌手
      final singers = await SongsApi.getHotSingers();
      singersListModel = singers.artists;

      final playlists = await NasMusicApi.listPlaylists(limit: 3);
      playlistPrivateModel = playlists.isNotEmpty ? playlists[0] : {};
      playlistTimeModel = playlists.length > 1 ? playlists[1] : {};
      playlistNewModel = playlists.length > 2 ? playlists[2] : {};
    } catch (e) {
      recommendListModel = [];
      personalizedListModel = [];
      singersListModel = [];
      playlistPrivateModel = {};
      playlistTimeModel = {};
      playlistNewModel = {};
      rethrow; // 重新抛出异常以便调试
    } finally {
      isLoading = false; // 数据加载完成，设置加载状态为false
      update(["home"]);
    }
  }

  /// 手动重试加载数据
  Future<void> retryLoadData() async {
    isLoading = true;
    update(["home"]);
    await _initData();
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
