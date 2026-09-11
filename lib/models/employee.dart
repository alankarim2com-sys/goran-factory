
class Employee {
  final String id;
  final String name;
  final String position;
  final double dailySalary;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.dailySalary,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  // گۆڕینی زانیاری کرێکار بۆ داتا بۆ هەڵگرتن.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'dailySalary': dailySalary,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // دروستکردنەوەی کرێکار لە داتای هەڵگیراو.
  factory Employee.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      // مامەڵەکردن لەگەڵ بەرواری Firestore ئەگەر هەبوو.
      try {
        if (value.toString().contains('Timestamp')) {
          return (value as dynamic).toDate();
        }
      } catch (e) {
        // لە کاتی هەڵەی خوێندنەوەی بەروار، بەرواری ئێستا بەکاردهێنین.
      }
      return DateTime.now();
    }

    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      dailySalary: (json['dailySalary'] ?? 0).toDouble(),
      phoneNumber: json['phoneNumber'] ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  // دروستکردنی وەشانێکی نوێ بە گۆڕینی خانە پێویستەکان.
  Employee copyWith({
    String? id,
    String? name,
    String? position,
    double? dailySalary,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      dailySalary: dailySalary ?? this.dailySalary,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
