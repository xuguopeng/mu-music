/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-29 12:45:13
 * @LastEditTime: 2025-10-10 12:43:47
 * @FilePath: /mu-music/lib/pages/singer/controller.dart
 * @Description: 歌手页面控制器
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';

class SingerController extends GetxController {
  SingerController();

  bool isLoading = true; // 加载状态
  bool isLoadingSongs = false; // 歌曲列表加载状态
  bool hasMoreSongs = true; // 是否有更多歌曲
  int currentPage = 0; // 当前页码
  int pageSize = 20; // 每页歌曲数量

  final ScrollController scrollController = ScrollController();
  Map<String, dynamic> singerDetail = {}; // 歌手详情
  List<Map<String, dynamic>> songsList = []; // 歌手歌曲列表
  String singerId = ''; // 歌手ID/名称
  int totalSongsCount = 0; // 歌曲总数（用于分页）

  // 标题透明度动画值（0-1）
  final RxDouble _titleOpacity = 0.0.obs;
  double get titleOpacity => _titleOpacity.value;

  // 注入播放列表存储
  final PlaylistStore playlistStore = Get.find<PlaylistStore>();

  // 对外暴露1-based页码，便于分页组件显示
  int get currentPageNum => currentPage + 1;

  _initData() async {
    try {
      singerId = Get.arguments['id']?.toString() ?? '';
      if (singerId.isEmpty) {
        debugPrint('歌手ID无效');
        return;
      }

      // 添加滚动监听
      scrollController.addListener(_handleScroll);

      // 加载歌手详情
      await loadSingerDetail();
      // 初始化总数（优先使用歌手详情里的musicSize）
      totalSongsCount = (singerDetail['artist']?['musicSize'] ?? 0) as int;
      // 加载第一页（页码从1开始显示，这里内部0索引）
      await loadSongsPage(0);
    } catch (e) {
      debugPrint('加载歌手信息失败: $e');
    } finally {
      isLoading = false;
      update(['singer']);
    }
  }

  /// 加载歌手详情
  Future<void> loadSingerDetail() async {
    try {
      singerDetail = {
        'artist': {
          'id': singerId,
          'name': singerId,
          'avatar': '',
          'musicSize': 0,
        },
      };
    } catch (e) {
      debugPrint('获取歌手详情异常: $e');
      rethrow;
    }
  }

  /// 加载指定页的歌曲（pageIndex为0-based）
  Future<void> loadSongsPage(int pageIndex) async {
    if (isLoadingSongs) return;

    try {
      isLoadingSongs = true;
      currentPage = pageIndex;
      final offset = currentPage * pageSize;
      final result =
          await SongsApi.getSongsBySinger(singerId, pageSize, offset);
      if (result.code != null && result.code == 200) {
        final newSongs = result.songs;
        if (newSongs != null && newSongs.isNotEmpty) {
          // 格式化歌曲数据
          final formattedSongs = newSongs.map((song) {
            Map<String, dynamic> songMap = {};
            if (song is Map<String, dynamic>) {
              songMap = Map<String, dynamic>.from(song);
            }
            return songMap;
          }).toList();

          songsList = formattedSongs;
          totalSongsCount = formattedSongs.length;
        } else {
          songsList = [];
          debugPrint('歌手歌曲列表为空');
        }

        // 判断是否还有更多歌曲（根据接口more或通过总数判断）
        hasMoreSongs = result.more == true ||
            ((currentPage + 1) * pageSize) <
                (totalSongsCount > 0
                    ? totalSongsCount
                    : ((result.songs?.length ?? 0)));
      } else {
        debugPrint('获取歌手歌曲列表失败');
      }
    } catch (e) {
      debugPrint('获取歌手歌曲列表异常: $e');
    } finally {
      isLoadingSongs = false;
      update(['singer', 'songs_list']);
    }
  }

  /// 旧的滚动加载兼容接口：下一页
  Future<void> loadMoreSongs({bool reset = false}) async {
    if (reset) {
      await onPageChanged(1);
    } else {
      await onPageChanged(currentPage + 2); // 下一页（1-based）
    }
  }

  /// 分页页码切换（1-based）
  Future<void> onPageChanged(int pageNum) async {
    final int pageIndex = (pageNum - 1).clamp(0, 999999);
    await loadSongsPage(pageIndex);
  }

  /// 播放全部歌曲
  void playAll() {
    if (songsList.isEmpty) {
      debugPrint('歌曲列表为空，无法播放');
      return;
    }

    // 设置播放列表
    playlistStore.setCurrentPlaylist(songsList, startIndex: 0);

    // 添加到播放历史
    playlistStore.addToHistory({
      'id': singerDetail['artist']['id'],
      'name': singerDetail['artist']['name'],
      'coverImgUrl': singerDetail['artist']['avatar'],
      'trackCount': songsList.length,
      'playTime': DateTime.now().millisecondsSinceEpoch,
    });

    // 开始播放第一首歌曲
    final firstTrack = songsList[0];
    _playTrack(firstTrack);

    debugPrint('开始播放全部，共${songsList.length}首歌曲');
    Get.to(
      () => GlobalMusicView(),
      transition: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    );
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

  /// 播放单个歌曲
  void playSingleTrack(Map<String, dynamic> track, int index) {
    // 转换歌曲列表格式
    final playlist =
        songsList.map((t) => Map<String, dynamic>.from(t)).toList();

    // 设置到播放列表存储，从指定索引开始播放
    playlistStore.setCurrentPlaylist(playlist, startIndex: index);

    // 添加到播放历史
    playlistStore.addToHistory({
      'id': singerDetail['artist']['id'],
      'name': singerDetail['artist']['name'],
      'coverImgUrl': singerDetail['artist']['avatar'],
      'trackCount': songsList.length,
      'playTime': DateTime.now().millisecondsSinceEpoch,
    });

    // 跳转到音乐播放页面
    _playTrack(track);

    debugPrint('开始播放第${index + 1}首歌曲');
  }

  /// 添加歌曲到播放列表
  void addToPlaylist(Map<String, dynamic> track) {
    try {
      // 添加歌曲到播放列表末尾
      playlistStore.addToPlaylist(track);
      debugPrint('已添加歌曲到播放列表: ${track['name']}');
    } catch (e) {
      debugPrint('添加歌曲到播放列表失败: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
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
    update(['singer']);
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();
  }
}
