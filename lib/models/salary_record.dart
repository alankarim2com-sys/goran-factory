import 'package:cloud_firestore/cloud_firestore.dart';

class SalaryRecord {
  final String id;
  final String employeeId;
  final DateTime date; // The date for which salary is calculated
  final double dailyEarnings;
  final double monthlyEarnings;
  final int fullDaysCount;
  final int halfDaysCount;
  final double totalEarnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalaryRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.dailyEarnings,
    required this.monthlyEarnings,
    required this.fullDaysCount,
    required this.halfDaysCount,
    required this.totalEarnings,
    required this.createdAt,
    required this.updatedAt,
  });

  // گۆڕینی حسابی مووچە بۆ داتا بۆ هەڵگرتن.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date,
      'dailyEarnings': dailyEarnings,
      'monthlyEarnings': monthlyEarnings,
      'fullDaysCount': fullDaysCount,
      'halfDaysCount': halfDaysCount,
      'totalEarnings': totalEarnings,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // دروستکردنەوەی حسابی مووچە لە داتای هەڵگیراو.
  factory SalaryRecord.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        if (value.toString().contains('Timestamp')) {
          return (value as dynamic).toDate();
        }
      } catch (e) {
        // لە کاتی هەڵەی بەروار، بەرواری ئێستا بەکاردهێنین.
      }
      return DateTime.now();
    }

    return SalaryRecord(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: parseDate(json['date']),
      dailyEarnings: (json['dailyEarnings'] ?? 0).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] ?? 0).toDouble(),
      fullDaysCount: json['fullDaysCount'] ?? 0,
      halfDaysCount: json['halfDaysCount'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  // دروستکردنی وەشانێکی نوێ بە گۆڕینی خانە پێویستەکان.
  SalaryRecord copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    double? dailyEarnings,
    double? monthlyEarnings,
    int? fullDaysCount,
    int? halfDaysCount,
    double? totalEarnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalaryRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      dailyEarnings: dailyEarnings ?? this.dailyEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      fullDaysCount: fullDaysCount ?? this.fullDaysCount,
      halfDaysCount: halfDaysCount ?? this.halfDaysCount,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
