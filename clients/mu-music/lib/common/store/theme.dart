/*
 * @Author: Codex
 * @Date: 2026-07-04
 * @FilePath: /mu-music/lib/common/store/theme.dart
 * @Description: 应用主题状态
 */
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mu_music/common/style/colors.dart';

class ThemeStore extends GetxController {
  static const _themeModeKey = 'app_theme_mode';

  final _storage = GetStorage();
  final RxBool _darkMode = true.obs;

  bool get darkMode => _darkMode.value;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<String>(_themeModeKey);
    _darkMode.value = stored != 'light';
    AppColors.setDark(_darkMode.value);
  }

  void toggleTheme() {
    setDarkMode(!_darkMode.value);
  }

  void setDarkMode(bool value) {
    _darkMode.value = value;
    AppColors.setDark(value);
    _storage.write(_themeModeKey, value ? 'dark' : 'light');
    update();
  }
}
