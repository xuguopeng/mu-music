/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-03-06 00:22:39
 * @LastEditTime: 2025-09-26 13:21:33
 * @FilePath: /mu-music/lib/common/widgets/net_image.dart
 * @Description:  加载网络图片
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';

class NetImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  NetImage(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _ImageFallback(width: width, height: height);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      placeholderFadeInDuration: Duration(milliseconds: 200),
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBtn),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppColors.surface,
        child: Icon(Icons.music_note, color: AppColors.secondaryText),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  _ImageFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: Icon(Icons.music_note, color: AppColors.secondaryText),
    );
  }
}
