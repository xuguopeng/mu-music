/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-23 13:19:22
 * @LastEditTime: 2025-10-10 13:17:53
 * @FilePath: /mu-music/lib/pages/search-page/view.dart
 * @Description: 搜索页视图
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mu_music/common/index.dart';
import 'package:mu_music/pages/music-list/widgets/index.dart';

import 'index.dart';

class SearchPagePage extends StatefulWidget {
  SearchPagePage({super.key});

  @override
  State<SearchPagePage> createState() => _SearchPagePageState();
}

class _SearchPagePageState extends State<SearchPagePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _SearchPageViewGetX();
  }
}

class _SearchPageViewGetX extends GetView<SearchPageController> {
  _SearchPageViewGetX();

  // 顶部栏
  Widget _buildTopBar() {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 返回按钮
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
            // 搜索输入框
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller.searchController,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: '搜索歌曲、歌手、专辑',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Image.asset(
                        AssetsImages.searchPng,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    suffixIcon: controller.searchKeyword.isNotEmpty
                        ? IconButton(
                            onPressed: controller.clearSearch,
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.secondaryText,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      controller.search(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 搜索结果
  Widget _buildSearchResults() {
    if (!controller.hasSearched) {
      return _buildSearchHistory();
    }

    if (controller.isSearching) {
      return _buildLoadingState();
    }

    if (controller.searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildResultsList();
  }

  // 搜索历史
  Widget _buildSearchHistory() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索提示
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: AppColors.secondaryText.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16),
                Text(
                  '搜索你喜欢的音乐',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          // 热门搜索
          // Text(
          //   '热门搜索',
          //   style: TextStyle(
          //     color: AppColors.primaryText,
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // SizedBox(height: 12),
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 8,
          //   children: [
          //     _buildHotSearchTag('周杰伦'),
          //     _buildHotSearchTag('邓紫棋'),
          //     _buildHotSearchTag('林俊杰'),
          //     _buildHotSearchTag('薛之谦'),
          //     _buildHotSearchTag('毛不易'),
          //     _buildHotSearchTag('陈奕迅'),
          //   ],
          // ),
          SizedBox(height: 24),
          // 搜索历史
          if (controller.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索历史',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: controller.clearSearchHistory,
                  child: Text(
                    '清空',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...controller.searchHistory
                .map((keyword) => _buildHistoryItem(keyword)),
          ],
        ],
      ),
    );
  }

  // 热门搜索标签
  // Widget _buildHotSearchTag(String keyword) {
  //   return GestureDetector(
  //     onTap: () {
  //       controller.searchController.text = keyword;
  //       controller.search(keyword);
  //     },
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //       decoration: BoxDecoration(
  //         color: AppColors.navigationBg.withValues(alpha: 0.6),
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(
  //           color: AppColors.borderColor.withValues(alpha: 0.3),
  //           width: 1,
  //         ),
  //       ),
  //       child: Text(
  //         keyword,
  //         style: TextStyle(
  //           color: AppColors.primaryText,
  //           fontSize: 14,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // 搜索历史项
  Widget _buildHistoryItem(String keyword) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          controller.searchController.text = keyword;
          controller.search(keyword);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.navigationBg.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: AppColors.secondaryText,
                size: 16,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.removeSearchHistory(keyword),
                child: Icon(
                  Icons.close,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.primaryBtn,
            size: 30,
          ),
          SizedBox(height: 16),
          Text(
            '搜索中...',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 无结果状态
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: AppColors.secondaryText.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            '没有找到相关歌曲',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '试试其他关键词',
            style: TextStyle(
              color: AppColors.secondaryText.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 结果列表
  Widget _buildResultsList() {
    return CustomScrollView(
      controller: controller.scrollController,
      slivers: [
        // 播放全部按钮
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            height: 50,
            child: PlayAllButton(
              trackCount: controller.searchResults.length,
              onTap: controller.playAll,
            ),
          ),
        ),
        // 歌曲列表
        SliverList.builder(
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final track = controller.searchResults[index];
            return MusicItem(
              track: track,
              index: index,
              onTap: () => controller.playSingleTrack(track, index),
            );
          },
        ),
        // 加载更多指示器
        if (controller.isLoading)
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryBtn,
                  size: 32,
                ),
              ),
            ),
          ),
        // 底部留白
        SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchPageController>(
      init: SearchPageController(),
      id: "search_page",
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.appBg,
          body: SafeArea(
            child: Column(
              children: [
                // 自定义顶部栏
                _buildTopBar(),
                // 搜索结果内容
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 自定义粘性头部代理
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      color: AppColors.navigationBg,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
