/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-29 09:35:00
 * @LastEditTime: 2025-10-02 00:10:48
 * @FilePath: /mu-music/lib/common/widgets/bottom_player_bar.dart
 * @Description: 底部播放栏组件
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

/// 底部播放栏组件
class BottomPlayerBar extends StatelessWidget {
  BottomPlayerBar({
    super.key,
    this.enableDetailNavigation = true,
  });

  final bool enableDetailNavigation;

  @override
  Widget build(BuildContext context) {
    final GlobalPlayerStore globalPlayerStore = Get.find<GlobalPlayerStore>();
    final GlobalMusicController musicController =
        Get.find<GlobalMusicController>();

    return Obx(() {
      final currentTrack = globalPlayerStore.currentTrack;
      final isPlaying = globalPlayerStore.isPlaying;
      final hasMusic = globalPlayerStore.hasMusic;

      if (!hasMusic || currentTrack == null) {
        return SizedBox.shrink();
      }

      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.navigationBg,
          border: Border(
            top: BorderSide(
              color: AppColors.borderColor,
              width: 0.5,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enableDetailNavigation
                ? () {
                    _showMusicDetail(context, currentTrack);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // 专辑封面
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.bgBtn,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetImage(
                        _albumField(currentTrack, 'picUrl'),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // 歌曲信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentTrack['name'] ?? '未知歌曲',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          _artistName(currentTrack),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 播放控制按钮
                  Row(
                    children: [
                      // 上一首按钮
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            musicController.playPrevious();
                          },
                          icon: Icon(
                            Icons.skip_previous,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                        ),
                      ),
                      // 播放/暂停按钮
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            musicController.togglePlayPause();
                          },
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: AppColors.primaryBtn,
                            size: 24,
                          ),
                        ),
                      ),
                      // 下一首按钮
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            musicController.playNext();
                          },
                          icon: Icon(
                            Icons.skip_next,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                        ),
                      ),
                      // 播放列表按钮
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            showPlaylistDialog();
                          },
                          icon: Icon(
                            Icons.queue_music,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 显示音乐详情页面
  void _showMusicDetail(BuildContext context, Map<String, dynamic> track) {
    Get.to(
      () => GlobalMusicView(),
      transition: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    );
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
