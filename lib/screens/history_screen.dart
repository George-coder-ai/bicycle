import 'package:flutter/material.dart';
import '../models/bicycle.dart';
import '../models/maintenance.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/maintenance_card.dart';
import 'add_maintenance_screen.dart';

/// Screen 4: Maintenance History
/// Displays all maintenance events sorted with the latest records first.
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const HistoryScreen({super.key, this.onDataChanged});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<MaintenanceRecord> _records = [];
  List<Bicycle> _bicycles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistoryData();
  }

  /// Reloads records and bicycles from SharedPreferences
  Future<void> loadHistoryData() async {
    setState(() => _isLoading = true);
    final records = await StorageService.getMaintenanceRecords();
    final bicycles = await StorageService.getBicycles();

    // Sort latest maintenance records first
    records.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _records = records;
        _bicycles = bicycles;
        _isLoading = false;
      });
    }
  }

  String _getBicycleName(String bicycleId) {
    final bike = _bicycles.where((b) => b.id == bicycleId).firstOrNull;
    return bike != null ? '${bike.name} (${bike.brand})' : 'Bicycle';
  }

  Future<void> _navigateToAddMaintenance() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMaintenanceScreen()),
    );
    if (result == true) {
      loadHistoryData();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _navigateToEditMaintenance(MaintenanceRecord record) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMaintenanceScreen(recordToEdit: record),
      ),
    );
    if (result == true) {
      loadHistoryData();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _confirmDeleteRecord(MaintenanceRecord record) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.delete_sweep_rounded,
                  color: AppColors.statusOverdue, size: 28),
              SizedBox(width: 8),
              Text('Delete Record?'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this "${record.maintenanceType}" record?',
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusOverdue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await StorageService.deleteMaintenanceRecord(record.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintenance record deleted.'),
            backgroundColor: AppColors.statusOverdue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        loadHistoryData();
        widget.onDataChanged?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Maintenance History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh History',
            onPressed: loadHistoryData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_history_maintenance',
        onPressed: _navigateToAddMaintenance,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Maintenance',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _records.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadHistoryData,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return MaintenanceCard(
                        record: record,
                        bicycleName: _getBicycleName(record.bicycleId),
                        onEdit: () => _navigateToEditMaintenance(record),
                        onDelete: () => _confirmDeleteRecord(record),
                      );
                    },
                  ),
                ),
    );
  }

  /// Friendly empty-state message when no maintenance records exist
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
                color: AppColors.pastelBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.build_circle_outlined,
                size: 52,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Maintenance Logged Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log tyre changes, lubrication, brake adjustments, and general servicing to maintain your bicycle log.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddMaintenance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Log First Maintenance',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
