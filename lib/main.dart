import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goran/config/index.dart';
import 'package:goran/providers/index.dart';
import 'package:goran/screens/index.dart';

void main() {
  // ئامادەکردنی Flutter پێش دەستپێکردنی ئەپەکە.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WorkforceApp());
}

// ئەم widget ـە theme و state ـی سەرەکیی ئەپەکە ڕێکدەخات.
class WorkforceApp extends StatelessWidget {
  const WorkforceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDataProvider(),
      child: MaterialApp(
        // ئەپەکە بە زمانی کوردی و ئاراستەی ڕاست بۆ چەپ کار دەکات.
        debugShowCheckedModeBanner: false,
        title: 'بەڕێوەبردنی کرێکاران',
        theme: AppTheme.lightTheme,
        locale: const Locale('ckb', 'IQ'),
        home: const MainNavigationScreen(),
        builder:
            (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // ژمارەی پەڕەی چالاک لە navigation ـی خوارەوە.
  int _currentIndex = 0;

  void _goTo(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    // هەر پەڕەیەک دەمێنێتەوە بۆ پاراستنی دۆخی خۆی.
    final screens = [
      DashboardScreen(onNavigate: _goTo),
      const AttendanceScreen(),
      const EmployeeManagementScreen(),
      const HistoryReportsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goTo,
        height: 72,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'سەرەکی',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'ئامادەبوون',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'کرێکاران',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'ڕاپۆرت',
          ),
        ],
      ),
    );
  }
}
