/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-26 10:19:22
 * @LastEditTime: 2025-09-26 12:27:38
 * @FilePath: /mu-music/lib/common/store/user.dart
 * @Description: 用户信息
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// 用户模型（简单示例）
class User {
  final String nickname;
  final String avatarUrl;
  final int userId;

  User({
    required this.nickname,
    required this.avatarUrl,
    required this.userId,
  });

  // 将对象转为 Map（用于存储）
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'userId': userId,
    };
  }

  // 从 Map 解析为对象（用于读取）
  static User fromJson(Map<String, dynamic> json) {
    return User(
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }
}

// 持久化 Store（状态管理 + 本地存储）
class UserStore extends GetxController {
  // 1. 初始化 get_storage 实例
  final _storage = GetStorage();

  // 2. 响应式状态（使用 Rx 包装，支持响应式更新）
  final Rx<User?> _user = Rx<User?>(null);

  // 对外暴露的状态读取方法
  User? get user => _user.value;
  bool get isLogin => _user.value != null;

  // 3. 初始化时从本地读取状态
  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  // 从 get_storage 读取并恢复状态
  void _loadUserFromStorage() {
    final json = _storage.read<Map<String, dynamic>>('user_info');
    if (json != null) {
      _user.value = User.fromJson(json);
    }
  }

  // 4. 状态修改方法（自动同步到本地存储）
  // 登录/保存用户信息
  void login(User newUser) {
    _user.value = newUser;
    _storage.write('user_info', newUser.toJson()); // 持久化到本地
  }

  // 更新用户信息
  void updateUser({String? nickname, String? avatarUrl, int? userId}) {
    if (_user.value == null) return;

    _user.value = User(
      nickname: nickname ?? _user.value!.nickname,
      avatarUrl: avatarUrl ?? _user.value!.avatarUrl,
      userId: userId ?? _user.value!.userId,
    );
    _storage.write('user_info', _user.value!.toJson()); // 同步更新本地
  }

  // 退出登录（清除状态）
  void logout() {
    _user.value = null;
    _storage.remove('user_info'); // 清除本地存储
  }
}
