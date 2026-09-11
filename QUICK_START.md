# Quick Start Checklist & Customization Guide

## ✅ Quick Start Checklist

Follow these steps to get the app running:

### 1. Firebase Setup (5-10 minutes)
- [ ] Create Firebase project at https://console.firebase.google.com
- [ ] Enable Firestore Database (Test Mode)
- [ ] Get Firebase credentials
- [ ] Update `lib/config/firebase_config.dart` with credentials
- [ ] Create Firestore collections: `employees`, `attendance`, `salary_records`

### 2. Dependencies (2-5 minutes)
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Verify all packages are installed
- [ ] Check for any dependency conflicts

### 3. Fonts (Optional, 2 minutes)
- [ ] Download Rudaw font files (if you want Kurdish text styling)
- [ ] Place in `assets/fonts/` directory
- [ ] Font already configured in pubspec.yaml

### 4. Run the App (1-2 minutes)
- [ ] Run `flutter run` on your device/emulator
- [ ] Verify app launches without errors
- [ ] Check Firebase connection in console

### 5. Test Two-Device Sync (5-10 minutes)
- [ ] Install app on Device A
- [ ] Install app on Device B
- [ ] Mark attendance on Device A
- [ ] Check if it appears on Device B within 2 seconds
- [ ] Verify it works both ways

### 6. Test Features
- [ ] Add multiple employees
- [ ] Mark different attendance types
- [ ] View Dashboard stats
- [ ] Check History & Reports
- [ ] Edit employee information
- [ ] Delete an employee

---

## 🎨 Customization Guide

### Change App Colors

**File:** `lib/config/theme_config.dart`

```dart
class AppTheme {
  // Change these colors
  static const Color primaryColor = Color(0xFF1E88E5);      // Blue
  static const Color accentColor = Color(0xFF26A69A);       // Teal
  static const Color successColor = Color(0xFF43A047);      // Green
  static const Color errorColor = Color(0xFFE53935);        // Red
  static const Color warningColor = Color(0xFFFDD835);      // Yellow
}
```

**Example: Make it green**
```dart
static const Color primaryColor = Color(0xFF4CAF50);  // Material Green 500
```

---

### Change App Name

**Android:**
- File: `android/app/src/main/AndroidManifest.xml`
```xml
<application
  android:label="My Attendance App"
  ...
/>
```

**iOS:**
- File: `ios/Runner/Info.plist`
```xml
<key>CFBundleName</key>
<string>My Attendance App</string>
```

**Dart:**
- File: `lib/main.dart`
```dart
MaterialApp(
  title: 'My Attendance App',
  ...
)
```

---

### Change Default Currency Symbol

**File:** `lib/providers/salary_provider.dart`

```dart
String formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';  // Change $ to €, £, etc.
}
```

**Example: Use Iraqi Dinar (د.ع)**
```dart
String formatCurrency(double amount) {
  return 'د.ع${amount.toStringAsFixed(2)}';
}
```

---

### Add More Attendance Types

**Currently:** Full Day and Half Day

**To add a "Quarter Day" type:**

1. **Update `lib/models/attendance.dart`:**
```dart
enum AttendanceType {
  fullDay,    // 100%
  halfDay,    // 50%
  quarterDay; // NEW: 25%

  double get salaryPercentage {
    switch (this) {
      case fullDay:
        return 1.0;
      case halfDay:
        return 0.5;
      case quarterDay:
        return 0.25;  // NEW
    }
  }

  String get displayName {
    switch (this) {
      case fullDay:
        return 'حاموو کات';
      case halfDay:
        return 'نیوەی کات';
      case quarterDay:
        return 'ربعی کات';  // NEW
    }
  }
}
```

2. **Update `lib/widgets/dialogs.dart`:**
Add a new RadioListTile in `AttendanceMarkDialog`:
```dart
RadioListTile<AttendanceType>(
  title: const Text('Quarter Day (ربعی کات)'),
  subtitle: Text('Earn 25% - \$${(widget.dailySalary * 0.25).toStringAsFixed(2)}'),
  value: AttendanceType.quarterDay,
  groupValue: _selectedType,
  onChanged: (value) {
    setState(() => _selectedType = value);
  },
),
```

---

### Customize Employee Fields

**To add "Department" field:**

1. **Update `lib/models/employee.dart`:**
```dart
class Employee {
  final String id;
  final String name;
  final String position;
  final String department;  // NEW
  final double dailySalary;
  final String phoneNumber;
  // ...

  Map<String, dynamic> toJson() {
    return {
      // ... existing fields
      'department': department,  // NEW
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      // ... existing fields
      department: json['department'] ?? '',  // NEW
    );
  }
}
```

2. **Update `lib/widgets/dialogs.dart`:**
Add TextField in `AddEmployeeDialog`:
```dart
TextFormField(
  controller: _departmentController,  // NEW
  decoration: const InputDecoration(labelText: 'Department'),
),
```

---

### Add Date Range Filter to Dashboard

**File:** `lib/screens/dashboard_screen.dart`

```dart
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (range != null) {
                setState(() => _dateRange = range);
              }
            },
          ),
        ],
      ),
      body: _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    // Filter data based on _dateRange
    return Center(
      child: Text(
        _dateRange != null
            ? 'From ${_dateRange!.start} to ${_dateRange!.end}'
            : 'Select a date range',
      ),
    );
  }
}
```

---

### Change Text Direction for Kurdish

The app supports RTL languages. To enable RTL globally:

**File:** `lib/main.dart`

```dart
return MaterialApp(
  title: 'Attendance & Salary Management',
  theme: AppTheme.lightTheme,
  // Add locale and directionality
  locale: const Locale('ckb', 'IQ'),  // Kurdish (Iraq)
  supportedLocales: const [
    Locale('en', 'US'),
    Locale('ckb', 'IQ'),
  ],
  // ... rest of MaterialApp
);
```

---

### Add Export to CSV Feature

**Create `lib/services/export_service.dart`:**

```dart
import 'package:csv/csv.dart';

class ExportService {
  static String exportAttendanceToCSV(List<Attendance> records) {
    List<List<dynamic>> rows = [
      ['Employee ID', 'Date', 'Type', 'Earned Amount', 'Notes'],
    ];

    for (var record in records) {
      rows.add([
        record.employeeId,
        record.date.toString(),
        record.type.displayName,
        record.earnedAmount.toString(),
        record.notes ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  static String exportSalaryToCSV(List<SalaryRecord> records) {
    List<List<dynamic>> rows = [
      ['Employee ID', 'Month', 'Full Days', 'Half Days', 'Total Earnings'],
    ];

    for (var record in records) {
      rows.add([
        record.employeeId,
        '${record.date.month}/${record.date.year}',
        record.fullDaysCount.toString(),
        record.halfDaysCount.toString(),
        record.totalEarnings.toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
```

---

### Customize Bottom Navigation

**File:** `lib/main.dart`

```dart
final List<BottomNavigationBarItem> _navItems = [
  const BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.calendar_month),
    label: 'Attendance',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.group),
    label: 'Staff',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.trending_up),
    label: 'Reports',
  ),
];
```

---

### Add Employee Avatar/Photo

**1. Update `lib/models/employee.dart`:**
```dart
class Employee {
  // ... existing fields
  final String? photoUrl;  // NEW
  
  // ... in toJson and fromJson, add:
  'photoUrl': photoUrl,
  photoUrl: json['photoUrl'],
}
```

**2. Update `lib/widgets/cards.dart`:**
```dart
CircleAvatar(
  backgroundImage: employee.photoUrl != null
      ? NetworkImage(employee.photoUrl!)
      : null,
  child: employee.photoUrl == null
      ? const Icon(Icons.person)
      : null,
),
```

---

### Add Search Functionality

**Create `lib/widgets/search_bar.dart`:**

```dart
class EmployeeSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const EmployeeSearchBar({required this.onSearch});

  @override
  State<EmployeeSearchBar> createState() => _EmployeeSearchBarState();
}

class _EmployeeSearchBarState extends State<EmployeeSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search employees...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
              )
            : null,
      ),
      onChanged: widget.onSearch,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

### Disable Test Mode Security (NOT for Production!)

**File:** `lib/config/firebase_config.dart`

If you want to allow anyone to access Firestore (test mode):

```dart
// In Firebase Console, update security rules:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // DANGEROUS! Only for testing
    }
  }
}
```

**For Production:**
```dart
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🚀 Common Enhancements

### 1. Add Dark Mode Toggle
```dart
// In main.dart
themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
```

### 2. Add Notifications
```dart
// Notify when attendance is marked on another device
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Attendance updated')),
);
```

### 3. Add Print Functionality
```dart
import 'package:printing/printing.dart';

void _printAttendanceSheet() {
  // Generate PDF and print
}
```

### 4. Add Backup to Cloud Storage
```dart
// Automatically backup data to Firebase Storage
```

### 5. Add Local Notifications
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void _notifyAttendanceAdded(String employeeName) {
  // Send local notification
}
```

---

## 📱 Testing on Different Devices

### Android Emulator
```bash
flutter emulators
flutter emulators launch <emulator-name>
flutter run
```

### iOS Simulator
```bash
open -a Simulator
flutter run
```

### Physical Device
```bash
flutter devices  # List connected devices
flutter run -d <device-id>
```

### Multiple Devices (for testing sync)
```bash
# Terminal 1
flutter run -d <device1-id>

# Terminal 2
flutter run -d <device2-id>
```

---

## 🔗 Useful Links

- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Firestore**: https://firebase.google.com/docs/firestore
- **Provider Package**: https://pub.dev/packages/provider
- **Material Design**: https://material.io
- **Dart Language**: https://dart.dev

---

**Remember:** Always test thoroughly before deploying to production!
