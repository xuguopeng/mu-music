/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-26 12:29:54
 * @LastEditTime: 2025-09-26 12:31:40
 * @FilePath: /mu-music/lib/common/store/token.dart
 * @Description: 令牌管理
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

/// 令牌管理 Store（负责 token 的状态管理和持久化）
class TokenStore extends GetxController {
  // 本地存储实例（使用 get_storage）
  final _storage = GetStorage();

  // 存储键（自定义，确保唯一）
  static const _tokenKey = 'auth_token';

  // 响应式状态（Rx 包装，支持响应式更新）
  final RxString _token = ''.obs;

  // 对外暴露的令牌读取方法
  String get token => _token.value;

  // 判断是否已登录（token 不为空）
  bool get isLoggedIn => _token.value.isNotEmpty;

  /// 初始化：从本地存储加载令牌
  @override
  void onInit() {
    super.onInit();
    _loadTokensFromStorage();
  }

  /// 从本地存储加载令牌到内存状态
  void _loadTokensFromStorage() {
    // 读取访问令牌
    final storedToken = _storage.read<String?>(_tokenKey) ?? '';
    _token.value = storedToken;

    debugPrint('TokenStore: 初始化时从本地存储加载token: $storedToken');
    debugPrint('TokenStore: 当前内存中的token: ${_token.value}');
  }

  /// 更新访问令牌（常用于用于令牌过期后刷新）
  void updateToken(String newToken) {
    debugPrint('TokenStore: 开始更新token');
    debugPrint('TokenStore: 新token值: $newToken');

    _token.value = newToken;
    _storage.write(_tokenKey, newToken);

    debugPrint('TokenStore: token已更新到内存: ${_token.value}');
    debugPrint('TokenStore: token已保存到本地存储');

    // 验证保存是否成功
    final savedToken = _storage.read<String?>(_tokenKey);
    debugPrint('TokenStore: 验证本地存储中的token: $savedToken');
  }

  /// 清除所有令牌（退出登录时使用）
  void clearTokens() {
    // 清空内存状态
    _token.value = '';

    // 清除本地存储
    _storage.remove(_tokenKey);
  }
}
