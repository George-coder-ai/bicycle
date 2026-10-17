import 'package:flutter/material.dart';
import 'screens/bicycle_list_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reminders_screen.dart';
import 'utils/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BicycleMaintenanceApp());
}

/// Root Application Widget configuring Material 3 theme and colors
class BicycleMaintenanceApp extends StatelessWidget {
  const BicycleMaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bicycle Maintenance Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: const CardTheme(
          color: AppColors.card,
          elevation: 2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

/// Bottom Navigation Host with four tabs:
/// 1. Home
/// 2. Bicycles
/// 3. History
/// 4. Reminders
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Global keys to refresh data across tabs on switch
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<BicycleListScreenState> _bicyclesKey =
      GlobalKey<BicycleListScreenState>();
  final GlobalKey<HistoryScreenState> _historyKey =
      GlobalKey<HistoryScreenState>();
  final GlobalKey<RemindersScreenState> _remindersKey =
      GlobalKey<RemindersScreenState>();

  void _refreshAll() {
    _homeKey.currentState?.loadDashboardData();
    _bicyclesKey.currentState?.loadBicycles();
    _historyKey.currentState?.loadHistoryData();
    _remindersKey.currentState?.loadReminders();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Refresh all data across tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: _homeKey,
        onNavigateToBicycles: () => _onTabTapped(1),
        onNavigateToHistory: () => _onTabTapped(2),
        onNavigateToReminders: () => _onTabTapped(3),
        onDataChanged: _refreshAll,
      ),
      BicycleListScreen(
        key: _bicyclesKey,
        onDataChanged: _refreshAll,
      ),
      HistoryScreen(
        key: _historyKey,
        onDataChanged: _refreshAll,
      ),
      RemindersScreen(
        key: _remindersKey,
        onDataChanged: _refreshAll,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike_outlined),
            activeIcon: Icon(Icons.directions_bike_rounded),
            label: 'Bicycles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            activeIcon: Icon(Icons.notifications_active_rounded),
            label: 'Reminders',
          ),
        ],
      ),
    );
  }
}
