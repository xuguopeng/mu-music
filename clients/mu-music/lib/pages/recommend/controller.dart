/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-29 14:05:00
 * @LastEditTime: 2025-10-10 13:43:13
 * @FilePath: /mu-music/lib/pages/recommend/controller.dart
 * @Description: 推荐页面控制器
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';

class RecommendController extends GetxController {
  RecommendController();

  // Tab控制器 - 延迟初始化
  TabController? tabController;
  int currentTabIndex = 0;

  // 推荐歌单数据
  bool isLoadingPlaylists = false;
  bool hasMorePlaylists = true;
  List<Map<String, dynamic>> playlists = [];
  int lastTime = 0; // 上次更新时间，用于分页
  final ScrollController playlistsScrollController = ScrollController();

  // 歌手列表数据
  bool isLoadingSingers = false;
  bool hasMoreSingers = true;
  List<Map<String, dynamic>> singers = [];
  int singerPage = 0;
  int singerPageSize = 21;
  final ScrollController singersScrollController = ScrollController();

  // 初始化TabController
  void initTabController(TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);

    // 添加监听器来同步滑动切换
    tabController!.addListener(() {
      if (tabController!.indexIsChanging ||
          tabController!.index != currentTabIndex) {
        currentTabIndex = tabController!.index;
        debugPrint('TabController滑动切换: currentTabIndex $currentTabIndex');
        update(['recommend']);
      }
    });

    // 获取传入的tabIndex参数
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments.containsKey('tabIndex')) {
      currentTabIndex = arguments['tabIndex'] as int;
      tabController!.animateTo(currentTabIndex);
    }
  }

  _initData() async {
    // 获取传入的tabIndex参数
    final arguments = Get.arguments as Map<String, dynamic>?;
    currentTabIndex = (arguments != null && arguments['tabIndex'] is int)
        ? arguments['tabIndex'] as int
        : 0;
    try {
      // 添加滚动监听
      playlistsScrollController.addListener(_handlePlaylistsScroll);
      singersScrollController.addListener(_handleSingersScroll);

      // 初始化加载数据
      if (currentTabIndex == 0) {
        await loadPlaylists();
        await loadSingers();
      } else {
        await loadSingers();
        await loadPlaylists();
      }
    } catch (e) {
      debugPrint('加载推荐数据失败: $e');
    }
  }

  // 处理歌单滚动事件（防抖处理）
  void _handlePlaylistsScroll() {
    if (currentTabIndex == 0 &&
        playlistsScrollController.position.pixels >=
            playlistsScrollController.position.maxScrollExtent - 100 &&
        hasMorePlaylists &&
        !isLoadingPlaylists) {
      loadMorePlaylists();
    }
  }

  // 处理歌手滚动事件（防抖处理）
  void _handleSingersScroll() {
    if (currentTabIndex == 1 &&
        singersScrollController.position.pixels >=
            singersScrollController.position.maxScrollExtent - 100 &&
        hasMoreSingers &&
        !isLoadingSingers) {
      loadMoreSingers();
    }
  }

  /// 切换Tab
  Future<void> onTabChanged(int index) async {
    debugPrint('TabBar点击切换: currentTabIndex $index');

    // 更新TabController的索引
    if (tabController != null && tabController!.index != index) {
      tabController!.animateTo(index);
    }
  }

  /// 加载推荐歌单
  Future<void> loadPlaylists({bool reset = false}) async {
    if (isLoadingPlaylists) return;

    try {
      isLoadingPlaylists = true;
      update(['recommend_playlists']);
      if (reset) {
        playlists.clear();
        lastTime = 0;
        hasMorePlaylists = true;
        update(['recommend_playlists']);
      }

      final result = await SongsApi.getTopPlayList(0, 20, lastTime);

      if (result.code == 200) {
        final newPlaylists = result.playlists;
        if (newPlaylists.isNotEmpty) {
          // 格式化歌单数据
          final formattedPlaylists = newPlaylists.map((playlist) {
            Map<String, dynamic> playlistMap = {};
            if (playlist is Map<String, dynamic>) {
              playlistMap = Map<String, dynamic>.from(playlist);
            }
            return playlistMap;
          }).toList();

          playlists.addAll(formattedPlaylists);
          // 更新lastTime用于下一页加载
          lastTime = result.lasttime as int;

          debugPrint('成功加载${formattedPlaylists.length}个歌单');
        } else {
          debugPrint('歌单数据为空');
        }

        // 判断是否还有更多歌单
        hasMorePlaylists = result.more;
      } else {
        debugPrint('获取推荐歌单失败: ${result.code}');
        // 可以在这里添加用户提示
      }
    } catch (e) {
      debugPrint('获取推荐歌单异常: $e');
      // 可以在这里添加用户提示
    } finally {
      isLoadingPlaylists = false;
      update(['recommend_playlists']);
    }
  }

  /// 加载更多推荐歌单
  Future<void> loadMorePlaylists() async {
    await loadPlaylists();
  }

  /// 加载歌手列表
  Future<void> loadSingers({bool reset = false}) async {
    if (isLoadingSingers) return;
    try {
      isLoadingSingers = true;
      update(['recommend_singers']);
      if (reset) {
        singers.clear();
        singerPage = 0;
        hasMoreSingers = true;
        update(['recommend_singers']);
      }

      final result = await SongsApi.getHotSingers(
          limit: singerPageSize, offset: singerPage * singerPageSize);

      if (result.code == 200) {
        final newSingers = result.artists;
        if (newSingers.isNotEmpty) {
          // 格式化歌手数据
          final formattedSingers = newSingers.map((singer) {
            Map<String, dynamic> singerMap = {};
            if (singer is Map<String, dynamic>) {
              singerMap = Map<String, dynamic>.from(singer);
            }
            return singerMap;
          }).toList();

          singers.addAll(formattedSingers);
          singerPage++;

          debugPrint('成功加载${formattedSingers.length}个歌手');
        } else {
          debugPrint('歌手数据为空');
        }

        // 判断是否还有更多歌手
        hasMoreSingers = result.more;
      } else {
        debugPrint('获取歌手列表失败: ${result.code}');
        // 可以在这里添加用户提示
      }
    } catch (e) {
      debugPrint('获取歌手列表异常: $e');
      // 可以在这里添加用户提示
    } finally {
      isLoadingSingers = false;
      update(['recommend_singers']);
    }
  }

  /// 加载更多歌手
  Future<void> loadMoreSingers() async {
    await loadSingers();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  @override
  void onClose() {
    super.onClose();
    tabController?.dispose();
    playlistsScrollController.dispose();
    singersScrollController.dispose();
  }
}
