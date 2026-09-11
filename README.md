# 📱 Attendance & Salary Management App

## Overview

A professional-grade Flutter mobile application designed for real-time employee attendance tracking and salary management. Built specifically for two-device synchronization using Firebase Firestore, this app provides seamless data synchronization with minimal lag.

**Status:** ✅ Complete Implementation Ready

---

## 🎯 Key Features

### ✨ Core Functionality
- **Employee Management** - Add, edit, delete employees with detailed profiles
- **Attendance Tracking** - Mark full-day (حاموو کات) or half-day (نیوەی کات) attendance
- **Real-time Sync** - Instant data synchronization between two devices via Firestore
- **Automatic Salary Calculation** - Daily and monthly earnings tracked automatically
- **History & Reports** - Browse and filter historical data seamlessly
- **Modern UI/UX** - Professional design with smooth animations and Material Design 3

### 🌐 Technical Features
- **Firebase Firestore** - Cloud database with real-time listeners
- **Provider Pattern** - Efficient state management
- **Stream-based Updates** - Live data without manual refresh
- **Kurdish Text Support** - Ready for Rudaw font integration
- **Cross-platform** - Works on Android, iOS, and more

---

## 📁 Project Structure

```
goran/
├── lib/
│   ├── main.dart                    # App entry point with navigation
│   ├── config/
│   │   ├── firebase_config.dart     # Firebase setup
│   │   ├── theme_config.dart        # Colors, typography, theming
│   │   └── index.dart
│   ├── models/
│   │   ├── employee.dart            # Employee data model
│   │   ├── attendance.dart          # Attendance with type enum
│   │   ├── salary_record.dart       # Salary calculations
│   │   └── index.dart
│   ├── services/
│   │   ├── firestore_service.dart   # All Firestore operations
│   │   └── index.dart
│   ├── providers/
│   │   ├── employee_provider.dart   # Employee state management
│   │   ├── attendance_provider.dart # Attendance state management
│   │   ├── salary_provider.dart     # Salary state management
│   │   └── index.dart
│   ├── screens/
│   │   ├── dashboard_screen.dart          # Main dashboard with stats
│   │   ├── attendance_screen.dart         # Mark & view attendance
│   │   ├── employee_management_screen.dart # CRUD employee operations
│   │   ├── history_reports_screen.dart    # Historical data & reports
│   │   └── index.dart
│   ├── widgets/
│   │   ├── cards.dart               # Reusable card components
│   │   ├── dialogs.dart             # Dialog components
│   │   └── index.dart
│   └── assets/
│       └── fonts/
│           ├── Rudaw-Regular.ttf
│           ├── Rudaw-Bold.ttf
│           └── Rudaw-Medium.ttf
├── pubspec.yaml                     # Dependencies and configuration
├── IMPLEMENTATION_GUIDE.md          # Complete setup guide
├── API_DOCUMENTATION.md             # Detailed API reference
├── QUICK_START.md                   # Quick start & customization
└── README.md                        # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.7.2+
- Firebase account
- Two physical devices or emulators (for testing sync)

### 1. Firebase Setup (5 minutes)
```bash
# Create Firebase project at https://console.firebase.google.com
# Enable Firestore Database in Test Mode
# Get your Firebase credentials
```

### 2. Update Firebase Configuration
Edit `lib/config/firebase_config.dart` with your credentials:
```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    // ... other fields
  ),
);
```

### 3. Install Dependencies
```bash
flutter clean
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

### 5. Test Two-Device Sync
Install on two devices and mark attendance - watch it sync instantly!

---

## 📚 Documentation

- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Complete setup and Firebase configuration
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Detailed API reference for all services and providers
- **[QUICK_START.md](QUICK_START.md)** - Quick start checklist and customization examples

---

## 🎨 Architecture

### Data Models
```
Employee
  ├── id (UUID)
  ├── name
  ├── position
  ├── dailySalary
  ├── phoneNumber
  └── timestamps

Attendance
  ├── id (UUID)
  ├── employeeId (FK)
  ├── date
  ├── type (Full-day | Half-day)
  ├── earnedAmount (calculated)
  └── timestamps

SalaryRecord
  ├── id (employeeId-year-month)
  ├── employeeId (FK)
  ├── date
  ├── dailyEarnings
  ├── monthlyEarnings
  ├── fullDaysCount
  ├── halfDaysCount
  └── totalEarnings
```

---

## 🔐 Security

### Current Setup (Test Mode)
- Allows all read/write in Firestore
- Suitable for development and internal two-device use

### Production Recommendation
Update Firestore rules to require authentication:
```javascript
match /databases/{database}/documents {
  match /{document=**} {
    allow read, write: if request.auth != null;
  }
}
```

---

## 📱 Supported Platforms

- ✅ **Android 5.0+** (recommended: Android 8+)
- ✅ **iOS 11.0+**
- ✅ **Web** (with authentication)
- ✅ **macOS, Windows, Linux** (with Firebase setup)

---

## 🚀 Next Steps

1. **Follow Setup Instructions**: See [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
2. **Configure Firebase**: Add your credentials
3. **Run the App**: Test on your device
4. **Test Sync**: Verify two-device synchronization
5. **Customize**: Adjust colors, fonts, features (see [QUICK_START.md](QUICK_START.md))
6. **Deploy**: Build for production with proper security rules

---

**Built with ❤️ for Professional Attendance Management**

