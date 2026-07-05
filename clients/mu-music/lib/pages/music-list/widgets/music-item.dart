/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-27 18:35:00
 * @LastEditTime: 2025-10-01 19:47:23
 * @FilePath: /mu-music/lib/pages/music-list/widgets/music-item.dart
 * @Description: 歌曲列表项组件
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

/// 歌曲列表项组件
class MusicItem extends StatelessWidget {
  final Map<String, dynamic> track;
  final int index;
  final VoidCallback? onTap;

  MusicItem({
    super.key,
    required this.track,
    required this.index,
    this.onTap,
  });

  /// 播放单个歌曲
  void _playSingleTrack() {
    // 获取播放列表存储
    final PlaylistStore playlistStore = Get.find<PlaylistStore>();

    // 检查当前是否有播放列表
    if (playlistStore.hasPlaylist) {
      // 如果有播放列表，将当前歌曲添加到列表末尾并播放
      playlistStore.addToPlaylist(track);
      playlistStore.setCurrentIndex(playlistStore.playlistCount - 1);
    } else {
      // 如果没有播放列表，创建新的播放列表
      playlistStore.setCurrentPlaylist([track], startIndex: 0);
    }

    // 开始播放歌曲
    _playTrack(track);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
      child: InkWell(
        splashColor: AppColors.primaryBtn.withValues(alpha: 0.3),
        highlightColor: AppColors.primaryBtn.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ??
            () {
              _playSingleTrack();
            },
        child: Container(
          height: 80,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navigationBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 1,
              color: AppColors.borderColor,
            ),
          ),
          child: Row(
            children: [
              // 专辑封面
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetImage(
                  track['al']['picUrl'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),

              // 歌曲信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 歌曲名称
                    Text(
                      track['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),

                    // 歌手和专辑信息
                    Row(
                      children: [
                        // 歌手名称
                        Flexible(
                          child: Text(
                            track['ar']?[0]['name'] ?? '未知歌手',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ),

                        // 分隔符
                        Text(
                          ' - ',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),

                        // 专辑名称
                        Flexible(
                          child: Text(
                            track['al']?['name'] ?? '未知专辑',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 右侧图标（可选：更多菜单或播放图标）
              // IconButton(
              //   onPressed: () {
              //     // 可以添加更多操作，如收藏、下载等
              //   },
              //   icon: Icon(
              //     Icons.more_vert,
              //     color: AppColors.secondaryText,
              //     size: 20,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
