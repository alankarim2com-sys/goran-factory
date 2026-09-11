import 'package:flutter/material.dart';
import 'package:goran/models/index.dart';
import 'package:goran/services/index.dart';

class AttendanceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Attendance> _attendanceRecords = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<Attendance> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  /// دەستپێکردن و گوێگرتن لە ئامادەبوونی بەروارێکی دیاریکراو.
  void initializeAttendanceStream(DateTime date) {
    _selectedDate = date;
    _firestoreService
        .getAttendanceForDateStream(date)
        .listen(
          (records) {
            _attendanceRecords = records;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  /// وەرگرتنی stream ـی مێژووی ئامادەبوونی کرێکار.
  Stream<List<Attendance>> getEmployeeAttendanceStream({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestoreService.getEmployeeAttendanceStream(
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// تۆمارکردنی ئامادەبوون.
  Future<bool> markAttendance({
    required String employeeId,
    required DateTime date,
    required AttendanceType type,
    required double dailySalary,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.markAttendance(
        employeeId: employeeId,
        date: date,
        type: type,
        dailySalary: dailySalary,
        notes: notes,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// دەستکاریکردنی تۆماری ئامادەبوون.
  Future<bool> updateAttendance(Attendance attendance) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateAttendance(attendance);

      final index = _attendanceRecords.indexWhere((a) => a.id == attendance.id);
      if (index != -1) {
        _attendanceRecords[index] = attendance;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// سڕینەوەی تۆماری ئامادەبوون.
  Future<bool> deleteAttendance(String attendanceId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteAttendance(attendanceId);
      _attendanceRecords.removeWhere((a) => a.id == attendanceId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// گۆڕینی بەرواری هەڵبژێردراو.
  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    initializeAttendanceStream(newDate);
  }

  /// پاککردنەوەی پەیامی هەڵە.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
