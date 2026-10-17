import 'package:flutter/material.dart';
import '../models/bicycle.dart';
import '../models/maintenance.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/bicycle_card.dart';
import 'add_bicycle_screen.dart';

/// Screen 2: My Bicycles
/// Lists all registered bicycles with capabilities to Add, Edit, and Delete.
class BicycleListScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const BicycleListScreen({super.key, this.onDataChanged});

  @override
  State<BicycleListScreen> createState() => BicycleListScreenState();
}

class BicycleListScreenState extends State<BicycleListScreen> {
  List<Bicycle> _bicycles = [];
  List<MaintenanceRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBicycles();
  }

  /// Reloads bicycles and records
  Future<void> loadBicycles() async {
    setState(() => _isLoading = true);
    final bicycles = await StorageService.getBicycles();
    final records = await StorageService.getMaintenanceRecords();

    if (mounted) {
      setState(() {
        _bicycles = bicycles;
        _records = records;
        _isLoading = false;
      });
    }
  }

  int _getMaintenanceCount(String bicycleId) {
    return _records.where((r) => r.bicycleId == bicycleId).length;
  }

  Future<void> _navigateToAddBicycle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBicycleScreen()),
    );
    if (result == true) {
      loadBicycles();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _navigateToEditBicycle(Bicycle bicycle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBicycleScreen(bicycleToEdit: bicycle),
      ),
    );
    if (result == true) {
      loadBicycles();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _confirmDeleteBicycle(Bicycle bicycle) async {
    final relatedCount = _getMaintenanceCount(bicycle.id);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.statusOverdue, size: 28),
              SizedBox(width: 8),
              Text('Delete Bicycle?'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${bicycle.name}"?\n\n'
            '${relatedCount > 0 ? "⚠️ This will also delete $relatedCount associated maintenance records to avoid orphaned data." : "This action cannot be undone."}',
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
      await StorageService.deleteBicycle(bicycle.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${bicycle.name}" deleted.'),
            backgroundColor: AppColors.statusOverdue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        loadBicycles();
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
          'My Bicycles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Bicycles',
            onPressed: loadBicycles,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_bicycle_list',
        onPressed: _navigateToAddBicycle,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Bicycle',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _bicycles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadBicycles,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: _bicycles.length,
                    itemBuilder: (context, index) {
                      final bicycle = _bicycles[index];
                      return BicycleCard(
                        bicycle: bicycle,
                        maintenanceCount: _getMaintenanceCount(bicycle.id),
                        onEdit: () => _navigateToEditBicycle(bicycle),
                        onDelete: () => _confirmDeleteBicycle(bicycle),
                      );
                    },
                  ),
                ),
    );
  }

  /// Friendly empty-state message when no bicycles are available
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
                color: AppColors.pastelTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bike_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Bicycles Added Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start tracking your bicycle fleet! Add your first bicycle with its brand, model, and purchase details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddBicycle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Your First Bicycle',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
