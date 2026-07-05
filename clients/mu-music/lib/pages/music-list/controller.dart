/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-23 13:22:02
 * @LastEditTime: 2025-10-10 12:42:47
 * @FilePath: /mu-music/lib/pages/music-list/controller.dart
 * @Description: 歌单列表控制器
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';

class MusicListController extends GetxController {
  MusicListController({required this.id});

  bool isLoading = true; // 添加加载状态

  final ScrollController scrollController = ScrollController();

  // 注入播放列表存储
  final PlaylistStore playlistStore = Get.find<PlaylistStore>();

  // 标题透明度动画值（0-1）
  final RxDouble _titleOpacity = 0.0.obs;
  double get titleOpacity => _titleOpacity.value;
  Map<String, dynamic> playlistPrivateModel = {};
  dynamic id;
  _initData() async {
    scrollController.addListener(_handleScroll);
    id = Get.arguments['id'];
    playlistPrivateModel = (await SongsApi.getPlayList(id)).playlist;
    isLoading = false;
    // 监听滚动事件
    update(["music_list"]);
  }

  void onTap() {}

  /// 播放全部歌曲
  void playAll() {
    final tracks = playlistPrivateModel['tracks'] as List?;
    if (tracks == null || tracks.isEmpty) {
      debugPrint('歌单为空，无法播放');
      return;
    }

    // 转换歌曲列表格式
    final playlist =
        tracks.map((track) => Map<String, dynamic>.from(track)).toList();

    // 设置到播放列表存储
    playlistStore.setCurrentPlaylist(playlist, startIndex: 0);

    // 添加到播放历史
    playlistStore.addToHistory({
      'id': playlistPrivateModel['id'],
      'name': playlistPrivateModel['name'],
      'coverImgUrl': playlistPrivateModel['coverImgUrl'],
      'trackCount': tracks.length,
      'playTime': DateTime.now().millisecondsSinceEpoch,
    });

    // 开始播放第一首歌曲
    final firstTrack = tracks[0];
    _playTrack(firstTrack);

    debugPrint('开始播放全部，共${tracks.length}首歌曲');
    Get.to(
      () => GlobalMusicView(),
      transition: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    );
  }

  /// 播放指定歌曲
  void playTrack(int index) {
    final tracks = playlistPrivateModel['tracks'] as List?;
    if (tracks == null || tracks.isEmpty || index >= tracks.length) {
      debugPrint('无效的歌曲索引');
      return;
    }

    // 转换歌曲列表格式
    final playlist =
        tracks.map((track) => Map<String, dynamic>.from(track)).toList();

    // 设置到播放列表存储，从指定索引开始播放
    playlistStore.setCurrentPlaylist(playlist, startIndex: index);

    // 添加到播放历史
    playlistStore.addToHistory({
      'id': playlistPrivateModel['id'],
      'name': playlistPrivateModel['name'],
      'coverImgUrl': playlistPrivateModel['coverImgUrl'],
      'trackCount': tracks.length,
      'playTime': DateTime.now().millisecondsSinceEpoch,
    });

    // 跳转到音乐播放页面
    final track = tracks[index];
    _playTrack(track);

    debugPrint('开始播放第${index + 1}首歌曲');
  }

  /// 播放指定歌曲
  void _playTrack(Map<String, dynamic> track) {
    try {
      // 获取全局音乐控制器
      final musicController = Get.find<GlobalMusicController>();
      final globalPlayerStore = Get.find<GlobalPlayerStore>();

      // 设置当前歌曲到全局状态
      globalPlayerStore.setCurrentTrack(track);

      // 初始化音乐数据
      musicController.initMusicData(track);

      debugPrint('开始播放歌曲: ${track['name']}');
    } catch (e) {
      debugPrint('播放歌曲失败: $e');
    }
  }

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  @override
  void onClose() {
    // 销毁滚动控制器，避免内存泄漏
    scrollController.dispose();
    super.onClose();
  }

  // 处理滚动事件，更新标题显示状态
  void _handleScroll() {
    final offset = scrollController.offset;

    // 滚动阈值：超过80开始显示，超过160完全显示
    if (offset < 80) {
      _titleOpacity.value = 0.0;
    } else if (offset > 160) {
      _titleOpacity.value = 1.0;
    } else {
      // 计算过渡透明度
      _titleOpacity.value = (offset - 80) / 80;
    }

    // 通知UI更新
    update(["music_list"]);
  }
}
