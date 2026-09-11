import 'package:flutter/material.dart';
import 'package:goran/models/index.dart';
import 'package:goran/services/index.dart';

class EmployeeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// دەستپێکردن و گوێگرتن لە stream ـی کرێکاران.
  void initializeEmployeeStream() {
    _firestoreService.getAllEmployeesStream().listen(
      (employees) {
        _employees = employees;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  /// زیادکردنی کرێکاری نوێ.
  Future<bool> addEmployee({
    required String name,
    required String position,
    required double dailySalary,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final employee = await _firestoreService.addEmployee(
        name: name,
        position: position,
        dailySalary: dailySalary,
        phoneNumber: phoneNumber,
      );

      _employees.insert(0, employee);
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

  /// نوێکردنەوەی زانیاری کرێکار.
  Future<bool> updateEmployee({
    required String employeeId,
    required String name,
    required String position,
    required double dailySalary,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final employee = Employee(
        id: employeeId,
        name: name,
        position: position,
        dailySalary: dailySalary,
        phoneNumber: phoneNumber,
        createdAt: _selectedEmployee?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateEmployee(employee);

      final index = _employees.indexWhere((e) => e.id == employeeId);
      if (index != -1) {
        _employees[index] = employee;
        _selectedEmployee = employee;
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

  /// سڕینەوەی کرێکار.
  Future<bool> deleteEmployee(String employeeId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteEmployee(employeeId);

      _employees.removeWhere((e) => e.id == employeeId);
      if (_selectedEmployee?.id == employeeId) {
        _selectedEmployee = null;
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

  /// هەڵبژاردنی کرێکارێک.
  void selectEmployee(Employee employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  /// لابردنی هەڵبژاردنی کرێکار.
  void deselectEmployee() {
    _selectedEmployee = null;
    notifyListeners();
  }

  /// پاککردنەوەی پەیامی هەڵە.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
