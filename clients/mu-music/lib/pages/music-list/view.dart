/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-23 13:22:02
 * @LastEditTime: 2025-10-04 17:10:16
 * @FilePath: /mu-music/lib/pages/music-list/view.dart
 * @Description: 歌单列表视图
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'widgets/index.dart';

import 'index.dart';

class MusicListPage extends StatefulWidget {
  MusicListPage({super.key, required this.id});
  final dynamic id;

  @override
  State<MusicListPage> createState() => _MusicListPageState();
}

class _MusicListPageState extends State<MusicListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _MusicListViewGetX();
  }
}

class _MusicListViewGetX extends GetView<MusicListController> {
  _MusicListViewGetX();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MusicListController>(
      init: MusicListController(id: Get.arguments['id']),
      id: "music_list",
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
                            // 展开时的高度（这里只需要工具栏，不需要展开区域）
                            expandedHeight: 60,
                            // 滚动时是否固定在顶部
                            pinned: true,
                            // 背景色（根据主题调整）
                            backgroundColor: AppColors.appBg,
                            // 标题（通过透明度控制显示/隐藏）
                            title: AnimatedOpacity(
                              // 动画持续时间
                              duration: Duration(milliseconds: 200),
                              // 透明度（0-1）
                              opacity: controller.titleOpacity,
                              // 标题文本
                              child: Text(
                                  controller.playlistPrivateModel['name'] ?? '',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            // 左侧图标（始终显示）
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ),
                          buildHeader(controller.playlistPrivateModel, context),
                          // 播放按钮
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyHeaderDelegate(
                              height: 50,
                              child: PlayAllButton(
                                trackCount: controller
                                        .playlistPrivateModel['tracks']
                                        ?.length ??
                                    0,
                                onTap: controller.playAll,
                              ),
                            ),
                          ),
                          SliverList.builder(
                            itemCount: controller
                                .playlistPrivateModel['tracks'].length,
                            itemBuilder: (context, index) {
                              final track = controller
                                  .playlistPrivateModel['tracks'][index];
                              return MusicItem(
                                track: track,
                                index: index,
                                onTap: () => controller.playTrack(index),
                              );
                            },
                          ),
                          // 底部留出空间
                          SliverToBoxAdapter(
                            child: SizedBox(height: 100), // 为底部组件留出空间
                          ),
                        ],
                      ),

                // 固定在底部的组件
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: AppColors.navigationBg.withValues(alpha: 0.95),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BottomPlayerBar(),
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
