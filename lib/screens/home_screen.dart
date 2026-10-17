import 'package:flutter/material.dart';
import '../models/bicycle.dart';
import '../models/maintenance.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/stat_card.dart';
import 'add_bicycle_screen.dart';
import 'add_maintenance_screen.dart';

/// Screen 1: Home Dashboard
/// Displays real-time overview statistics, SDG 11 contribution,
/// quick action buttons, and upcoming service alerts.
class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToBicycles;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToReminders;
  final VoidCallback? onDataChanged;

  const HomeScreen({
    super.key,
    required this.onNavigateToBicycles,
    required this.onNavigateToHistory,
    required this.onNavigateToReminders,
    this.onDataChanged,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Bicycle> _bicycles = [];
  List<MaintenanceRecord> _records = [];
  double _totalExpenses = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  /// Public reload method so parent can trigger refresh when switching tabs
  Future<void> loadDashboardData() async {
    setState(() => _isLoading = true);
    final bicycles = await StorageService.getBicycles();
    final records = await StorageService.getMaintenanceRecords();
    final expenses = await StorageService.getTotalExpenses();

    if (mounted) {
      setState(() {
        _bicycles = bicycles;
        _records = records;
        _totalExpenses = expenses;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<MaintenanceRecord> get _upcomingReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = _records.where((r) {
      if (r.nextServiceDate == null) return false;
      final serviceDate = DateTime(
        r.nextServiceDate!.year,
        r.nextServiceDate!.month,
        r.nextServiceDate!.day,
      );
      return !serviceDate.isBefore(today);
    }).toList();

    // Sort by reminder date ascending (earliest first)
    upcoming.sort((a, b) => a.nextServiceDate!.compareTo(b.nextServiceDate!));
    return upcoming;
  }

  String _getBicycleName(String bicycleId) {
    final bike = _bicycles.where((b) => b.id == bicycleId).firstOrNull;
    return bike != null ? bike.name : 'Unknown Bicycle';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            AppLogo(
              size: 38,
              borderRadius: 10,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bicycle Maintenance Log',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ride Smart. Maintain Better.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: AppColors.primaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Dashboard',
            onPressed: loadDashboardData,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Greeting Banner
                    _buildWelcomeBanner(),
                    const SizedBox(height: 18),

                    // Section 8: SDG 11 Card
                    _buildSdgCard(),
                    const SizedBox(height: 20),

                    // Statistics Section Header
                    const Text(
                      'Overview & Statistics',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Statistics Cards Grid / Layout
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: widget.onNavigateToBicycles,
                            borderRadius: BorderRadius.circular(16),
                            child: StatCard(
                              title: 'Total Bicycles',
                              value: '${_bicycles.length}',
                              icon: Icons.directions_bike_rounded,
                              iconColor: AppColors.primary,
                              backgroundColor: AppColors.pastelTeal,
                              subtitle: 'Manage',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: widget.onNavigateToHistory,
                            borderRadius: BorderRadius.circular(16),
                            child: StatCard(
                              title: 'Total Services',
                              value: '${_records.length}',
                              icon: Icons.history_rounded,
                              iconColor: AppColors.secondary,
                              backgroundColor: AppColors.pastelBlue,
                              subtitle: 'History',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Total Expenses Card (Full width pastel orange)
                    StatCard(
                      title: 'Total Maintenance Expenses',
                      value: '₹${_totalExpenses.toStringAsFixed(2)}',
                      icon: Icons.savings_rounded,
                      iconColor: AppColors.accent,
                      backgroundColor: AppColors.pastelOrange,
                      subtitle: 'Cumulative',
                    ),
                    const SizedBox(height: 22),

                    // Quick Actions Section
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddBicycleScreen(),
                                ),
                              );
                              if (result == true) {
                                loadDashboardData();
                                widget.onDataChanged?.call();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text(
                              'Add Bicycle',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddMaintenanceScreen(),
                                ),
                              );
                              if (result == true) {
                                loadDashboardData();
                                widget.onDataChanged?.call();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.build_rounded, size: 18),
                            label: const Text(
                              'Add Maintenance',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Service Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Service',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (_upcomingReminders.isNotEmpty)
                          TextButton(
                            onPressed: widget.onNavigateToReminders,
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildUpcomingServicePreview(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  /// Welcome banner card
  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25009688),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Rider!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Keep your bicycles in top condition for healthy, sustainable commuting.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const AppLogo(
              size: 54,
              borderRadius: 13,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  /// Section 8: SDG 11 Card requirement
  Widget _buildSdgCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastelGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA5D6A7),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF81C784),
              ),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF2E7D32),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supporting SDG 11 – Sustainable Cities and Communities',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Regular bicycle maintenance encourages safe, sustainable, and eco-friendly transportation.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF2E7D32),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Upcoming service section on home screen
  Widget _buildUpcomingServicePreview() {
    final reminders = _upcomingReminders;

    if (reminders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 36,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 8),
            Text(
              'No upcoming services scheduled.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Set a next service date when recording maintenance.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show up to the next 2 upcoming reminders
    final previewList = reminders.take(2).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: previewList.map((record) {
        final serviceDate = DateTime(
          record.nextServiceDate!.year,
          record.nextServiceDate!.month,
          record.nextServiceDate!.day,
        );

        Color badgeColor;
        Color badgeBg;
        String statusLabel;

        if (serviceDate.isBefore(today)) {
          badgeColor = AppColors.statusOverdue;
          badgeBg = AppColors.statusOverdueBg;
          statusLabel = 'Overdue';
        } else if (serviceDate.isAtSameMomentAs(today)) {
          badgeColor = AppColors.statusDueToday;
          badgeBg = AppColors.statusDueTodayBg;
          statusLabel = 'Due Today';
        } else {
          badgeColor = AppColors.statusUpcoming;
          badgeBg = AppColors.statusUpcomingBg;
          statusLabel = 'Upcoming';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.alarm_rounded, color: badgeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.maintenanceType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_getBicycleName(record.bicycleId)} • ${_formatDate(record.nextServiceDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
