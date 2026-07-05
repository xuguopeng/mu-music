/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-26 00:43:58
 * @LastEditTime: 2025-09-29 13:11:41
 * @FilePath: /mu-music/lib/common/components/card.dart
 * @Description:
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';
import 'package:get/get.dart';

/// 卡片组件
Widget buildCard(String title, String imageUrl, dynamic id) {
  return GestureDetector(
      onTap: () {
        Get.toNamed(RouteNames.musicList, arguments: {'id': id});
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.navigationBg.withValues(alpha: 0.5),
          border: Border.all(
            width: 1,
            color: AppColors.borderColor,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetImage(
                  imageUrl,
                  width: 170,
                  height: 170,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ));
}

/// 歌手卡片组件
Widget buildSingerCard(
    dynamic id, String name, String imageUrl, int musicCount) {
  return GestureDetector(
    onTap: () {
      Get.toNamed(RouteNames.singer, arguments: {'id': id});
    },
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: NetImage(
            imageUrl,
            width: 100,
            height: 100,
          ),
        ),
        SizedBox(height: 10),
        Text(name,
            style: TextStyle(color: AppColors.primaryText, fontSize: 16)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 16, color: AppColors.primaryText),
            Text('$musicCount首',
                style: TextStyle(color: AppColors.primaryText, fontSize: 16)),
          ],
        ),
      ],
    ),
  );
}
