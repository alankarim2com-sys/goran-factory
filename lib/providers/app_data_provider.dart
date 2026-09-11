import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
// ئەم وەشانە ڕاستەوخۆ بەستراوەتەوە بە Firebase Firestore بۆ هاوکاتکردنی داتا لەنێوان چەند ئامێرێکدا.
class AppDataProvider extends ChangeNotifier {
  final List<Employee> _employees = [];
  final List<Attendance> _attendance = [];
  final List<PaymentRecord> _payments = [];
  bool _isReady = false;
  String _search = '';
  DateTime _reportMonth = DateTime(DateTime.now().year, DateTime.now().month);

  AppDataProvider() {
    _loadFromFirestore();
  }

  bool get isReady => _isReady;
  DateTime get reportMonth => _reportMonth;
  
  List<Employee> get employees {
    final filtered = _employees.where((employee) {
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

  Future<void> _loadFromFirestore() async {
    try {
      // گوێگرتن لە گۆڕانکارییەکانی کرێکاران بەشێوەی ڕاستەوخۆ
      FirebaseFirestore.instance.collection('employees').snapshots().listen((snapshot) {
        _employees.clear();
        for (var doc in snapshot.docs) {
          _employees.add(Employee.fromJson(doc.data()));
        }
        _isReady = true;
        notifyListeners();
      });

      // گوێگرتن لە گۆڕانکارییەکانی ئامادەبوون
      FirebaseFirestore.instance.collection('attendance').snapshots().listen((snapshot) {
        _attendance.clear();
        for (var doc in snapshot.docs) {
          _attendance.add(Attendance.fromJson(doc.data()));
        }
        notifyListeners();
      });

      // گوێگرتن لە گۆڕانکارییەکانی پارەدان
      FirebaseFirestore.instance.collection('salary_records').snapshots().listen((snapshot) {
        _payments.clear();
        for (var doc in snapshot.docs) {
          _payments.add(PaymentRecord.fromLocalJson(doc.data()));
        }
        notifyListeners();
      });
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setReportMonth(DateTime value) {
    _reportMonth = DateTime(value.year, value.month);
    notifyListeners();
  }

  Future<void> addEmployee({
    required String name,
    required String position,
    required double dailySalary,
    required String phoneNumber,
  }) async {
    final now = DateTime.now();
    final employee = Employee(
      id: '${now.microsecondsSinceEpoch}',
      name: name.trim(),
      position: position.trim(),
      dailySalary: dailySalary,
      phoneNumber: phoneNumber.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await FirebaseFirestore.instance.collection('employees').doc(employee.id).set(employee.toJson());
  }

  Future<void> updateEmployee({
    required String employeeId,
    required String name,
    required String position,
    required double dailySalary,
    required String phoneNumber,
  }) async {
    final index = _employees.indexWhere((item) => item.id == employeeId);
    if (index == -1) return;
    final current = _employees[index];
    final updated = current.copyWith(
      name: name.trim(),
      position: position.trim(),
      dailySalary: dailySalary,
      phoneNumber: phoneNumber.trim(),
      updatedAt: DateTime.now(),
    );
    await FirebaseFirestore.instance.collection('employees').doc(employeeId).update(updated.toJson());
  }

  Future<void> deleteEmployee(String employeeId) async {
    await FirebaseFirestore.instance.collection('employees').doc(employeeId).delete();
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
    await FirebaseFirestore.instance.collection('attendance').doc(record.id).set(record.toJson());
  }

  Future<void> addPayment({
    required String employeeId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final payment = PaymentRecord(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      employeeId: employeeId,
      amount: amount,
      date: date,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
    await FirebaseFirestore.instance.collection('salary_records').doc(payment.id).set(payment.toLocalJson());
  }

  List<EmployeeMonthSummary> get monthSummaries {
    return _employees.map((employee) {
      final records = _attendance.where((record) =>
          record.employeeId == employee.id &&
          record.date.year == _reportMonth.year &&
          record.date.month == _reportMonth.month);
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
          .where((payment) =>
              payment.employeeId == employee.id &&
              payment.date.year == _reportMonth.year &&
              payment.date.month == _reportMonth.month)
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

  double get totalEarned => monthSummaries.fold<double>(0, (sum, item) => sum + item.earned);
  double get totalPaid => monthSummaries.fold<double>(0, (sum, item) => sum + item.paid);
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
    return _employees.where((employee) => attendanceFor(employee.id, now) != null).length;
  }

  Employee? _employeeById(String id) {
    for (final employee in _employees) {
      if (employee.id == id) return employee;
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
