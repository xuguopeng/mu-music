/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-27 19:55:00
 * @LastEditTime: 2025-09-29 09:43:02
 * @FilePath: /mu-music/lib/common/store/playlist.dart
 * @Description: 播放列表存储管理
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// 播放列表存储管理 Store
class PlaylistStore extends GetxController {
  // 本地存储实例
  final _storage = GetStorage();

  // 存储键
  static const _currentPlaylistKey = 'current_playlist';
  static const _playlistHistoryKey = 'playlist_history';
  static const _currentIndexKey = 'current_index';
  static const _playModeKey = 'play_mode';

  // 当前播放列表
  final RxList<Map<String, dynamic>> _currentPlaylist =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get currentPlaylist => _currentPlaylist.toList();

  // 当前播放索引
  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  // 播放模式 (0: 顺序播放, 1: 随机播放, 2: 单曲循环)
  final RxInt _playMode = 0.obs;
  int get playMode => _playMode.value;

  // 播放历史（最近播放的歌单）
  final RxList<Map<String, dynamic>> _playlistHistory =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get playlistHistory => _playlistHistory.toList();

  /// 初始化：从本地存储加载数据
  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  /// 从本地存储加载数据
  void _loadFromStorage() {
    // 加载当前播放列表
    final playlistData = _storage.read<List?>(_currentPlaylistKey);
    if (playlistData != null) {
      _currentPlaylist.value = List<Map<String, dynamic>>.from(
          playlistData.map((item) => Map<String, dynamic>.from(item)));
    }

    // 加载当前播放索引
    _currentIndex.value = _storage.read<int>(_currentIndexKey) ?? 0;

    // 加载播放模式
    _playMode.value = _storage.read<int>(_playModeKey) ?? 0;

    // 加载播放历史
    final historyData = _storage.read<List?>(_playlistHistoryKey);
    if (historyData != null) {
      _playlistHistory.value = List<Map<String, dynamic>>.from(
          historyData.map((item) => Map<String, dynamic>.from(item)));
    }
  }

  /// 设置当前播放列表
  void setCurrentPlaylist(List<Map<String, dynamic>> playlist,
      {int startIndex = 0}) {
    _currentPlaylist.value = playlist;
    _currentIndex.value = startIndex.clamp(0, playlist.length - 1);

    // 持久化到本地存储
    _storage.write(_currentPlaylistKey, playlist);
    _storage.write(_currentIndexKey, _currentIndex.value);
  }

  /// 添加歌曲到当前播放列表
  void addToPlaylist(Map<String, dynamic> track) {
    _currentPlaylist.add(track);
    _storage.write(_currentPlaylistKey, _currentPlaylist.toList());
  }

  /// 从播放列表移除歌曲
  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _currentPlaylist.length) {
      _currentPlaylist.removeAt(index);

      // 调整当前播放索引
      if (_currentIndex.value >= index && _currentIndex.value > 0) {
        _currentIndex.value--;
      }

      _storage.write(_currentPlaylistKey, _currentPlaylist.toList());
      _storage.write(_currentIndexKey, _currentIndex.value);
    }
  }

  /// 设置当前播放索引
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _currentPlaylist.length) {
      _currentIndex.value = index;
      _storage.write(_currentIndexKey, index);
    }
  }

  /// 获取当前播放的歌曲
  Map<String, dynamic>? get currentTrack {
    if (_currentPlaylist.isEmpty ||
        _currentIndex.value >= _currentPlaylist.length) {
      return null;
    }
    return _currentPlaylist[_currentIndex.value];
  }

  /// 下一首
  void nextTrack() {
    if (_currentPlaylist.isEmpty) return;

    switch (_playMode.value) {
      case 0: // 顺序播放
        _currentIndex.value =
            (_currentIndex.value + 1) % _currentPlaylist.length;
        break;
      case 1: // 随机播放
        _currentIndex.value =
            DateTime.now().millisecondsSinceEpoch % _currentPlaylist.length;
        break;
      case 2: // 单曲循环
        // 保持当前索引不变
        break;
    }
    _storage.write(_currentIndexKey, _currentIndex.value);
  }

  /// 上一首
  void previousTrack() {
    if (_currentPlaylist.isEmpty) return;

    switch (_playMode.value) {
      case 0: // 顺序播放
        _currentIndex.value =
            (_currentIndex.value - 1 + _currentPlaylist.length) %
                _currentPlaylist.length;
        break;
      case 1: // 随机播放
        _currentIndex.value =
            DateTime.now().millisecondsSinceEpoch % _currentPlaylist.length;
        break;
      case 2: // 单曲循环
        // 保持当前索引不变
        break;
    }
    _storage.write(_currentIndexKey, _currentIndex.value);
  }

  /// 切换播放模式
  void togglePlayMode() {
    _playMode.value = (_playMode.value + 1) % 3;
    _storage.write(_playModeKey, _playMode.value);
  }

  /// 获取播放模式描述
  String get playModeDescription {
    switch (_playMode.value) {
      case 0:
        return '顺序播放';
      case 1:
        return '随机播放';
      case 2:
        return '单曲循环';
      default:
        return '顺序播放';
    }
  }

  /// 添加到播放历史
  void addToHistory(Map<String, dynamic> playlistInfo) {
    // 移除重复项
    _playlistHistory.removeWhere((item) => item['id'] == playlistInfo['id']);

    // 添加到开头
    _playlistHistory.insert(0, playlistInfo);

    // 限制历史记录数量（最多保存20个）
    if (_playlistHistory.length > 20) {
      _playlistHistory.removeRange(20, _playlistHistory.length);
    }

    _storage.write(_playlistHistoryKey, _playlistHistory.toList());
  }

  /// 清空当前播放列表
  void clearPlaylist() {
    _currentPlaylist.clear();
    _currentIndex.value = 0;
    _storage.remove(_currentPlaylistKey);
    _storage.write(_currentIndexKey, 0);
  }

  /// 清空播放历史
  void clearHistory() {
    _playlistHistory.clear();
    _storage.remove(_playlistHistoryKey);
  }

  /// 是否有播放列表
  bool get hasPlaylist => _currentPlaylist.isNotEmpty;

  /// 播放列表歌曲数量
  int get playlistCount => _currentPlaylist.length;

  /// 获取当前索引的流
  Stream<int> get currentIndexStream => _currentIndex.stream;

  /// 获取播放模式的流
  Stream<int> get playModeStream => _playMode.stream;
}
