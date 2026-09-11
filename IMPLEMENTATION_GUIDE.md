# Mobile Attendance & Salary Management App - Implementation Guide

## 🎯 Project Overview

This is a professional-grade Flutter application for managing employee attendance and salary calculations. It features real-time data synchronization using Firebase Firestore, designed to work seamlessly on two devices with instant updates.

## 📱 Features

✅ **Employee Management** - Add, edit, delete employees with daily salary rates
✅ **Attendance Tracking** - Mark full-day (حاموو کات) or half-day (نیوەی کات) attendance
✅ **Real-time Sync** - Firestore streams ensure instant data updates across devices
✅ **Salary Calculations** - Automatic daily and monthly salary tracking
✅ **History & Reports** - Browse historical attendance and salary data
✅ **Modern UI/UX** - Clean, professional design with smooth animations
✅ **Kurdish Typography** - Support for Kurdish text with Rudaw font

## 🔧 Setup Instructions

### Step 1: Firebase Project Setup

1. **Go to Firebase Console** → https://console.firebase.google.com
2. **Create a new project**:
   - Project name: `Attendance-Salary-App`
   - Enable Google Analytics (optional)

3. **Enable Firestore Database**:
   - Go to "Firestore Database" in the left sidebar
   - Click "Create Database"
   - Start in **Test Mode** (for development)
   - Choose a region (e.g., `us-central1`)

4. **Set Firestore Security Rules** (for production, make these more restrictive):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;  // For testing only!
       }
     }
   }
   ```

5. **Get Firebase Credentials**:
   - Go to Project Settings (⚙️ icon)
   - Download `google-services.json` (for Android)
   - Copy the project ID, API key, and other credentials

### Step 2: Update Firebase Configuration

Open [lib/config/firebase_config.dart](lib/config/firebase_config.dart) and replace with your Firebase credentials:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY_HERE',
    appId: 'YOUR_APP_ID_HERE',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  ),
);
```

### Step 3: Add Rudaw Font (Optional but Recommended)

For Kurdish text support with Rudaw font:

1. Download Rudaw font files (TrueType .ttf format)
2. Place them in `assets/fonts/`:
   - `Rudaw-Regular.ttf`
   - `Rudaw-Bold.ttf`
   - `Rudaw-Medium.ttf`

The font is already configured in `pubspec.yaml`. If you skip this step, the app will use fallback system fonts.

### Step 4: Install Dependencies

```bash
cd path/to/goran
flutter clean
flutter pub get
```

### Step 5: Run the Application

```bash
# Development mode
flutter run

# Release mode (for two devices)
flutter run --release
```

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point with navigation
├── config/
│   ├── firebase_config.dart           # Firebase initialization
│   ├── theme_config.dart              # Theme, colors, typography
│   └── index.dart
├── models/
│   ├── employee.dart                  # Employee data model
│   ├── attendance.dart                # Attendance tracking model
│   ├── salary_record.dart             # Salary calculation model
│   └── index.dart
├── services/
│   ├── firestore_service.dart         # Firestore operations
│   └── index.dart
├── providers/
│   ├── employee_provider.dart         # Employee state management
│   ├── attendance_provider.dart       # Attendance state management
│   ├── salary_provider.dart           # Salary state management
│   └── index.dart
├── screens/
│   ├── dashboard_screen.dart          # Home dashboard
│   ├── attendance_screen.dart         # Attendance marking
│   ├── employee_management_screen.dart # CRUD operations
│   ├── history_reports_screen.dart    # Historical data
│   └── index.dart
├── widgets/
│   ├── cards.dart                     # Reusable card components
│   ├── dialogs.dart                   # Dialog components
│   └── index.dart
└── assets/
    └── fonts/
        ├── Rudaw-Regular.ttf
        ├── Rudaw-Bold.ttf
        └── Rudaw-Medium.ttf
```

## 🎨 Key Features Explained

### Real-time Synchronization

The app uses Firebase Firestore Streams for automatic real-time updates:

```dart
// Any change on one device is instantly reflected on the other
Stream<List<Attendance>> getAttendanceForDateStream(DateTime date) {
  return _firestore
      .collection('attendance')
      .where('date', isGreaterThanOrEqualTo: startOfDay)
      .where('date', isLessThan: endOfDay)
      .snapshots()
      .map((snapshot) => /* convert to models */);
}
```

### Attendance Types

- **Full Day (حاموو کات)**: Employee earns 100% of daily salary
- **Half Day (نیوەی کات)**: Employee earns 50% of daily salary

### Salary Calculation

Monthly salary is calculated automatically:
- Counts full days and half days
- Multiplies by daily rate
- Accumulates throughout the month
- Accessible from History/Reports screen

### State Management with Provider

Each major feature has its own ChangeNotifier:

- **EmployeeProvider**: Manages employee CRUD operations
- **AttendanceProvider**: Manages attendance marking and retrieval
- **SalaryProvider**: Manages salary calculations and history

## 🚀 Running on Two Devices

### Setup for Two-Device Sync:

1. **Configure both phones**:
   - Connect both phones to the same WiFi network
   - Ensure both have the app installed (same build)

2. **Firestore will automatically sync**:
   - When you mark attendance on Phone A, it appears on Phone B instantly
   - Changes to employee data sync in real-time
   - No additional configuration needed!

3. **Test the sync**:
   - Open the app on both devices
   - Mark attendance on one device
   - Verify it appears on the other device within seconds

## 📊 Database Structure

### Firestore Collections

#### `employees` Collection
```json
{
  "id": "uuid",
  "name": "Ahmed Hassan",
  "position": "Developer",
  "dailySalary": 50.00,
  "phoneNumber": "+964...",
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

#### `attendance` Collection
```json
{
  "id": "uuid",
  "employeeId": "uuid",
  "date": timestamp,
  "type": 0,  // 0 = full-day, 1 = half-day
  "earnedAmount": 25.00,
  "notes": "Optional notes",
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

#### `salary_records` Collection
```json
{
  "id": "employeeId-year-month",
  "employeeId": "uuid",
  "date": timestamp,
  "dailyEarnings": 25.00,
  "monthlyEarnings": 750.00,
  "fullDaysCount": 28,
  "halfDaysCount": 2,
  "totalEarnings": 750.00,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

## 🎯 Usage Guide

### Dashboard
- View total employees and daily salary budget
- See today's attendance records
- Quick access to recent employees

### Attendance
- Select a date to view/modify attendance
- Add attendance records by selecting employee and attendance type
- Edit or delete existing records

### Employee Management
- Add new employees with name, position, daily salary, phone
- Edit employee information
- Delete employees (with cascading deletion of related records)
- View employee details

### History & Reports
- **Salary History Tab**: View monthly salary summaries
- **Attendance History Tab**: Browse attendance by employee or date range
- Export-ready data format

## 🔒 Security Considerations

### Current Setup (Development)
- Test mode Firestore rules allow all read/write
- Suitable for two-device internal use

### For Production
Update Firestore rules to:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /employees/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /attendance/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /salary_records/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📝 Customization

### Colors & Theme
Edit [lib/config/theme_config.dart](lib/config/theme_config.dart):

```dart
static const Color primaryColor = Color(0xFF1E88E5);
static const Color successColor = Color(0xFF43A047);
static const Color errorColor = Color(0xFFE53935);
```

### Typography
All Kurdish text uses the Rudaw font configured in TextTheme. Customize in `AppTheme.lightTheme`:

```dart
textTheme: TextTheme(
  bodyLarge: GoogleFonts.rudaw(
    fontSize: 16,
    color: textPrimary,
  ),
  // ... more styles
)
```

## 🐛 Troubleshooting

### Firebase Connection Issues
- Verify Firebase credentials in `firebase_config.dart`
- Check internet connection on both devices
- Ensure Firestore is enabled in Firebase console

### Data Not Syncing
- Confirm both devices are using the same Firebase project
- Check Firestore security rules allow read/write
- Restart the app on both devices

### Font Not Displaying
- If Rudaw font is missing, app falls back to system fonts
- Kurdish text will still be readable, just with different font
- To use Rudaw, add the `.ttf` files to `assets/fonts/`

## 📱 Supported Platforms

- ✅ Android 5.0+ (recommended: Android 8+)
- ✅ iOS 11.0+
- ✅ Web (with Firebase authentication)
- ✅ Windows, macOS, Linux (with appropriate Flutter setup)

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev)
- [Firebase & Firestore](https://firebase.google.com)
- [Provider Package](https://pub.dev/packages/provider)
- [Firestore Real-time Syncing](https://firebase.google.com/docs/firestore/query-data/listen)

## 📞 Support & Notes

### Two-Device Synchronization
This app is designed for exactly two devices. Firestore automatically syncs:
- Employee data changes
- Attendance records
- Salary calculations

Just keep both apps connected to the internet!

### Performance Optimization
- Streams are set up for efficient real-time listening
- Queries use indexes for fast retrieval
- Material 3 design ensures smooth 60fps animations

---

**Built with ❤️ for Professional Attendance Management**
