/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-26 13:43:55
 * @LastEditTime: 2025-09-26 14:02:14
 * @FilePath: /mu-music/lib/common/utils/utils.dart
 * @Description: 工具
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

/// 数字单位格式化工具
/// 将数字转换为带最大单位的简洁表示（如 12312312312 → "123.1亿"）
String formatNumberWithUnit(num number) {
  // 定义单位和对应的阈值（从大到小）
  final List<Map<String, dynamic>> units = [
    {'unit': '万亿', 'value': 1000000000000}, // 10^12
    {'unit': '亿', 'value': 100000000}, // 10^8
    {'unit': '万', 'value': 10000}, // 10^4
    {'unit': '千', 'value': 1000}, // 10^3
  ];

  // 处理0的情况
  if (number == 0) {
    return "0";
  }

  // 寻找最大匹配的单位
  for (var unit in units) {
    final unitValue = unit['value']!;
    final unitName = unit['unit']!;

    if (number.abs() >= unitValue) {
      // 计算转换后的值（保留一位小数）
      final formatted = (number / unitValue).toStringAsFixed(1);
      // 去除末尾的.0（如 2.0千 → 2千）
      return formatted.endsWith('.0')
          ? "${formatted.split('.')[0]}$unitName"
          : "$formatted$unitName";
    }
  }

  // 小于1000的数字直接显示
  return number.toString();
}

/// 时间戳转换工具类
class TimestampDateConverter {
  /// 将时间戳转换为年月日字符串
  /// [timestamp]：时间戳（支持毫秒或秒，自动识别）
  /// [format]：日期格式（默认：yyyy-MM-dd，可选：yyyy年MM月dd日、MM/dd/yyyy等）
  static String convert(
    num timestamp, {
    String format = 'yyyy-MM-dd',
  }) {
    try {
      // 处理时间戳单位（如果小于1e12，视为秒级，否则视为毫秒级）
      final int milliseconds = timestamp < 1000000000000
          ? (timestamp * 1000).toInt() // 秒 → 毫秒
          : timestamp.toInt();

      // 转换为DateTime
      final DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(milliseconds);

      // 格式化日期
      return DateFormat(format).format(dateTime);
    } catch (e) {
      debugPrint('时间戳转换失败：$e');
      return '无效时间';
    }
  }
}
