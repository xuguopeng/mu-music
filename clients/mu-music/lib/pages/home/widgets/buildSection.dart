/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-25 11:26:06
 * @LastEditTime: 2025-09-26 18:14:10
 * @FilePath: /mu-music/lib/pages/home/widgets/buildSection.dart
 * @Description: 首页公用 section 组件
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

/// 个人推荐歌曲 section
Widget buildRecommendSection(List<Map<String, dynamic>> items) {
  final int currentDay = DateTime.now().day;
  if (items.isEmpty) return SizedBox();
  return GestureDetector(
    onTap: () {
      // 点击每日推荐，播放推荐歌曲
      _playRecommendSongs(items);
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.navigationBg.withValues(alpha: 0.8),
        border: Border.all(
          width: 1,
          color: AppColors.borderColor,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: NetImage(
                items[0]['al']?['picUrl'] ?? '',
                width: 170,
                height: 170,
              ),
            ),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center, // 子组件居中对齐
                  children: [
                    // 底层图标
                    Icon(
                      Icons.calendar_today, // 圆形图标
                      size: 28, // 图标大小
                      color: AppColors.primaryText,
                    ),
                    // 上层文字（居中显示在图标上）
                    Positioned(
                        top: 10,
                        child: Text('$currentDay',
                            style: TextStyle(
                                color: AppColors.primaryText, fontSize: 12))),
                  ],
                ),
                SizedBox(width: 10),
                Text(
                  '每日推荐',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '根据你的口味为你推荐',
                  style: TextStyle(color: AppColors.primaryText, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// 播放推荐歌曲
void _playRecommendSongs(List<Map<String, dynamic>> items) {
  try {
    final musicController = Get.find<GlobalMusicController>();
    final globalPlayerStore = Get.find<GlobalPlayerStore>();
    final playlistStore = Get.find<PlaylistStore>();

    final List<Map<String, dynamic>> tracks =
        items.map((song) => Map<String, dynamic>.from(song)).toList();

    // 设置播放列表
    playlistStore.setCurrentPlaylist(tracks);
    playlistStore.setCurrentIndex(0);

    // 设置当前歌曲
    final currentTrack = tracks[0];
    globalPlayerStore.setCurrentTrack(currentTrack);

    // 初始化音乐数据并播放
    musicController.initMusicData(currentTrack);

    debugPrint('开始播放推荐歌曲: ${currentTrack['name']}');
  } catch (e) {
    debugPrint('播放推荐歌曲失败: $e');
  }
}
