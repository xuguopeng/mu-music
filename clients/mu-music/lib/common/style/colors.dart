/*
 * @Author: xuguopeng
 * @Date: 2024-09-13 10:50:42
 * @FilePath: /mu-music/lib/common/style/colors.dart
 * @Description: 颜色控制
 */

import 'dart:ui';

class AppColors {
  static bool _dark = true;
  static const Color brandRed = Color.fromRGBO(254, 121, 113, 1);

  static bool get isDark => _dark;

  static void setDark(bool value) {
    _dark = value;
  }

  /// APP整体背景颜色
  static Color get appBg =>
      _dark ? const Color.fromRGBO(40, 39, 44, 1) : const Color(0xFFF6F7FB);

  /// 底部bar 颜色
  static Color get navigationBg =>
      _dark ? const Color.fromRGBO(28, 27, 32, 1) : const Color(0xFFFFFFFF);

  /// 边框颜色
  static Color get borderColor =>
      _dark ? const Color.fromRGBO(50, 48, 58, 1) : const Color(0xFFE5E8F0);

  /// 主文本
  static Color get primaryText => _dark
      ? const Color.fromARGB(255, 255, 255, 255)
      : const Color(0xFF171923);

  /// 次文本
  static Color get secondaryText => _dark
      ? const Color.fromRGBO(255, 255, 255, 0.5)
      : const Color(0xFF687083);

  /// btn 主颜色
  static Color get primaryBtn => brandRed;

  /// btn 背景颜色
  static Color get bgBtn => const Color.fromRGBO(254, 121, 113, 0.16);

  /// 表面颜色（用于卡片、输入框等控件背景）
  static Color get surface =>
      _dark ? const Color.fromRGBO(55, 55, 60, 1) : const Color(0xFFF0F2F7);
}
