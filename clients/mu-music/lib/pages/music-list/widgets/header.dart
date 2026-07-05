/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-26 20:22:33
 * @LastEditTime: 2025-10-03 20:08:05
 * @FilePath: /mu-music/lib/pages/music-list/widgets/header.dart
 * @Description: 歌单列表头部
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';

Widget buildHeader(
    Map<String, dynamic> playlistPrivateModel, BuildContext context) {
  return SliverToBoxAdapter(
      child: Padding(
    padding: EdgeInsets.all(8),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: NetImage(
            (playlistPrivateModel['coverImgUrl'] ?? '') + '?param=300y300',
            width: 120,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 150,
              child: Text(playlistPrivateModel['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: NetImage(
                    playlistPrivateModel['creator']['avatarUrl'],
                    width: 30,
                    height: 30,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${playlistPrivateModel['creator']['nickname']}',
                        style: TextStyle(
                            color: AppColors.primaryText, fontSize: 16)),
                    SizedBox(height: 5),
                    Text(
                        '${TimestampDateConverter.convert(playlistPrivateModel['createTime'])} 创建',
                        style: TextStyle(
                            color: AppColors.secondaryText, fontSize: 14)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note,
                    size: 16, color: AppColors.secondaryText),
                SizedBox(width: 3),
                Text('${playlistPrivateModel['trackCount'] ?? 0}首',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 16)),
                SizedBox(width: 10),
                Icon(Icons.headphones,
                    size: 16, color: AppColors.secondaryText),
                SizedBox(width: 3),
                Text(
                    '${formatNumberWithUnit(playlistPrivateModel['playCount'] ?? 0)}次',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 16)),
                // SizedBox(width: 10),
                // Icon(Icons.access_time,
                //     size: 16, color: AppColors.secondaryText),
                // SizedBox(width: 3),
                // Text(
                //     TimestampDateConverter.convert(
                //         playlistPrivateModel['updateTime']),
                //     style: TextStyle(
                //         color: AppColors.secondaryText, fontSize: 16)),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              width: MediaQuery.of(context).size.width - 150,
              child: Text(
                playlistPrivateModel['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
          ],
        ),
      ],
    ),
  ));
}
