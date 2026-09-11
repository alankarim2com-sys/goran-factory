import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goran/models/index.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String employeesCollection = 'employees';
  static const String attendanceCollection = 'attendance';
  static const String salaryCollection = 'salary_records';

  // ==================== کارەکانی کرێکاران ====================

  /// زیادکردنی کرێکاری نوێ.
  Future<Employee> addEmployee({
    required String name,
    required String position,
    required double dailySalary,
    required String phoneNumber,
  }) async {
    try {
      final String id = const Uuid().v4();
      final now = DateTime.now();

      final employee = Employee(
        id: id,
        name: name,
        position: position,
        dailySalary: dailySalary,
        phoneNumber: phoneNumber,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(employeesCollection)
          .doc(id)
          .set(employee.toJson());

      return employee;
    } catch (e) {
      print('Error adding employee: $e');
      rethrow;
    }
  }

  /// نوێکردنەوەی کرێکاری پێشوو.
  Future<void> updateEmployee(Employee employee) async {
    try {
      await _firestore
          .collection(employeesCollection)
          .doc(employee.id)
          .update(employee.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      print('Error updating employee: $e');
      rethrow;
    }
  }

  /// سڕینەوەی کرێکار و تۆمارە پەیوەندیدارەکانی.
  Future<void> deleteEmployee(String employeeId) async {
    try {
      // سڕینەوەی خودی کرێکار.
      await _firestore.collection(employeesCollection).doc(employeeId).delete();

      // سڕینەوەی هەموو تۆمارەکانی ئامادەبوونی ئەو کرێکارە.
      final attendanceQuery =
          await _firestore
              .collection(attendanceCollection)
              .where('employeeId', isEqualTo: employeeId)
              .get();

      for (var doc in attendanceQuery.docs) {
        await doc.reference.delete();
      }

      // سڕینەوەی هەموو حسابەکانی مووچەی ئەو کرێکارە.
      final salaryQuery =
          await _firestore
              .collection(salaryCollection)
              .where('employeeId', isEqualTo: employeeId)
              .get();

      for (var doc in salaryQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting employee: $e');
      rethrow;
    }
  }

  /// وەرگرتنی زانیاری تەنها یەک کرێکار.
  Future<Employee?> getEmployee(String employeeId) async {
    try {
      final doc =
          await _firestore
              .collection(employeesCollection)
              .doc(employeeId)
              .get();

      if (doc.exists) {
        return Employee.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting employee: $e');
      rethrow;
    }
  }

  /// وەرگرتنی هەموو کرێکاران بە stream بۆ نوێبوونەوەی خێرا.
  Stream<List<Employee>> getAllEmployeesStream() {
    return _firestore
        .collection(employeesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Employee.fromJson(doc.data()))
              .toList();
        });
  }

  /// وەرگرتنی هەموو کرێکاران وەک Future.
  Future<List<Employee>> getAllEmployees() async {
    try {
      final snapshot =
          await _firestore
              .collection(employeesCollection)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting all employees: $e');
      rethrow;
    }
  }

  // ==================== کارەکانی ئامادەبوون ====================

  /// تۆمارکردنی ئامادەبوونی کرێکارێک.
  Future<Attendance> markAttendance({
    required String employeeId,
    required DateTime date,
    required AttendanceType type,
    required double dailySalary,
    String? notes,
  }) async {
    try {
      final String id = const Uuid().v4();
      final now = DateTime.now();
      final earnedAmount = dailySalary * type.salaryPercentage;

      final attendance = Attendance(
        id: id,
        employeeId: employeeId,
        date: date,
        type: type,
        earnedAmount: earnedAmount,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(attendanceCollection)
          .doc(id)
          .set(attendance.toJson());

      // نوێکردنەوەی حسابی مووچە دوای تۆمارکردنی ئامادەبوون.
      await _updateSalaryRecord(employeeId, date, dailySalary);

      return attendance;
    } catch (e) {
      print('Error marking attendance: $e');
      rethrow;
    }
  }

  /// دەستکاریکردنی تۆماری ئامادەبوون.
  Future<void> updateAttendance(Attendance attendance) async {
    try {
      await _firestore
          .collection(attendanceCollection)
          .doc(attendance.id)
          .update(attendance.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }

  /// سڕینەوەی تۆماری ئامادەبوون.
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore
          .collection(attendanceCollection)
          .doc(attendanceId)
          .delete();
    } catch (e) {
      print('Error deleting attendance: $e');
      rethrow;
    }
  }

  /// وەرگرتنی ئامادەبوونی هەموو کرێکاران بۆ بەروارێکی دیاریکراو.
  Stream<List<Attendance>> getAttendanceForDateStream(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(attendanceCollection)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Attendance.fromJson(doc.data()))
              .toList();
        });
  }

  /// وەرگرتنی ئامادەبوونی کرێکار لە ماوەیەکی دیاریکراو.
  Stream<List<Attendance>> getEmployeeAttendanceStream({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection(attendanceCollection)
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Attendance.fromJson(doc.data()))
              .toList();
        });
  }

  /// وەرگرتنی هەموو تۆمارەکانی ئامادەبوون.
  Stream<List<Attendance>> getAllAttendanceStream() {
    return _firestore
        .collection(attendanceCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Attendance.fromJson(doc.data()))
              .toList();
        });
  }

  // ==================== کارەکانی مووچە ====================

  /// نوێکردنەوە یان دروستکردنی حسابی مووچە.
  Future<void> _updateSalaryRecord(
    String employeeId,
    DateTime date,
    double dailySalary,
  ) async {
    try {
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(
        date.year,
        date.month + 1,
        1,
      ).subtract(const Duration(days: 1));

      // وەرگرتنی هەموو ئامادەبوونەکانی ئەم مانگە.
      final attendanceQuery =
          await _firestore
              .collection(attendanceCollection)
              .where('employeeId', isEqualTo: employeeId)
              .where('date', isGreaterThanOrEqualTo: startOfMonth)
              .where('date', isLessThanOrEqualTo: endOfMonth)
              .get();

      double monthlyEarnings = 0;
      int fullDaysCount = 0;
      int halfDaysCount = 0;

      for (var doc in attendanceQuery.docs) {
        final attendance = Attendance.fromJson(doc.data());
        monthlyEarnings += attendance.earnedAmount;

        if (attendance.type == AttendanceType.fullDay) {
          fullDaysCount++;
        } else {
          halfDaysCount++;
        }
      }

      // حسابکردنی شایستەیی ئەو ڕۆژە.
      final dailyAttendance =
          attendanceQuery.docs.where((doc) {
            final attendance = Attendance.fromJson(doc.data());
            return attendance.date.day == date.day &&
                attendance.date.month == date.month &&
                attendance.date.year == date.year;
          }).toList();

      double dailyEarnings = 0;
      if (dailyAttendance.isNotEmpty) {
        dailyEarnings =
            Attendance.fromJson(dailyAttendance.first.data()).earnedAmount;
      }

      final recordId = '$employeeId-${date.year}-${date.month}';
      final now = DateTime.now();

      final salaryRecord = SalaryRecord(
        id: recordId,
        employeeId: employeeId,
        date: date,
        dailyEarnings: dailyEarnings,
        monthlyEarnings: monthlyEarnings,
        fullDaysCount: fullDaysCount,
        halfDaysCount: halfDaysCount,
        totalEarnings: monthlyEarnings,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(salaryCollection)
          .doc(recordId)
          .set(salaryRecord.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating salary record: $e');
      rethrow;
    }
  }

  /// وەرگرتنی حسابی مووچەی مانگێک.
  Stream<SalaryRecord?> getSalaryRecordStream({
    required String employeeId,
    required int year,
    required int month,
  }) {
    final recordId = '$employeeId-$year-$month';

    return _firestore
        .collection(salaryCollection)
        .doc(recordId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return SalaryRecord.fromJson(
              snapshot.data() as Map<String, dynamic>,
            );
          }
          return null;
        });
  }

  /// وەرگرتنی هەموو حسابەکانی مووچەی کرێکارێک.
  Stream<List<SalaryRecord>> getEmployeeSalaryHistoryStream(String employeeId) {
    return _firestore
        .collection(salaryCollection)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SalaryRecord.fromJson(doc.data()))
              .toList();
        });
  }

  /// وەرگرتنی حسابەکانی مووچە بۆ ماوەیەکی دیاریکراو.
  Stream<List<SalaryRecord>> getSalaryHistoryStream({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection(salaryCollection)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SalaryRecord.fromJson(doc.data()))
              .toList();
        });
  }
}
