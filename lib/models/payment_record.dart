class PaymentRecord {
  // تۆماری هەر پارەیەک کە بۆ کرێکارێک دراوە.
  final String id;
  final String employeeId;
  final double amount;
  final DateTime date;
  final String? note;

  PaymentRecord({
    required this.id,
    required this.employeeId,
    required this.amount,
    required this.date,
    this.note,
  });

  // گۆڕینی تۆمار بۆ شێوەیەک کە بتوانرێت لە local storage هەڵگیرێت.
  Map<String, dynamic> toLocalJson() => {
    'id': id,
    'employeeId': employeeId,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
  };

  // دروستکردنەوەی تۆمار لە داتای پاشەکەوتکراو.
  factory PaymentRecord.fromLocalJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      note: json['note']?.toString(),
    );
  }
}
