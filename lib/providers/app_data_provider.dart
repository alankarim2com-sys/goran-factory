import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goran/models/index.dart';

// کورتەی حسابی مانگانەی هەر کرێکار.
class EmployeeMonthSummary {
  final Employee employee;
  final int fullDays;
  final int halfDays;
  final int absentDays;
  final double workedDays;
  final double earned;
  final double paid;

  const EmployeeMonthSummary({
    required this.employee,
    required this.fullDays,
    required this.halfDays,
    required this.absentDays,
    required this.workedDays,
    required this.earned,
    required this.paid,
  });

  double get remaining => earned - paid;
}

// ناوەندی هەموو داتا و کارەکانی ئەپەکە.
// داتا لە SharedPreferences ـدا پاشەکەوت دەکرێت بۆ ئەوەی بە داخستنی ئەپەکە ون نەبێت.
class AppDataProvider extends ChangeNotifier {
  static const _employeesKey = 'local_employees';
  static const _attendanceKey = 'local_attendance';
  static const _paymentsKey = 'local_payments';

  final List<Employee> _employees = [];
  final List<Attendance> _attendance = [];
  final List<PaymentRecord> _payments = [];
  bool _isReady = false;
  String _search = '';
  DateTime _reportMonth = DateTime(DateTime.now().year, DateTime.now().month);

  AppDataProvider() {
    _load();
  }

  bool get isReady => _isReady;
  DateTime get reportMonth => _reportMonth;
  List<Employee> get employees {
    final filtered =
        _employees.where((employee) {
          final query = _search.trim().toLowerCase();
          return query.isEmpty ||
              employee.name.toLowerCase().contains(query) ||
              employee.phoneNumber.toLowerCase().contains(query) ||
              employee.position.toLowerCase().contains(query);
        }).toList();
    return List.unmodifiable(filtered);
  }

  List<Employee> get allEmployees => List.unmodifiable(_employees);
  List<PaymentRecord> get payments => List.unmodifiable(_payments);

  Future<void> _load() async {
    // خوێندنەوەی کرێکار، ئامادەبوون و پارەدانەکانی پێشوو لە local storage.
    final prefs = await SharedPreferences.getInstance();
    _readEmployees(prefs.getString(_employeesKey));
    _readAttendance(prefs.getString(_attendanceKey));
    _readPayments(prefs.getString(_paymentsKey));
    _isReady = true;
    notifyListeners();
  }

  void _readEmployees(String? raw) {
    // گۆڕینی داتای هەڵگیراو بۆ لیستی کرێکارەکان.
    if (raw == null) return;
    try {
      final items = jsonDecode(raw) as List<dynamic>;
      _employees
        ..clear()
        ..addAll(
          items.map(
            (item) => _employeeFromLocalJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          ),
        );
    } catch (_) {
      _employees.clear();
    }
  }

  void _readAttendance(String? raw) {
    // گۆڕینی داتای هەڵگیراو بۆ تۆمارەکانی ئامادەبوون.
    if (raw == null) return;
    try {
      final items = jsonDecode(raw) as List<dynamic>;
      _attendance
        ..clear()
        ..addAll(
          items.map(
            (item) => Attendance.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          ),
        );
    } catch (_) {
      _attendance.clear();
    }
  }

  void _readPayments(String? raw) {
    // گۆڕینی داتای هەڵگیراو بۆ تۆمارەکانی پارەدان.
    if (raw == null) return;
    try {
      final items = jsonDecode(raw) as List<dynamic>;
      _payments
        ..clear()
        ..addAll(
          items.map(
            (item) => PaymentRecord.fromLocalJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          ),
        );
    } catch (_) {
      _payments.clear();
    }
  }

  Employee _employeeFromLocalJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    return Employee(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      dailySalary: (json['dailySalary'] as num?)?.toDouble() ?? 0,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> _employeeToLocalJson(Employee employee) => {
    'id': employee.id,
    'name': employee.name,
    'position': employee.position,
    'dailySalary': employee.dailySalary,
    'phoneNumber': employee.phoneNumber,
    'createdAt': employee.createdAt.toIso8601String(),
    'updatedAt': employee.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _attendanceToLocalJson(Attendance record) => {
    'id': record.id,
    'employeeId': record.employeeId,
    'date': record.date.toIso8601String(),
    'type': record.type.index,
    'earnedAmount': record.earnedAmount,
    'notes': record.notes,
    'createdAt': record.createdAt.toIso8601String(),
    'updatedAt': record.updatedAt.toIso8601String(),
  };

  Future<void> _save() async {
    // پاشەکەوتکردنی هەموو گۆڕانکارییەکان لەسەر ئامێر.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _employeesKey,
      jsonEncode(_employees.map(_employeeToLocalJson).toList()),
    );
    await prefs.setString(
      _attendanceKey,
      jsonEncode(_attendance.map(_attendanceToLocalJson).toList()),
    );
    await prefs.setString(
      _paymentsKey,
      jsonEncode(_payments.map((item) => item.toLocalJson()).toList()),
    );
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  void setSearch(String value) {
    // فلتەرکردنی لیستی کرێکاران بە ناو، پیشە یان ژمارەی مۆبایل.
    _search = value;
    notifyListeners();
  }

  void setReportMonth(DateTime value) {
    // دیاریکردنی ئەو مانگەی کە لە ڕاپۆرتدا دەبینرێت.
    _reportMonth = DateTime(value.year, value.month);
    notifyListeners();
  }

  Future<void> addEmployee({
    // زیادکردنی کرێکارێکی نوێ بە زانیارییە سەرەکییەکانی.
    required String name,
    required String position,
    required double dailySalary,
    required String phoneNumber,
  }) async {
    final now = DateTime.now();
    _employees.insert(
      0,
      Employee(
        id: '${now.microsecondsSinceEpoch}',
        name: name.trim(),
        position: position.trim(),
        dailySalary: dailySalary,
        phoneNumber: phoneNumber.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );
    _changed();
  }

  Future<void> updateEmployee({
    // نوێکردنەوەی زانیاری کرێکارێکی پێشوو.
    required String employeeId,
    required String name,
    required String position,
    required double dailySalary,
    required String phoneNumber,
  }) async {
    final index = _employees.indexWhere((item) => item.id == employeeId);
    if (index == -1) return;
    final current = _employees[index];
    _employees[index] = current.copyWith(
      name: name.trim(),
      position: position.trim(),
      dailySalary: dailySalary,
      phoneNumber: phoneNumber.trim(),
      updatedAt: DateTime.now(),
    );
    _changed();
  }

  Future<void> deleteEmployee(String employeeId) async {
    // سڕینەوەی کرێکار و هەموو تۆمارە پەیوەندیدارەکانی.
    _employees.removeWhere((item) => item.id == employeeId);
    _attendance.removeWhere((item) => item.employeeId == employeeId);
    _payments.removeWhere((item) => item.employeeId == employeeId);
    _changed();
  }

  Attendance? attendanceFor(String employeeId, DateTime date) {
    for (final item in _attendance) {
      if (item.employeeId == employeeId && _sameDay(item.date, date)) {
        return item;
      }
    }
    return null;
  }

  Future<void> setAttendance({
    // دانانی دۆخی کرێکار بۆ ڕۆژێکی دیاریکراو.
    required String employeeId,
    required DateTime date,
    required AttendanceType type,
    String? notes,
  }) async {
    final employee = _employeeById(employeeId);
    if (employee == null) return;
    final old = attendanceFor(employeeId, date);
    final now = DateTime.now();
    final record = Attendance(
      id: old?.id ?? '${employeeId}_${_dateKey(date)}',
      employeeId: employeeId,
      date: DateTime(date.year, date.month, date.day),
      type: type,
      earnedAmount: employee.dailySalary * type.salaryPercentage,
      notes: notes,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
    );
    if (old == null) {
      _attendance.add(record);
    } else {
      final index = _attendance.indexOf(old);
      _attendance[index] = record;
    }
    _changed();
  }

  Future<void> addPayment({
    // تۆمارکردنی بڕی پارەی دراو بۆ حسابی مانگانەی کرێکار.
    required String employeeId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    _payments.add(
      PaymentRecord(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        employeeId: employeeId,
        amount: amount,
        date: date,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
      ),
    );
    _changed();
  }

  List<EmployeeMonthSummary> get monthSummaries {
    // کۆکردنەوەی ڕۆژەکان، شایستەیی، پارەدراو و پارەی ماوە بۆ مانگ.
    return _employees.map((employee) {
      final records = _attendance.where(
        (record) =>
            record.employeeId == employee.id &&
            record.date.year == _reportMonth.year &&
            record.date.month == _reportMonth.month,
      );
      var full = 0;
      var half = 0;
      var absent = 0;
      var earned = 0.0;
      for (final record in records) {
        earned += record.earnedAmount;
        if (record.type == AttendanceType.fullDay) full++;
        if (record.type == AttendanceType.halfDay) half++;
        if (record.type == AttendanceType.absent) absent++;
      }
      final paid = _payments
          .where(
            (payment) =>
                payment.employeeId == employee.id &&
                payment.date.year == _reportMonth.year &&
                payment.date.month == _reportMonth.month,
          )
          .fold<double>(0, (sum, payment) => sum + payment.amount);
      return EmployeeMonthSummary(
        employee: employee,
        fullDays: full,
        halfDays: half,
        absentDays: absent,
        workedDays: full + half * 0.5,
        earned: earned,
        paid: paid,
      );
    }).toList();
  }

  double get totalEarned =>
      monthSummaries.fold<double>(0, (sum, item) => sum + item.earned);
  double get totalPaid =>
      monthSummaries.fold<double>(0, (sum, item) => sum + item.paid);
  double get totalRemaining => totalEarned - totalPaid;

  int get todayPresentCount {
    final now = DateTime.now();
    return _employees.where((employee) {
      final record = attendanceFor(employee.id, now);
      return record != null && record.type != AttendanceType.absent;
    }).length;
  }

  int get todayMarkedCount {
    final now = DateTime.now();
    return _employees
        .where((employee) => attendanceFor(employee.id, now) != null)
        .length;
  }

  Employee? _employeeById(String id) {
    for (final employee in _employees) {
      if (employee.id == id) return employee;
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
