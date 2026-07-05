/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-29 12:45:13
 * @LastEditTime: 2025-10-04 17:22:33
 * @FilePath: /mu-music/lib/pages/singer/view.dart
 * @Description: 歌手页面视图
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mu_music/common/index.dart';
import 'package:mu_music/pages/music-list/widgets/index.dart';
import 'package:mu_music/common/widgets/pagination.dart';

import 'index.dart';

class SingerPage extends StatefulWidget {
  SingerPage({super.key});

  @override
  State<SingerPage> createState() => _SingerPageState();
}

class _SingerPageState extends State<SingerPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _SingerViewGetX();
  }
}

class _SingerViewGetX extends GetView<SingerController> {
  _SingerViewGetX();

  // 构建歌手信息头部
  Widget _buildSingerHeader() {
    if (controller.singerDetail.isEmpty) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // 歌手头像
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: NetImage(
                controller.singerDetail['artist']['avatar'] ?? '',
                width: 160,
                height: 160,
              ),
            ),
          ),
          SizedBox(height: 20),
          // 歌手名称
          Text(
            controller.singerDetail['artist']['name'] ?? '未知歌手',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          // 歌手信息
          Text(
            '${controller.singerDetail['artist']['musicSize'] ?? 0}首歌曲 · ${controller.singerDetail['artist']['albumSize'] ?? 0}个专辑',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SingerController>(
      init: SingerController(),
      id: "singer",
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.appBg,
          body: SafeArea(
            child: Stack(
              children: [
                // 主要内容区域
                controller.isLoading
                    ? Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppColors.primaryBtn,
                          size: 30,
                        ),
                      )
                    : CustomScrollView(
                        controller: controller.scrollController,
                        slivers: [
                          SliverAppBar(
                            // 标题栏高度
                            toolbarHeight: 60,
                            // 展开时的高度
                            expandedHeight: 300,
                            // 滚动时是否固定在顶部
                            pinned: true,
                            // 背景色
                            backgroundColor: AppColors.appBg,
                            // 标题（通过透明度控制显示/隐藏）
                            title: AnimatedOpacity(
                              duration: Duration(milliseconds: 200),
                              opacity: controller.titleOpacity,
                              child: Text(
                                controller.singerDetail['artist']['name'] ??
                                    '歌手详情',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            // 左侧图标
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () => Get.back(),
                            ),
                            // 展开区域内容
                            flexibleSpace: FlexibleSpaceBar(
                              background: _buildSingerHeader(),
                            ),
                          ),
                          // 播放全部按钮
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyHeaderDelegate(
                              height: 50,
                              child: PlayAllButton(
                                trackCount: controller.songsList.length,
                                onTap: controller.playAll,
                              ),
                            ),
                          ),
                          // 歌曲列表
                          SliverList.builder(
                            itemCount: controller.songsList.length,
                            itemBuilder: (context, index) {
                              final track = controller.songsList[index];
                              return MusicItem(
                                track: track,
                                index: index,
                                onTap: () =>
                                    controller.playSingleTrack(track, index),
                              );
                            },
                          ),
                          // 底部留出分页组件空间
                          SliverToBoxAdapter(
                            child: SizedBox(height: 50), // 只留分页组件空间
                          ),
                        ],
                      ),

                // 固定在底部的分页组件
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0, // 直接贴底，让SafeArea处理安全区
                  child: Container(
                    color: AppColors.navigationBg.withValues(alpha: 0.95),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 加载状态指示器
                        if (controller.isLoadingSongs)
                          SizedBox(
                            height: 4,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryBtn),
                            ),
                          ),
                        BottomPlayerBar(),
                        // 分页组件
                        Pagination(
                          currentPage: controller.currentPageNum,
                          totalItems: controller.totalSongsCount,
                          pageSize: controller.pageSize,
                          onPageChanged: controller.onPageChanged,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 自定义粘性头部代理（控制头部行为）
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height; // 头部高度
  final Widget child; // 头部内容

  _StickyHeaderDelegate({
    required this.height,
    required this.child,
  });

  // 头部最小高度（固定时的高度）
  @override
  double get minExtent => height;

  // 头部最大高度（未滚动时的高度，与 minExtent 一致则无拉伸效果）
  @override
  double get maxExtent => height;

  // 构建头部内容
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset, // 滚动偏移量（0 = 未滚动，maxExtent = 完全固定）
    bool overlapsContent, // 是否与下方内容重叠
  ) {
    return child;
  }

  // 是否需要重建（通常返回 false 即可）
  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
