
enum AttendanceType {
  fullDay, // کارکردنی تەواوی ڕۆژ و وەرگرتنی ١٠٠٪ی کرێ.
  halfDay, // کارکردنی نیوەی ڕۆژ و وەرگرتنی ٥٠٪ی کرێ.
  absent; // غایببوون و وەرنەگرتنی کرێ بۆ ئەو ڕۆژە.

  double get salaryPercentage {
    switch (this) {
      case AttendanceType.fullDay:
        return 1.0;
      case AttendanceType.halfDay:
        return 0.5;
      case AttendanceType.absent:
        return 0.0;
    }
  }

  String get displayName {
    switch (this) {
      case AttendanceType.fullDay:
        return 'ڕۆژی تەواو';
      case AttendanceType.halfDay:
        return 'نیوەی ڕۆژ';
      case AttendanceType.absent:
        return 'غایب';
    }
  }
}

class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final AttendanceType type;
  final double earnedAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.type,
    required this.earnedAmount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // گۆڕینی تۆمار بۆ داتا بۆ هەڵگرتن یان ناردن.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date,
      'type': type.index,
      'earnedAmount': earnedAmount,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // دروستکردنەوەی تۆمار لە داتای هەڵگیراو.
  factory Attendance.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        if (value.toString().contains('Timestamp')) {
          return (value as dynamic).toDate();
        }
      } catch (e) {
        // ئەگەر بەروار نەخوێندرایەوە، بەرواری ئێستا بەکاردهێنین.
      }
      return DateTime.now();
    }

    return Attendance(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: parseDate(json['date']),
      type: AttendanceType.values[json['type'] ?? 0],
      earnedAmount: (json['earnedAmount'] ?? 0).toDouble(),
      notes: json['notes'],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  // دروستکردنی وەشانێکی نوێ بە گۆڕینی تەنها خانەی پێویست.
  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    AttendanceType? type,
    double? earnedAmount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      type: type ?? this.type,
      earnedAmount: earnedAmount ?? this.earnedAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
