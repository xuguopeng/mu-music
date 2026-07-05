/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-23 13:17:47
 * @LastEditTime: 2025-09-29 09:34:31
 * @FilePath: /mu-music/lib/pages/user/view.dart
 * @Description: 用户页视图
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

import 'index.dart';

class UserPage extends StatefulWidget {
  UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _UserViewGetX();
  }
}

class _UserViewGetX extends GetView<UserController> {
  _UserViewGetX();

  // 主视图
  Widget _buildView() {
    return GetBuilder<UserController>(
      id: "user",
      builder: (controller) {
        return Obx(() {
          final userStore = Get.find<UserStore>();

          if (!userStore.isLogin) {
            return _buildLoginPrompt();
          }

          return _buildUserContent(controller);
        });
      },
    );
  }

  /// 构建登录提示
  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 24),
          Text(
            '请先登录',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '登录后可以查看个人歌单',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // 重新检查登录状态
              controller.checkLoginStatus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBtn,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              '立即登录',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户内容
  Widget _buildUserContent(UserController controller) {
    final userStore = Get.find<UserStore>();
    final user = userStore.user!;

    return RefreshIndicator(
      onRefresh: controller.refreshPlaylists,
      color: AppColors.primaryBtn,
      child: CustomScrollView(
        slivers: [
          // 用户信息头部
          SliverToBoxAdapter(
            child: _buildUserHeader(user),
          ),

          // 歌单列表
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '我的歌单',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Obx(() {
                    if (controller.isLoadingPlaylists.value) {
                      return SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBtn),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),

          // 歌单网格
          Obx(() {
            if (controller.userPlaylists.isEmpty &&
                !controller.isLoadingPlaylists.value) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.queue_music,
                          size: 64,
                          color: AppColors.secondaryText,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '暂无歌单',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final playlist = controller.userPlaylists[index];
                    return _buildPlaylistCard(playlist);
                  },
                  childCount: controller.userPlaylists.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 构建用户信息头部
  Widget _buildUserHeader(User user) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBtn.withValues(alpha: 0.8),
            AppColors.primaryBtn.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 头像
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: NetImage(
              user.avatarUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${user.userId}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // 退出登录按钮
          IconButton(
            onPressed: () {
              _showLogoutDialog();
            },
            icon: Icon(
              Icons.logout,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建歌单卡片
  Widget _buildPlaylistCard(Map<String, dynamic> playlist) {
    // 使用首页推荐歌单的公用样式
    return buildCard(
      playlist['name'] ?? '未知歌单',
      playlist['coverImgUrl'] ?? '',
      (playlist['id'] ?? 0) is int
          ? (playlist['id'] ?? 0)
          : int.tryParse('${playlist['id']}') ?? 0,
    );
  }

  /// 显示退出登录对话框
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.navigationBg,
        title: Text(
          '退出登录',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '确定要退出登录吗？',
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
              Get.back();
              _logout();
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

  /// 退出登录
  void _logout() {
    final userStore = Get.find<UserStore>();
    final tokenStore = Get.find<TokenStore>();

    userStore.logout();
    tokenStore.clearTokens();

    // 重新静默检查登录状态
    controller.checkLoginStatusSilently();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      init: UserController(),
      id: "user",
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.appBg,
          appBar: AppBar(
            backgroundColor: AppColors.appBg,
            elevation: 0,
            title: Text(
              "个人中心",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
