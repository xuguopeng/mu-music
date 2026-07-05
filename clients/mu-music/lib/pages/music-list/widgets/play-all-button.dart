/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-27 18:40:00
 * @LastEditTime: 2025-09-27 19:49:24
 * @FilePath: /mu-music/lib/pages/music-list/widgets/play-all-button.dart
 * @Description: 播放全部按钮组件
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';

/// 播放全部按钮组件
class PlayAllButton extends StatelessWidget {
  final VoidCallback? onTap;
  final int trackCount;

  PlayAllButton({
    super.key,
    this.onTap,
    required this.trackCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: EdgeInsets.all(8),
      color: AppColors.appBg.withValues(alpha: 0.9),
      child: Row(
        children: [
          // 播放按钮
          InkWell(
            splashColor: AppColors.primaryBtn.withValues(alpha: 0.3),
            highlightColor: AppColors.primaryBtn.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(40),
            onTap: onTap,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.bgBtn,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.primaryBtn,
                size: 20,
              ),
            ),
          ),

          SizedBox(width: 10),

          // 播放全部文字
          Text(
            '播放全部',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(width: 8),

          // 歌曲数量
          Text(
            '($trackCount)',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),

          // 占位空间，确保布局正确
          Spacer(),
        ],
      ),
    );
  }
}
