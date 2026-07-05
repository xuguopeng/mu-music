/*
 * @Author: Codex
 * @Date: 2026-07-04
 * @FilePath: /mu-music/lib/common/widgets/theme_toggle_button.dart
 * @Description: 黑白主题切换按钮
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';

class ThemeToggleButton extends StatelessWidget {
  ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeStore>(
      builder: (themeStore) {
        return Tooltip(
          message: themeStore.darkMode ? '切换白色主题' : '切换黑色主题',
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: themeStore.toggleTheme,
            child: Container(
              height: 34,
              padding: EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: AppColors.bgBtn.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    themeStore.darkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    size: 17,
                    color: AppColors.primaryBtn,
                  ),
                  SizedBox(width: 6),
                  Text(
                    themeStore.darkMode ? '黑色' : '白色',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
