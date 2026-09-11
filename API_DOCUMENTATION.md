# API Documentation - Attendance & Salary Management App

## 📚 Complete API Reference

### FirestoreService

The main service class for all Firestore operations. Use this in providers to interact with the database.

#### Employee Operations

**`addEmployee()`**
```dart
Future<Employee> addEmployee({
  required String name,
  required String position,
  required double dailySalary,
  required String phoneNumber,
})
```
Adds a new employee and returns the created Employee object.

**`updateEmployee()`**
```dart
Future<void> updateEmployee(Employee employee)
```
Updates an existing employee. Must pass the complete Employee object with updated fields.

**`deleteEmployee()`**
```dart
Future<void> deleteEmployee(String employeeId)
```
Deletes an employee and all their related records (attendance, salary).

**`getEmployee()`**
```dart
Future<Employee?> getEmployee(String employeeId)
```
Retrieves a single employee by ID (one-time fetch).

**`getAllEmployeesStream()`**
```dart
Stream<List<Employee>> getAllEmployeesStream()
```
Returns a live stream of all employees. Updates in real-time.

**`getAllEmployees()`**
```dart
Future<List<Employee>> getAllEmployees()
```
Retrieves all employees as a Future (one-time fetch).

#### Attendance Operations

**`markAttendance()`**
```dart
Future<Attendance> markAttendance({
  required String employeeId,
  required DateTime date,
  required AttendanceType type,
  required double dailySalary,
  String? notes,
})
```
Marks attendance for an employee on a specific date. Automatically calculates earnedAmount and updates salary record.

**Parameters:**
- `type`: `AttendanceType.fullDay` (100% salary) or `AttendanceType.halfDay` (50% salary)
- `dailySalary`: Used to calculate `earnedAmount`

**`updateAttendance()`**
```dart
Future<void> updateAttendance(Attendance attendance)
```
Updates an existing attendance record.

**`deleteAttendance()`**
```dart
Future<void> deleteAttendance(String attendanceId)
```
Deletes an attendance record.

**`getAttendanceForDateStream()`**
```dart
Stream<List<Attendance>> getAttendanceForDateStream(DateTime date)
```
Returns a stream of all attendance records for a specific date. Real-time updates.

**`getEmployeeAttendanceStream()`**
```dart
Stream<List<Attendance>> getEmployeeAttendanceStream({
  required String employeeId,
  required DateTime startDate,
  required DateTime endDate,
})
```
Returns attendance records for a specific employee within a date range. Real-time updates.

**`getAllAttendanceStream()`**
```dart
Stream<List<Attendance>> getAllAttendanceStream()
```
Returns all attendance records. Real-time updates.

#### Salary Operations

**`getSalaryRecordStream()`**
```dart
Stream<SalaryRecord?> getSalaryRecordStream({
  required String employeeId,
  required int year,
  required int month,
})
```
Returns the salary record for a specific employee in a month. Real-time updates.

**`getEmployeeSalaryHistoryStream()`**
```dart
Stream<List<SalaryRecord>> getEmployeeSalaryHistoryStream(String employeeId)
```
Returns all salary records for an employee. Real-time updates.

**`getSalaryHistoryStream()`**
```dart
Stream<List<SalaryRecord>> getSalaryHistoryStream({
  required DateTime startDate,
  required DateTime endDate,
})
```
Returns salary records for all employees within a date range. Real-time updates.

---

### EmployeeProvider (State Management)

Manages employee state and provides access to FirestoreService.

#### Methods

**`initializeEmployeeStream()`**
```dart
void initializeEmployeeStream()
```
Initializes the real-time employee stream. Call this once when the app starts or when the screen loads.

**`addEmployee()`**
```dart
Future<bool> addEmployee({
  required String name,
  required String position,
  required double dailySalary,
  required String phoneNumber,
})
```
Adds a new employee. Returns `true` on success.

**`updateEmployee()`**
```dart
Future<bool> updateEmployee({
  required String employeeId,
  required String name,
  required String position,
  required double dailySalary,
  required String phoneNumber,
})
```
Updates an existing employee. Returns `true` on success.

**`deleteEmployee()`**
```dart
Future<bool> deleteEmployee(String employeeId)
```
Deletes an employee. Returns `true` on success.

**`selectEmployee()`**
```dart
void selectEmployee(Employee employee)
```
Selects an employee for detailed view. Updates `selectedEmployee`.

**`deselectEmployee()`**
```dart
void deselectEmployee()
```
Clears the selected employee.

#### Properties

```dart
List<Employee> employees           // All employees
Employee? selectedEmployee         // Currently selected employee
bool isLoading                     // Loading state
String? error                      // Error message
```

#### Usage Example

```dart
// In a widget
Consumer<EmployeeProvider>(
  builder: (context, employeeProvider, _) {
    return ListView(
      children: employeeProvider.employees.map((employee) {
        return EmployeeCard(
          employee: employee,
          onTap: () => employeeProvider.selectEmployee(employee),
        );
      }).toList(),
    );
  },
);
```

---

### AttendanceProvider (State Management)

Manages attendance state and real-time updates.

#### Methods

**`initializeAttendanceStream()`**
```dart
void initializeAttendanceStream(DateTime date)
```
Sets up real-time listening for attendance on a specific date.

**`getEmployeeAttendanceStream()`**
```dart
Stream<List<Attendance>> getEmployeeAttendanceStream({
  required String employeeId,
  required DateTime startDate,
  required DateTime endDate,
})
```
Get a stream of attendance records for an employee in a date range.

**`markAttendance()`**
```dart
Future<bool> markAttendance({
  required String employeeId,
  required DateTime date,
  required AttendanceType type,
  required double dailySalary,
  String? notes,
})
```
Marks attendance. Returns `true` on success.

**`updateAttendance()`**
```dart
Future<bool> updateAttendance(Attendance attendance)
```
Updates an attendance record. Returns `true` on success.

**`deleteAttendance()`**
```dart
Future<bool> deleteAttendance(String attendanceId)
```
Deletes an attendance record. Returns `true` on success.

**`changeDate()`**
```dart
void changeDate(DateTime newDate)
```
Changes the selected date and re-initializes the attendance stream.

#### Properties

```dart
List<Attendance> attendanceRecords    // Attendance records for selected date
DateTime selectedDate                 // Currently viewing this date
bool isLoading                        // Loading state
String? error                         // Error message
```

---

### SalaryProvider (State Management)

Manages salary calculations and history.

#### Methods

**`initializeSalaryStream()`**
```dart
void initializeSalaryStream({
  required String employeeId,
  int? year,
  int? month,
})
```
Sets up real-time listening for salary records.

**`getEmployeeSalaryHistoryStream()`**
```dart
Stream<List<SalaryRecord>> getEmployeeSalaryHistoryStream(String employeeId)
```
Get salary history for a specific employee.

**`getSalaryHistoryStream()`**
```dart
Stream<List<SalaryRecord>> getSalaryHistoryStream({
  required DateTime startDate,
  required DateTime endDate,
})
```
Get salary records for all employees in a date range.

**`changeMonth()`**
```dart
void changeMonth({required int year, required int month})
```
Change the selected month/year.

**`formatCurrency()`**
```dart
String formatCurrency(double amount)
```
Formats a number as currency (e.g., `$25.50`).

#### Properties

```dart
SalaryRecord? currentMonthSalary    // Current month salary record
List<SalaryRecord> salaryHistory    // Historical salary records
int selectedYear                    // Currently selected year
int selectedMonth                   // Currently selected month
bool isLoading                      // Loading state
String? error                       // Error message
```

---

## 🎯 Usage Examples

### Add an Employee

```dart
final employeeProvider = context.read<EmployeeProvider>();

final success = await employeeProvider.addEmployee(
  name: 'Ali Ahmed',
  position: 'Software Engineer',
  dailySalary: 100.0,
  phoneNumber: '+964791234567',
);

if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Employee added successfully')),
  );
}
```

### Mark Attendance

```dart
final attendanceProvider = context.read<AttendanceProvider>();

final success = await attendanceProvider.markAttendance(
  employeeId: 'employee-123',
  date: DateTime.now(),
  type: AttendanceType.fullDay,
  dailySalary: 100.0,
  notes: 'Regular attendance',
);
```

### Display Real-time Attendance

```dart
Consumer<AttendanceProvider>(
  builder: (context, attendanceProvider, _) {
    return ListView(
      children: attendanceProvider.attendanceRecords.map((attendance) {
        return Text('${attendance.earnedAmount} earned');
      }).toList(),
    );
  },
);
```

### Display Salary History with Stream

```dart
Consumer<SalaryProvider>(
  builder: (context, salaryProvider, _) {
    return StreamBuilder<List<SalaryRecord>>(
      stream: salaryProvider.getEmployeeSalaryHistoryStream('employee-123'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        return ListView(
          children: snapshot.data!.map((record) {
            return Text('${record.totalEarnings} (${record.fullDaysCount} days)');
          }).toList(),
        );
      },
    );
  },
);
```

---

## 🔄 Data Flow & Real-time Sync

```
User Action (Mark Attendance)
        ↓
AttendanceProvider.markAttendance()
        ↓
FirestoreService.markAttendance()
        ↓
Firestore Cloud (writes to 'attendance' collection)
        ↓
Firestore Stream listeners (both devices)
        ↓
Provider notifyListeners()
        ↓
UI Updates Automatically (both devices)
```

---

## 🧪 Testing Queries

### Test Real-time Sync

1. Open the app on Device A
2. Mark attendance for an employee
3. **Without closing/refreshing**, observe on Device B
4. Attendance should appear within 1-2 seconds

### Firestore Console Testing

Visit https://console.firebase.google.com:

1. Go to Firestore Database
2. Click on `attendance` collection
3. You should see the document you just created
4. In real-time, you'll see updates from both devices

---

## 🚨 Common Issues & Solutions

### Data Not Updating in Real-time

**Problem**: Changes on Device A don't appear on Device B immediately

**Solutions**:
1. Check internet connection on both devices
2. Verify Firestore security rules allow read/write
3. Check browser console for Firestore errors
4. Restart the app on both devices

### Null Reference Errors

**Problem**: `SelectedEmployee` or other provider properties are null

**Solution**:
```dart
// Always check for null before using
if (employeeProvider.selectedEmployee != null) {
  // Use the employee
} else {
  // Handle null case
}
```

### Performance Issues with Large Datasets

**Problem**: App slows down with many employees/attendance records

**Solutions**:
1. Use pagination in ListView
2. Filter queries by date range
3. Use `take()` to limit results
4. Index frequently queried fields in Firestore

---

## 📖 Full Code Examples

### Complete Screen Example with Real-time Updates

```dart
class MyAttendanceScreen extends StatefulWidget {
  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize stream when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>()
          .initializeAttendanceStream(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.attendanceRecords.isEmpty) {
            return const Center(child: Text('No records'));
          }

          return ListView.builder(
            itemCount: provider.attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = provider.attendanceRecords[index];
              return ListTile(
                title: Text('Earned: \$${record.earnedAmount}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _markAttendance(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _markAttendance(BuildContext context) async {
    final success = await context.read<AttendanceProvider>().markAttendance(
      employeeId: 'emp-123',
      date: DateTime.now(),
      type: AttendanceType.fullDay,
      dailySalary: 50.0,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked')),
      );
    }
  }
}
```

---

## 📝 Notes

- All Provider methods that modify data return `Future<bool>` indicating success/failure
- Stream methods return `Stream<T>` for real-time updates
- Always use `Consumer` or `StreamBuilder` to listen to real-time changes
- Errors are stored in the provider's `error` property
- Salary records are calculated automatically when attendance is marked
