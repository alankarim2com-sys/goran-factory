import 'package:intl/intl.dart';

final _moneyFormatter = NumberFormat('#,##0', 'en_US');

// نیشاندانی بڕی پارە بە دیناری عێراقی و ژمارەی ڕێکخراو.
String money(double amount) =>
    '${_moneyFormatter.format(amount.round())} دینار';

// نیشاندانی ڕۆژە کارکراوەکان بەبێ خاڵی زیادە.
String number(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

// نیشاندانی بەروار بە شێوەی ڕۆژ / مانگ / ساڵ.
String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';

// ناوی مانگەکان بە کوردی بۆ ڕاپۆرتی مانگانە.
String monthLabel(DateTime date) {
  const months = [
    'کانوونی دووەم',
    'شوبات',
    'ئازار',
    'نیسان',
    'ئایار',
    'حوزەیران',
    'تەممووز',
    'ئاب',
    'ئەیلول',
    'تشرینی یەکەم',
    'تشرینی دووەم',
    'کانوونی یەکەم',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
