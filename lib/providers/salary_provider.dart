import 'package:flutter/material.dart';
import 'package:goran/models/index.dart';
import 'package:goran/services/index.dart';

class SalaryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  SalaryRecord? _currentMonthSalary;
  List<SalaryRecord> _salaryHistory = [];
  bool _isLoading = false;
  String? _error;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  SalaryRecord? get currentMonthSalary => _currentMonthSalary;
  List<SalaryRecord> get salaryHistory => _salaryHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  /// دەستپێکردن و گوێگرتن لە حسابی مووچەی مانگی ئێستا.
  void initializeSalaryStream({
    required String employeeId,
    int? year,
    int? month,
  }) {
    final _year = year ?? DateTime.now().year;
    final _month = month ?? DateTime.now().month;

    _firestoreService
        .getSalaryRecordStream(
          employeeId: employeeId,
          year: _year,
          month: _month,
        )
        .listen(
          (record) {
            _currentMonthSalary = record;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  /// وەرگرتنی مێژووی مووچەی کرێکارێک.
  Stream<List<SalaryRecord>> getEmployeeSalaryHistoryStream(String employeeId) {
    return _firestoreService.getEmployeeSalaryHistoryStream(employeeId);
  }

  /// وەرگرتنی حسابی مووچە بۆ ماوەیەکی دیاریکراو.
  Stream<List<SalaryRecord>> getSalaryHistoryStream({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestoreService.getSalaryHistoryStream(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// نوێکردنەوەی مانگ و ساڵی هەڵبژێردراو.
  void changeMonth({required int year, required int month}) {
    _selectedYear = year;
    _selectedMonth = month;
    notifyListeners();
  }

  /// پاککردنەوەی پەیامی هەڵە.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// ڕێکخستنی نیشاندانی بڕی پارە.
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
