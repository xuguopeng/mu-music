import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mu_music/common/index.dart';
import 'package:flutter/services.dart';

class UserController extends GetxController {
  UserController();

  // 用户歌单列表
  final RxList<Map<String, dynamic>> userPlaylists =
      <Map<String, dynamic>>[].obs;

  // WebView URL
  final String url = 'https://music.163.com/prime/m/portal';
  // 原生Cookie通道（复用之前的MethodChannel）
  static MethodChannel _cookieChannel = MethodChannel('cookie_channel');

  // 加载状态
  final RxBool isLoadingPlaylists = false.obs;

  // WebView控制器
  WebViewController? webViewController;

  // 监听状态控制
  bool _isMonitoring = false;

  @override
  void onInit() {
    super.onInit();
    // 只在初始化时检查登录状态，不自动弹出登录框
    checkLoginStatusSilently();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  _initData() {
    update(["user"]);
  }

  void onTap() {}

  /// 静默检查登录状态（不弹出登录框）
  Future<void> checkLoginStatusSilently() async {
    try {
      final loginResponse = await UserApi.getLoginStatus();

      if (loginResponse.profile != null) {
        // 已登录，保存用户信息
        _saveUserInfo(loginResponse.profile!);
        // 获取用户歌单
        await _loadUserPlaylists();
      }
      // 未登录时不弹出登录框，只更新UI状态
    } catch (e) {
      debugPrint('检查登录状态失败: $e');
      // 出错时不弹出登录框
    }
  }

  /// 检查登录状态（主动登录时调用）
  Future<void> checkLoginStatus() async {
    try {
      final loginResponse = await UserApi.getLoginStatus();
      if (loginResponse.isLoggedIn && loginResponse.profile != null) {
        // 已登录，保存用户信息
        _saveUserInfo(loginResponse.profile!);
        // 获取用户歌单
        await _loadUserPlaylists();
      } else {
        // 未登录，显示登录页面
        _showLoginPage();
      }
    } catch (e) {
      debugPrint('检查登录状态失败: $e');
      // 出错时也显示登录页面
      _showLoginPage();
    }
  }

  /// 保存用户信息到UserStore
  void _saveUserInfo(Map<String, dynamic> profile) {
    final userStore = Get.find<UserStore>();
    final user = User(
      nickname: profile['nickname'] ?? '未知用户',
      avatarUrl: profile['avatarUrl'] ?? '',
      userId: profile['userId'] ?? 0,
    );
    userStore.login(user);
  }

  /// 显示登录页面
  void _showLoginPage() {
    _isMonitoring = true; // 开始监听

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          decoration: BoxDecoration(
            color: AppColors.navigationBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '登录网易云音乐',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        _stopMonitoring(); // 停止监听
                        Get.back();
                      },
                      icon: Icon(
                        Icons.close,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // WebView
              Expanded(
                child: _buildWebView(),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      // 对话框关闭时停止监听
      _stopMonitoring();
    });
  }

  /// 停止所有监听
  void _stopMonitoring() {
    _isMonitoring = false;
    debugPrint('停止所有Cookie监听');
  }

  /// 构建WebView
  Widget _buildWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            debugPrint('页面加载完成: $url');
            _monitorCookies();
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('导航请求: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return WebViewWidget(controller: webViewController!);
  }

  /// 监控Cookie获取MUSIC_U
  void _monitorCookies() async {
    if (webViewController == null || !_isMonitoring) return;

    try {
      // 1. 调用原生方法获取Cookie（包含HttpOnly）
      final result = await _cookieChannel.invokeMethod('getCookies', {
        'url': url,
      });
      final Map<String, String> nativeCookies =
          Map<String, String>.from(result);
      debugPrint('nativeCookies: $nativeCookies');
      // 2. 提取并持久化关键 Cookie（MUSIC_U 与 __csrf）
      final String? musicU = nativeCookies['MUSIC_U'];
      debugPrint('musicU: $musicU');
      if ((musicU != null && musicU.isNotEmpty)) {
        final String cookieString = 'MUSIC_U=$musicU';

        // 保存到 TokenStore，后续接口通过 params['cookie'] 传递
        final tokenStore = Get.find<TokenStore>();
        tokenStore.updateToken(cookieString);

        debugPrint('已保存 MUSIC_U 到本地，并更新为后续请求的 cookie');
        debugPrint('MUSIC_U参数${tokenStore.token}');

        // 停止监听并关闭登录弹窗
        _stopMonitoring();
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // 刷新登录状态与数据
        await checkLoginStatusSilently();
      } else {
        // 未拿到关键 Cookie，继续轮询监听
        if (_isMonitoring) {
          Future.delayed(Duration(seconds: 2), () {
            _monitorCookies();
          });
        }
      }
    } catch (e) {
      debugPrint('获取Cookie失败: $e');
      // 出错时继续监控
      if (_isMonitoring) {
        Future.delayed(Duration(seconds: 2), () {
          _monitorCookies();
        });
      }
    }
  }

  /// 加载用户歌单
  Future<void> _loadUserPlaylists() async {
    try {
      isLoadingPlaylists.value = true;

      final userStore = Get.find<UserStore>();
      if (userStore.user == null) {
        isLoadingPlaylists.value = false;
        return;
      }

      final response = await UserApi.getUserPlaylist(userStore.user!.userId);
      if (response.playlist != null) {
        userPlaylists.value =
            List<Map<String, dynamic>>.from(response.playlist);
      } else {
        userPlaylists.clear();
      }
    } catch (e) {
      debugPrint('加载用户歌单失败: $e');
    } finally {
      isLoadingPlaylists.value = false;
    }
  }

  /// 手动刷新歌单
  Future<void> refreshPlaylists() async {
    await _loadUserPlaylists();
  }

  @override
  void onClose() {
    // 控制器销毁时停止所有监听
    _stopMonitoring();
    super.onClose();
  }
}
