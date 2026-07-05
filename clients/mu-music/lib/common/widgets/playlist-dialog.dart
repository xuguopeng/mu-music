/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-27 20:15:00
 * @LastEditTime: 2025-09-29 09:40:03
 * @FilePath: /mu-music/lib/common/widgets/playlist-dialog.dart
 * @Description: 播放列表对话框组件
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

/// 播放列表对话框
class PlaylistDialog extends StatelessWidget {
  PlaylistDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaylistStore playlistStore = Get.find<PlaylistStore>();

    return GetBuilder<PlaylistStore>(
      builder: (controller) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.navigationBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 头部
            _buildHeader(playlistStore),

            // 播放列表
            Expanded(
              child: _buildPlaylist(playlistStore),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(PlaylistStore playlistStore) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前播放',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Obx(() => Text(
                      '共${playlistStore.playlistCount}首 · ${playlistStore.playModeDescription}',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    )),
              ],
            ),
          ),

          // 播放模式按钮
          Obx(() => IconButton(
                onPressed: () {
                  playlistStore.togglePlayMode();
                },
                icon: Icon(
                  _getPlayModeIcon(playlistStore.playMode),
                  color: AppColors.primaryBtn,
                  size: 24,
                ),
              )),

          // 清空按钮
          IconButton(
            onPressed: () {
              _showClearDialog(playlistStore);
            },
            icon: Icon(
              Icons.clear_all,
              color: AppColors.secondaryText,
              size: 24,
            ),
          ),

          // 关闭按钮
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: AppColors.secondaryText,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建播放列表
  Widget _buildPlaylist(PlaylistStore playlistStore) {
    return Obx(() {
      if (playlistStore.currentPlaylist.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.queue_music,
                size: 64,
                color: AppColors.secondaryText,
              ),
              SizedBox(height: 16),
              Text(
                '暂无播放列表',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: playlistStore.currentPlaylist.length,
        itemBuilder: (context, index) {
          final track = playlistStore.currentPlaylist[index];
          final isCurrentTrack = index == playlistStore.currentIndex;

          return Container(
            color: isCurrentTrack
                ? AppColors.primaryBtn.withValues(alpha: 0.1)
                : Colors.transparent,
            child: ListTile(
              dense: true,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.bgBtn,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: NetImage(
                    track['al']?['picUrl'] ?? '',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                track['name'] ?? '',
                style: TextStyle(
                  color: isCurrentTrack
                      ? AppColors.primaryBtn
                      : AppColors.primaryText,
                  fontSize: 14,
                  fontWeight:
                      isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track['ar']?[0]['name'] ?? '未知歌手',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 当前播放图标
                  if (isCurrentTrack)
                    Icon(
                      Icons.volume_up,
                      color: AppColors.primaryBtn,
                      size: 18,
                    ),

                  // 删除按钮
                  IconButton(
                    onPressed: () {
                      playlistStore.removeFromPlaylist(index);
                    },
                    icon: Icon(
                      Icons.close,
                      color: AppColors.secondaryText,
                      size: 18,
                    ),
                  ),
                ],
              ),
              onTap: () {
                playlistStore.setCurrentIndex(index);
                Get.back(); // 关闭对话框

                // 播放选中的歌曲
                final track = playlistStore.currentPlaylist[index];
                _playTrack(track);
              },
            ),
          );
        },
      );
    });
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

  /// 显示清空确认对话框
  void _showClearDialog(PlaylistStore playlistStore) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.navigationBg,
        title: Text(
          '清空播放列表',
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: Text(
          '确定要清空当前播放列表吗？',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '取消',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              playlistStore.clearPlaylist();
              Get.back(); // 关闭确认对话框
              Get.back(); // 关闭播放列表对话框
            },
            child: Text(
              '确定',
              style: TextStyle(color: AppColors.primaryBtn),
            ),
          ),
        ],
      ),
    );
  }

  /// 播放指定歌曲
  void _playTrack(Map<String, dynamic> track) {
    try {
      // 获取全局音乐控制器
      final musicController = Get.find<GlobalMusicController>();

      // 初始化音乐数据
      musicController.initMusicData(track);
    } catch (e) {
      debugPrint('播放歌曲失败: $e');
    }
  }
}

/// 显示播放列表对话框的工具方法
void showPlaylistDialog() {
  Get.bottomSheet(
    PlaylistDialog(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
