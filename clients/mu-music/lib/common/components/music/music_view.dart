/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-01-27 10:00:00
 * @LastEditTime: 2025-10-10 13:07:00
 * @FilePath: /mu-music/lib/common/components/music/music_view.dart
 * @Description: 全局音乐播放视图
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';
import 'dart:math' as math;
import 'dart:ui';

/// 全局音乐播放视图
class GlobalMusicView extends StatelessWidget {
  GlobalMusicView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalMusicController>(
      builder: (controller) {
        final currentTrack = Get.find<GlobalPlayerStore>().currentTrack;

        if (currentTrack == null) {
          return SizedBox.shrink();
        }

        return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              // 背景图片
              Positioned.fill(
                child: NetImage(
                  _albumField(currentTrack, 'picUrl'),
                  fit: BoxFit.cover,
                ),
              ),
              // 模糊效果层
              Positioned.fill(
                child: BackdropFilter(
                  // 模糊滤镜，sigma值越大越模糊
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  // 模糊层上的半透明遮罩，增强文字可读性
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        // 顶部控制栏
                        _buildTopBar(context),
                        // 专辑封面区域
                        _buildAlbumCover(context, currentTrack),
                        // 歌曲信息区域
                        _buildSongInfo(context, currentTrack),
                        SizedBox(height: 20),
                        // 歌词区域
                        SizedBox(
                          height: 200,
                          child: _buildLyricsArea(context, controller),
                        ),
                        // 进度条区域
                        _buildProgressBar(context, controller),
                        // 控制按钮区域
                        _buildControlButtons(context, controller),
                      ],
                    ),
                  ),
                ),
              ),
            ]));
      },
    );
  }

  /// 构建顶部控制栏
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 关闭按钮
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                Get.back(); // 关闭音乐详情页面
              },
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建专辑封面区域
  Widget _buildAlbumCover(BuildContext context, Map<String, dynamic> track) {
    final coverSize = math.min(MediaQuery.of(context).size.width * 0.5, 240.0);
    return Container(
      width: coverSize,
      height: coverSize,
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: NetImage(
          _albumField(track, 'picUrl'),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// 构建歌曲信息区域
  Widget _buildSongInfo(BuildContext context, Map<String, dynamic> track) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // 歌曲名称
          Text(
            track['name'] ?? '未知歌曲',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          // 歌手名称
          Text(
            _artistName(track),
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 构建进度条区域
  Widget _buildProgressBar(
      BuildContext context, GlobalMusicController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Obx(() => Column(
            children: [
              // 进度条
              Material(
                color: Colors.transparent,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white30,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.2),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: controller.totalDuration > 0
                        ? controller.currentPosition / controller.totalDuration
                        : 0.0,
                    onChanged: (value) {
                      final position =
                          (value * controller.totalDuration).round();
                      controller.seekTo(position);
                    },
                  ),
                ),
              ),
              // 时间显示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.formatDuration(controller.currentPosition),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    controller.formatDuration(controller.totalDuration),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  /// 构建控制按钮区域
  Widget _buildControlButtons(
      BuildContext context, GlobalMusicController controller) {
    final playlistStore = Get.find<PlaylistStore>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 播放模式按钮
          Obx(() => Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    playlistStore.togglePlayMode();
                  },
                  icon: Icon(
                    _getPlayModeIcon(playlistStore.playMode),
                    color: Colors.white70,
                    size: 24,
                  ),
                ),
              )),

          // 上一首按钮
          Obx(() => Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: playlistStore.hasPlaylist
                      ? () {
                          controller.playPrevious();
                        }
                      : null,
                  icon: Icon(
                    Icons.skip_previous,
                    color: playlistStore.hasPlaylist
                        ? Colors.white
                        : Colors.white30,
                    size: 32,
                  ),
                ),
              )),

          // 播放/暂停按钮
          Obx(() => Material(
                color: Colors.transparent,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.togglePlayPause();
                    },
                    icon: Icon(
                      controller.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              )),

          // 下一首按钮
          Obx(() => Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: playlistStore.hasPlaylist
                      ? () {
                          controller.playNext();
                        }
                      : null,
                  icon: Icon(
                    Icons.skip_next,
                    color: playlistStore.hasPlaylist
                        ? Colors.white
                        : Colors.white30,
                    size: 32,
                  ),
                ),
              )),

          // 播放列表按钮
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                showPlaylistDialog();
              },
              icon: Icon(
                Icons.queue_music,
                color: Colors.white70,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建歌词区域
  Widget _buildLyricsArea(
      BuildContext context, GlobalMusicController controller) {
    if (controller.lyrics.isEmpty) {
      return Center(
        child: Text(
          '暂无歌词',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Obx(() => ListView.builder(
            controller: controller.lyricScrollController,
            itemCount: controller.lyrics.length,
            itemBuilder: (context, index) {
              final lyric = controller.lyrics[index];
              final isCurrent = index == controller.currentLyricIndex;

              return Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  lyric.text,
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white54,
                    fontSize: isCurrent ? 20 : 16,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          )),
    );
  }

  /// 获取播放模式图标
  IconData _getPlayModeIcon(int mode) {
    switch (mode) {
      case 0:
        return Icons.repeat; // 顺序播放
      case 1:
        return Icons.shuffle; // 随机播放
      case 2:
        return Icons.repeat_one; // 单曲循环
      default:
        return Icons.repeat;
    }
  }

  String _artistName(Map<String, dynamic> track) {
    final artists = track['ar'];
    if (artists is List && artists.isNotEmpty && artists.first is Map) {
      return artists.first['name']?.toString() ?? '未知歌手';
    }
    final rawArtists = track['artists'];
    if (rawArtists is List && rawArtists.isNotEmpty) {
      final first = rawArtists.first;
      if (first is Map && first['artist'] is Map) {
        return (first['artist'] as Map)['name']?.toString() ?? '未知歌手';
      }
      if (first is Map) return first['name']?.toString() ?? '未知歌手';
    }
    return track['albumArtist']?.toString() ?? '未知歌手';
  }

  String _albumField(Map<String, dynamic> track, String key) {
    final album = track['al'];
    if (album is Map) return album[key]?.toString() ?? '';
    final rawAlbum = track['album'];
    if (rawAlbum is Map && key == 'picUrl') {
      return NasMusicApi.resolveAssetUrl(
        rawAlbum['coverArtUrl']?.toString() ?? rawAlbum['picUrl']?.toString(),
      );
    }
    if (key == 'picUrl') {
      return NasMusicApi.resolveAssetUrl(track['coverArtUrl']?.toString());
    }
    return '';
  }
}
