/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-23 13:21:30
 * @LastEditTime: 2025-10-04 16:14:21
 * @FilePath: /mu-music/lib/pages/recommend/view.dart
 * @Description: 推荐页视图
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mu_music/common/index.dart';

import 'index.dart';

class RecommendPage extends StatefulWidget {
  RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<RecommendController>(
      init: RecommendController(),
      builder: (controller) {
        // 初始化TabController
        controller.initTabController(this);
        return _RecommendViewGetX();
      },
    );
  }
}

class _RecommendViewGetX extends GetView<RecommendController> {
  _RecommendViewGetX();

  // 构建推荐歌单列表
  Widget _buildPlaylistsView() {
    return GetBuilder<RecommendController>(
      id: 'recommend_playlists',
      builder: (_) {
        if (controller.isLoadingPlaylists && controller.playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryBtn,
                  size: 30,
                ),
              ],
            ),
          );
        }

        if (controller.playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_off,
                  size: 64,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无推荐歌单',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadPlaylists(reset: true),
          color: AppColors.primaryBtn,
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: controller.playlistsScrollController,
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2列
                    crossAxisSpacing: 16, // 列间距
                    mainAxisSpacing: 16, // 行间距
                    childAspectRatio: 0.7, // 宽高比
                  ),
                  itemCount: controller.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = controller.playlists[index];
                    return _buildPlaylistCard(playlist);
                  },
                ),
              ),
              // 加载更多指示器 - 占全行
              if (controller.hasMorePlaylists && controller.isLoadingPlaylists)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.primaryBtn,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 构建歌手列表
  Widget _buildSingersView() {
    return GetBuilder<RecommendController>(
      id: 'recommend_singers',
      builder: (_) {
        if (controller.isLoadingSingers && controller.singers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryBtn,
                  size: 30,
                ),
              ],
            ),
          );
        }

        if (controller.singers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无歌手信息',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadSingers(reset: true),
          color: AppColors.primaryBtn,
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: controller.singersScrollController,
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3列
                    crossAxisSpacing: 16, // 列间距
                    mainAxisSpacing: 16, // 行间距
                    childAspectRatio: 0.85, // 宽高比
                  ),
                  itemCount: controller.singers.length,
                  itemBuilder: (context, index) {
                    final singer = controller.singers[index];
                    return _buildSingerCard(singer);
                  },
                ),
              ),
              // 加载更多指示器 - 占全行
              if (controller.hasMoreSingers && controller.isLoadingSingers)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.primaryBtn,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 构建歌单卡片
  Widget _buildPlaylistCard(Map<String, dynamic> playlist) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(RouteNames.musicList, arguments: {'id': playlist['id']});
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.navigationBg.withValues(alpha: 0.6),
            border: Border.all(
              width: 1,
              color: AppColors.borderColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图片
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      NetImage(
                        '${playlist['coverImgUrl']}?param=200y200',
                        fit: BoxFit.cover,
                        width: 170,
                        height: 170,
                      ),
                    ],
                  ),
                ),
              ),
              // 歌单信息
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 歌单名称
                      Text(
                        playlist['name'] ?? '未知歌单',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 8),
                      // 播放次数
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 12,
                            color: AppColors.secondaryText,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatPlayCount(playlist['playCount'] ?? 0),
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建歌手卡片
  Widget _buildSingerCard(Map<String, dynamic> singer) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(RouteNames.singer, arguments: {'id': singer['id']});
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.navigationBg.withValues(alpha: 0.6),
            border: Border.all(
              width: 1,
              color: AppColors.borderColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 歌手头像
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBtn.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: NetImage(
                      '${singer['picUrl']}?param=200y200',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // 歌手名称
                Text(
                  singer['name'] ?? '未知歌手',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                // 歌曲数量
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 12,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${singer['musicSize'] ?? 0}首',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
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
  }

  // 格式化播放次数
  String _formatPlayCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else {
      return count.toString();
    }
  }

  // 主视图
  Widget _buildView(RecommendController controller) {
    return Column(
      children: [
        // 顶部栏（返回键 + Tab）
        Container(
          decoration: BoxDecoration(
            color: AppColors.navigationBg,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 返回按钮行
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Tab栏
              TabBar(
                controller: controller.tabController,
                onTap: controller.onTabChanged,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.playlist_play, size: 18),
                        SizedBox(width: 8),
                        Text('推荐歌单'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 18),
                        SizedBox(width: 8),
                        Text('歌手列表'),
                      ],
                    ),
                  ),
                ],
                indicatorColor: AppColors.primaryBtn,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.primaryBtn,
                unselectedLabelColor: AppColors.secondaryText,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // 内容区域
        Expanded(
          child: TabBarView(
            controller: controller.tabController,
            physics: ClampingScrollPhysics(),
            children: [
              _buildPlaylistsView(),
              _buildSingersView(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendController>(
      id: "recommend",
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.appBg,
          body: SafeArea(
            child: _buildView(controller),
          ),
        );
      },
    );
  }
}
