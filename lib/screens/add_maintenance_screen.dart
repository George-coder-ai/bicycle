import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bicycle.dart';
import '../models/maintenance.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'add_bicycle_screen.dart';

/// Form screen to add or edit a maintenance record.
class AddMaintenanceScreen extends StatefulWidget {
  final MaintenanceRecord? recordToEdit;
  final String? preselectedBicycleId;

  const AddMaintenanceScreen({
    super.key,
    this.recordToEdit,
    this.preselectedBicycleId,
  });

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Bicycle> _bicycles = [];
  bool _isLoadingBicycles = true;
  bool _isSaving = false;

  String? _selectedBicycleId;
  String _selectedType = MaintenanceRecord.types.first;
  late DateTime _maintenanceDate;
  DateTime? _nextServiceDate;
  late TextEditingController _costController;
  late TextEditingController _notesController;

  bool get _isEditing => widget.recordToEdit != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recordToEdit;
    _selectedType = r?.maintenanceType ?? MaintenanceRecord.types.first;
    _maintenanceDate = r?.date ?? DateTime.now();
    _nextServiceDate = r?.nextServiceDate;
    _costController = TextEditingController(
      text: r != null ? r.cost.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: r?.notes ?? '');

    _loadBicycles();
  }

  @override
  void dispose() {
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBicycles() async {
    setState(() => _isLoadingBicycles = true);
    final list = await StorageService.getBicycles();

    setState(() {
      _bicycles = list;
      _isLoadingBicycles = false;

      // Determine preselection
      if (widget.recordToEdit != null) {
        _selectedBicycleId = widget.recordToEdit!.bicycleId;
      } else if (widget.preselectedBicycleId != null &&
          _bicycles.any((b) => b.id == widget.preselectedBicycleId)) {
        _selectedBicycleId = widget.preselectedBicycleId;
      } else if (_bicycles.isNotEmpty) {
        _selectedBicycleId = _bicycles.first.id;
      } else {
        _selectedBicycleId = null;
      }
    });
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

  Future<void> _pickMaintenanceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _maintenanceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _maintenanceDate = picked);
    }
  }

  Future<void> _pickNextServiceDate() async {
    final initialDate = _nextServiceDate ?? _maintenanceDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _nextServiceDate = picked);
    }
  }

  Future<void> _saveRecord() async {
    if (_bicycles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a bicycle first.'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBicycleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bicycle.'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
    if (cost < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cost cannot be negative.'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final updated = widget.recordToEdit!.copyWith(
          bicycleId: _selectedBicycleId!,
          maintenanceType: _selectedType,
          date: _maintenanceDate,
          cost: cost,
          notes: _notesController.text.trim(),
          nextServiceDate: _nextServiceDate,
          clearNextServiceDate: _nextServiceDate == null,
        );
        await StorageService.updateMaintenanceRecord(updated);
      } else {
        final newRecord = MaintenanceRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bicycleId: _selectedBicycleId!,
          maintenanceType: _selectedType,
          date: _maintenanceDate,
          cost: cost,
          notes: _notesController.text.trim(),
          nextServiceDate: _nextServiceDate,
        );
        await StorageService.addMaintenanceRecord(newRecord);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Maintenance record updated!'
                  : 'Maintenance record saved!',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving record: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Maintenance' : 'Add Maintenance',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingBicycles
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _bicycles.isEmpty
                  ? _buildNoBicyclesPrompt()
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.pastelTeal,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.build_circle_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isEditing
                                            ? 'Update Maintenance Log'
                                            : 'Record Maintenance',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Track servicing, parts, and costs.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Bicycle selection dropdown
                          const Text(
                            'Select Bicycle *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedBicycleId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.directions_bike_rounded,
                                color: AppColors.primary,
                              ),
                              filled: true,
                              fillColor: AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                            items: _bicycles.map((bike) {
                              return DropdownMenuItem<String>(
                                value: bike.id,
                                child: Text('${bike.name} (${bike.brand})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedBicycleId = val);
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please select a bicycle';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Maintenance Type dropdown
                          const Text(
                            'Maintenance Type *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.handyman_outlined,
                                color: AppColors.secondary,
                              ),
                              filled: true,
                              fillColor: AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                            items: MaintenanceRecord.types.map((t) {
                              return DropdownMenuItem<String>(
                                value: t,
                                child: Text(t),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedType = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Maintenance Date Picker Field
                          const Text(
                            'Maintenance Date *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickMaintenanceDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded,
                                      color: AppColors.accent),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _formatDate(_maintenanceDate),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.edit_calendar_outlined,
                                      color: AppColors.textMuted, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Maintenance Cost Field
                          const Text(
                            'Cost (₹) *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _costController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: const Icon(
                                  Icons.currency_rupee_rounded,
                                  color: AppColors.primary),
                              filled: true,
                              fillColor: AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter the cost (enter 0 if free)';
                              }
                              final parsed = double.tryParse(val.trim());
                              if (parsed == null) {
                                return 'Please enter a valid number';
                              }
                              if (parsed < 0) {
                                return 'Cost cannot be negative';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Notes Field
                          const Text(
                            'Notes (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  'e.g., Cleaned drivetrain, tightened front brake cable',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 40),
                                child: Icon(Icons.notes_rounded,
                                    color: AppColors.accentPurple),
                              ),
                              filled: true,
                              fillColor: AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Next Service Date Picker Field (Optional)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Next Service Date (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (_nextServiceDate != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() => _nextServiceDate = null);
                                  },
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.statusOverdue),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickNextServiceDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.alarm_on_rounded,
                                      color: AppColors.secondary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _nextServiceDate != null
                                          ? _formatDate(_nextServiceDate!)
                                          : 'Tap to select next service date',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: _nextServiceDate != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: _nextServiceDate != null
                                            ? AppColors.textDark
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.event_outlined,
                                      color: AppColors.textMuted, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Action Buttons
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveRecord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline_rounded),
                            label: Text(
                              _isEditing
                                  ? 'Update Record'
                                  : 'Save Maintenance Record',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }

  /// Helpful empty-state widget when user has not added any bicycles yet
  Widget _buildNoBicyclesPrompt() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.pastelOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bike_outlined,
                size: 44,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Bicycles Added Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need to register at least one bicycle before recording maintenance activities.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBicycleScreen(),
                  ),
                );
                if (added == true) {
                  _loadBicycles();
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
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Bicycle Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
