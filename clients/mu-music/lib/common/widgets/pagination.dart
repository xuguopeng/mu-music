/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-10-01 23:40:00
 * @FilePath: /mu-music/lib/common/widgets/pagination.dart
 * @Description: 通用分页组件（固定每页20条，可选页码）
 */
import 'package:flutter/material.dart';
import 'package:mu_music/common/index.dart';

class Pagination extends StatelessWidget {
  final int currentPage; // 1-based 当前页
  final int totalItems; // 总条数
  final int pageSize; // 每页数量，默认20
  final ValueChanged<int> onPageChanged; // 参数为1-based页码

  Pagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    this.pageSize = 20,
    required this.onPageChanged,
  });

  int get totalPages {
    if (totalItems <= 0) return 1;
    return (totalItems + pageSize - 1) ~/ pageSize;
  }

  List<int> _visiblePages() {
    final int tp = totalPages;
    if (tp <= 5) {
      return List<int>.generate(tp, (i) => i + 1);
    }

    // 显示当前页前后各1页，首尾保留
    final List<int> pages = <int>[1];

    if (currentPage > 3) {
      pages.add(-1); // 省略号标记
    }

    // 当前页及其前后页
    final int start = (currentPage - 1).clamp(2, tp - 1);
    final int end = (currentPage + 1).clamp(2, tp - 1);
    for (int p = start; p <= end; p++) {
      if (!pages.contains(p)) pages.add(p);
    }

    if (currentPage < tp - 2) {
      pages.add(-1); // 省略号标记
    }

    if (!pages.contains(tp)) pages.add(tp);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final int tp = totalPages;
    final List<int> pages = _visiblePages();

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.navigationBg.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 上一页按钮
          _NavButton(
            icon: Icons.chevron_left,
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            isEnabled: currentPage > 1,
          ),

          SizedBox(width: 16),

          // 页码按钮区域
          Row(
            children: [
              for (int i = 0; i < pages.length; i++) ...[
                if (i > 0) SizedBox(width: 8),
                if (pages[i] == -1)
                  // 省略号
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '...',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  _PageChip(
                    page: pages[i],
                    active: pages[i] == currentPage,
                    onTap: () => onPageChanged(pages[i]),
                  ),
              ],
            ],
          ),

          SizedBox(width: 16),

          // 下一页按钮
          _NavButton(
            icon: Icons.chevron_right,
            onPressed:
                currentPage < tp ? () => onPageChanged(currentPage + 1) : null,
            isEnabled: currentPage < tp,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;

  _NavButton({
    required this.icon,
    this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.bgBtn.withValues(alpha: 0.8)
            : AppColors.bgBtn.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isEnabled
              ? AppColors.borderColor.withValues(alpha: 0.5)
              : AppColors.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Icon(
              icon,
              color:
                  isEnabled ? AppColors.primaryText : AppColors.secondaryText,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _PageChip extends StatelessWidget {
  final int page;
  final bool active;
  final VoidCallback onTap;

  _PageChip({
    required this.page,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? Colors.transparent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active ? AppColors.primaryBtn : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              '$page',
              style: TextStyle(
                color: active ? AppColors.primaryBtn : AppColors.primaryText,
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
