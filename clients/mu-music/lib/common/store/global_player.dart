/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-27 20:35:00
 * @LastEditTime: 2025-09-28 15:12:42
 * @FilePath: /mu-music/lib/common/store/global_player.dart
 * @Description: 全局播放状态管理器
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

/// 全局播放状态管理器
class GlobalPlayerStore extends GetxController {
  static GlobalPlayerStore get to => Get.find();

  // 是否有音乐播放
  final RxBool _hasMusic = false.obs;
  bool get hasMusic => _hasMusic.value;

  // 当前播放状态
  final RxBool _isPlaying = false.obs;
  bool get isPlaying => _isPlaying.value;

  // 当前播放的歌曲信息
  final Rxn<Map<String, dynamic>> _currentTrack = Rxn<Map<String, dynamic>>();
  Map<String, dynamic>? get currentTrack => _currentTrack.value;

  // 全局音乐控制器实例
  GlobalMusicController? _musicController;
  GlobalMusicController? get musicController => _musicController;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  /// 设置监听器
  void _setupListeners() {
    final PlaylistStore playlistStore = Get.find<PlaylistStore>();

    // 监听播放列表变化
    playlistStore.currentIndexStream.listen((index) {
      final track = playlistStore.currentTrack;
      if (track != null) {
        _currentTrack.value = track;
        _hasMusic.value = true;
      }
    });

    // 监听播放模式变化
    playlistStore.playModeStream.listen((mode) {
      update();
    });
  }

  /// 设置播放状态
  void setPlayingState(bool playing) {
    _isPlaying.value = playing;
  }

  /// 设置当前歌曲
  void setCurrentTrack(Map<String, dynamic>? track) {
    _currentTrack.value = track;
    _hasMusic.value = track != null;
  }

  /// 设置音乐控制器
  void setMusicController(GlobalMusicController? controller) {
    _musicController = controller;
  }

  /// 获取播放状态（从音乐控制器）
  bool getPlayingState() {
    if (_musicController != null) {
      return _musicController!.isPlaying;
    }
    return _isPlaying.value;
  }

  /// 监听播放状态变化
  void updatePlayingState() {
    if (_musicController != null) {
      _isPlaying.value = _musicController!.isPlaying;
    }
  }
}
