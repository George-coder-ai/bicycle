import 'package:flutter/material.dart';
import '../models/bicycle.dart';
import '../models/maintenance.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'add_maintenance_screen.dart';

enum ServiceStatus { upcoming, dueToday, overdue }

/// Screen 6: Service Reminders
/// Displays in-app upcoming, due today, and overdue maintenance schedules.
class RemindersScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const RemindersScreen({super.key, this.onDataChanged});

  @override
  State<RemindersScreen> createState() => RemindersScreenState();
}

class RemindersScreenState extends State<RemindersScreen> {
  List<MaintenanceRecord> _recordsWithReminders = [];
  List<Bicycle> _bicycles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  /// Reloads reminders and bicycle list
  Future<void> loadReminders() async {
    setState(() => _isLoading = true);
    final records = await StorageService.getMaintenanceRecords();
    final bicycles = await StorageService.getBicycles();

    // Filter to only those records where nextServiceDate is set
    final withReminders =
        records.where((r) => r.nextServiceDate != null).toList();

    // Sort reminders by nextServiceDate ascending (earliest first)
    withReminders
        .sort((a, b) => a.nextServiceDate!.compareTo(b.nextServiceDate!));

    if (mounted) {
      setState(() {
        _recordsWithReminders = withReminders;
        _bicycles = bicycles;
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

  String _getBicycleName(String bicycleId) {
    final bike = _bicycles.where((b) => b.id == bicycleId).firstOrNull;
    return bike != null ? '${bike.name} (${bike.brand})' : 'Bicycle';
  }

  ServiceStatus _getStatus(DateTime serviceDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(serviceDate.year, serviceDate.month, serviceDate.day);

    if (target.isBefore(today)) {
      return ServiceStatus.overdue;
    } else if (target.isAtSameMomentAs(today)) {
      return ServiceStatus.dueToday;
    } else {
      return ServiceStatus.upcoming;
    }
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.upcoming:
        return AppColors.statusUpcoming; // Green
      case ServiceStatus.dueToday:
        return AppColors.statusDueToday; // Orange
      case ServiceStatus.overdue:
        return AppColors.statusOverdue; // Red
    }
  }

  Color _getStatusBgColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.upcoming:
        return AppColors.statusUpcomingBg;
      case ServiceStatus.dueToday:
        return AppColors.statusDueTodayBg;
      case ServiceStatus.overdue:
        return AppColors.statusOverdueBg;
    }
  }

  String _getStatusLabel(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.upcoming:
        return 'Upcoming';
      case ServiceStatus.dueToday:
        return 'Due Today';
      case ServiceStatus.overdue:
        return 'Overdue';
    }
  }

  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.upcoming:
        return Icons.event_available_rounded;
      case ServiceStatus.dueToday:
        return Icons.alarm_rounded;
      case ServiceStatus.overdue:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Service Reminders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Reminders',
            onPressed: loadReminders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _recordsWithReminders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadReminders,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    itemCount: _recordsWithReminders.length,
                    itemBuilder: (context, index) {
                      final record = _recordsWithReminders[index];
                      final status = _getStatus(record.nextServiceDate!);
                      final statusColor = _getStatusColor(status);
                      final statusBgColor = _getStatusBgColor(status);
                      final statusLabel = _getStatusLabel(status);
                      final statusIcon = _getStatusIcon(status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status icon circle
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(statusIcon,
                                        color: statusColor, size: 24),
                                  ),
                                  const SizedBox(width: 12),

                                  // Maintenance Type & Bicycle Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.maintenanceType,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.directions_bike_rounded,
                                              size: 14,
                                              color: AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                _getBicycleName(
                                                    record.bicycleId),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textMuted,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 10),

                              // Date & Action row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 15,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Next Service: ${_formatDate(record.nextServiceDate!)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddMaintenanceScreen(
                                            recordToEdit: record,
                                          ),
                                        ),
                                      );
                                      if (res == true) {
                                        loadReminders();
                                        widget.onDataChanged?.call();
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                    child: const Text(
                                      'Edit / Reschedule',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  /// Empty state when no service reminders have been set
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.pastelGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 52,
                color: AppColors.statusUpcoming,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Service Reminders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Keep your rides dependable! Whenever you record maintenance, specify a "Next Service Date" to receive in-app reminders here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMaintenanceScreen(),
                  ),
                );
                if (res == true) {
                  loadReminders();
                  widget.onDataChanged?.call();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.alarm_add_rounded),
              label: const Text(
                'Schedule Maintenance',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
