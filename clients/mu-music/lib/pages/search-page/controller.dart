import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mu_music/common/index.dart';

class SearchPageController extends GetxController {
  SearchPageController();

  // 搜索相关
  final TextEditingController searchController = TextEditingController();
  String searchKeyword = '';
  bool isSearching = false;
  bool hasSearched = false;

  // 搜索历史
  List<String> searchHistory = [];

  // 搜索结果
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 0;
  int pageSize = 20;
  int totalCount = 0;

  // 滚动控制器
  final ScrollController scrollController = ScrollController();

  _initData() {
    // 添加滚动监听
    scrollController.addListener(_handleScroll);
    // 加载搜索历史
    _loadSearchHistory();
    update(["search_page"]);
  }

  // 处理滚动事件
  void _handleScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (hasMore && !isLoading) {
        loadMoreResults();
      }
    }
  }

  // 执行搜索
  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) return;

    searchKeyword = keyword.trim();
    isSearching = true;
    hasSearched = true;
    currentPage = 0;
    searchResults.clear();
    hasMore = true;

    // 添加到搜索历史
    _addToSearchHistory(keyword.trim());

    update(["search_page"]);

    try {
      await loadSearchResults();
    } catch (e) {
      debugPrint('搜索失败: $e');
    } finally {
      isSearching = false;
      update(["search_page"]);
    }
  }

  // 加载搜索结果
  Future<void> loadSearchResults() async {
    if (isLoading) return;

    try {
      isLoading = true;
      update(["search_page"]);

      final result = await SearchApi.getSearch(
          searchKeyword, pageSize, currentPage * pageSize);
      debugPrint('搜索结果: $result');
      debugPrint('结果代码: ${result.code}');
      debugPrint('结果数据类型: ${result.result.runtimeType}');
      debugPrint('结果数据: ${result.result}');

      if (result.code == 200 && result.result != null) {
        final songs = result.result!['songs'] as List<dynamic>? ?? [];
        debugPrint('歌曲数量: ${songs.length}');

        final List<Map<String, dynamic>> newSongs = songs.map((song) {
          return Map<String, dynamic>.from(song);
        }).toList();

        if (currentPage == 0) {
          searchResults = newSongs;
        } else {
          searchResults.addAll(newSongs);
        }

        totalCount = result.result!['songCount'] ?? 0;
        hasMore = newSongs.length == pageSize;
        currentPage++;

        // 获取歌曲详情
        if (newSongs.isNotEmpty) {
          await _loadSongDetails(newSongs);
        }
      } else {
        debugPrint('搜索失败: 代码=${result.code}, 结果=${result.result}');
      }
    } catch (e) {
      debugPrint('加载搜索结果失败: $e');
    } finally {
      isLoading = false;
      update(["search_page"]);
    }
  }

  // 加载更多结果
  Future<void> loadMoreResults() async {
    await loadSearchResults();
  }

  // 获取歌曲详情
  Future<void> _loadSongDetails(List<Map<String, dynamic>> songs) async {
    try {
      final songIds = songs.map((song) => song['id'].toString()).join(',');
      final songDetails = await SongApi.getSongDetail(songIds);

      // 更新搜索结果中的歌曲详情
      for (int i = 0; i < songs.length && i < songDetails.songs.length; i++) {
        final index = searchResults.indexOf(songs[i]);
        if (index != -1) {
          final detail = songDetails.songs[i];
          searchResults[index]['al'] = detail['al'];
          searchResults[index]['ar'] = detail['ar'];
          searchResults[index]['dt'] = detail['dt'];
          searchResults[index]['name'] = detail['name'];
        }
      }
      update(["search_page"]);
    } catch (e) {
      debugPrint('获取歌曲详情失败: $e');
    }
  }

  // 播放单首歌曲
  void playSingleTrack(Map<String, dynamic> track, int index) {
    try {
      final playlistStore = Get.find<PlaylistStore>();
      final musicController = Get.find<GlobalMusicController>();

      // 设置播放列表
      playlistStore.setCurrentPlaylist(searchResults, startIndex: index);

      // 初始化音乐数据
      musicController.initMusicData(track);

      // 更新全局播放状态
      final globalPlayerStore = Get.find<GlobalPlayerStore>();
      globalPlayerStore.setCurrentTrack(track);
      globalPlayerStore.setPlayingState(true);

      debugPrint('播放搜索歌曲: ${track['name']}');
    } catch (e) {
      debugPrint('播放歌曲失败: $e');
    }
  }

  // 播放全部
  void playAll() {
    if (searchResults.isEmpty) return;
    playSingleTrack(searchResults[0], 0);
  }

  // 清空搜索
  void clearSearch() {
    searchController.clear();
    searchKeyword = '';
    searchResults.clear();
    hasSearched = false;
    currentPage = 0;
    hasMore = true;
    update(["search_page"]);
  }

  // 加载搜索历史
  void _loadSearchHistory() {
    try {
      final storage = GetStorage();
      final history = storage.read<List<dynamic>>('search_history') ?? [];
      searchHistory = history.cast<String>();
    } catch (e) {
      debugPrint('加载搜索历史失败: $e');
      searchHistory = [];
    }
  }

  // 保存搜索历史
  void _saveSearchHistory() {
    try {
      final storage = GetStorage();
      storage.write('search_history', searchHistory);
    } catch (e) {
      debugPrint('保存搜索历史失败: $e');
    }
  }

  // 添加到搜索历史
  void _addToSearchHistory(String keyword) {
    if (keyword.isEmpty) return;

    // 移除已存在的相同关键词
    searchHistory.remove(keyword);
    // 添加到开头
    searchHistory.insert(0, keyword);
    // 限制历史记录数量
    if (searchHistory.length > 10) {
      searchHistory = searchHistory.take(10).toList();
    }

    _saveSearchHistory();
  }

  // 移除单个搜索历史
  void removeSearchHistory(String keyword) {
    searchHistory.remove(keyword);
    _saveSearchHistory();
    update(["search_page"]);
  }

  // 清空搜索历史
  void clearSearchHistory() {
    searchHistory.clear();
    _saveSearchHistory();
    update(["search_page"]);
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
