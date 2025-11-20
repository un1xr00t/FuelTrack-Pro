// lib/screens/garage_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';
import 'add_vehicle_screen.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  List<VehicleProfile> _vehicles = [];
  VehicleProfile? _activeVehicle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicles = await DatabaseService.instance.getAllVehicles();
      final activeVehicle = await DatabaseService.instance.getActiveVehicle();

      // Debug: Log vehicle image paths
      for (var vehicle in vehicles) {
        debugPrint('Vehicle: ${vehicle.name}, ImagePath: ${vehicle.imagePath}');
        if (vehicle.imagePath != null && vehicle.imagePath!.isNotEmpty) {
          final imageFile = File(vehicle.imagePath!);
          debugPrint('  Image exists: ${imageFile.existsSync()}');
        }
      }

      setState(() {
        _vehicles = vehicles;
        _activeVehicle = activeVehicle;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Error',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Error loading vehicles: $e',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF667EEA)),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Garage',
        useNativeToolbar: true,
      ),
      body: SafeArea(
        top: false, // Don't apply SafeArea to top since app bar handles it
        child: Container(
          color: const Color(0xFF000000),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF667EEA),
                  ),
                )
              : _vehicles.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 120,
                        left: 24,
                        right: 24,
                        bottom: 140,
                      ),
                      itemCount: _vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _vehicles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildVehicleCard(vehicle),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: AdaptiveFloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddVehicleScreen(),
              ),
            );
            if (result == true) {
              _loadVehicles();
            }
          },
          backgroundColor: const Color(0xFF667EEA),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.directions_car,
                size: 64,
                color: Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Vehicles Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first vehicle to start tracking fuel efficiency',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddVehicleScreen(),
                  ),
                );
                if (result == true) {
                  _loadVehicles();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'ADD VEHICLE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleProfile vehicle) {
    final isActive = vehicle.id == _activeVehicle?.id;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF667EEA)
              : const Color(0xFF2A2A2A),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectVehicle(vehicle),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Car profile picture
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF667EEA),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _buildVehicleImage(vehicle.imagePath),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vehicle.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (vehicle.year != null ||
                              vehicle.make != null ||
                              vehicle.model != null)
                            Text(
                              [
                                if (vehicle.year != null) vehicle.year.toString(),
                                if (vehicle.make != null) vehicle.make,
                                if (vehicle.model != null) vehicle.model,
                              ].join(' '),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (vehicle.tankCapacity != null ||
                    vehicle.epaCombined != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        if (vehicle.tankCapacity != null)
                          _buildSpec(
                            'Tank',
                            '${vehicle.tankCapacity!.toStringAsFixed(1)} gal',
                            Icons.local_gas_station,
                          ),
                        if (vehicle.tankCapacity != null &&
                            vehicle.epaCombined != null)
                          const SizedBox(width: 16),
                        if (vehicle.epaCombined != null)
                          _buildSpec(
                            'EPA',
                            '${vehicle.epaCombined!.toStringAsFixed(1)} MPG',
                            Icons.speed,
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _editVehicle(vehicle),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF667EEA),
                        ),
                        child: const Text('EDIT'),
                      ),
                    ),
                    if (!isActive)
                      Expanded(
                        child: TextButton(
                          onPressed: () => _deleteVehicle(vehicle),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('DELETE'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpec(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF667EEA),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(
        Icons.directions_car,
        color: Color(0xFF667EEA),
        size: 40,
      );
    }

    final imageFile = File(imagePath);
    
    // Check if file exists synchronously first
    if (!imageFile.existsSync()) {
      debugPrint('Vehicle image not found at: $imagePath');
      return const Icon(
        Icons.directions_car,
        color: Color(0xFF667EEA),
        size: 40,
      );
    }

    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading vehicle image: $error');
        return const Icon(
          Icons.directions_car,
          color: Color(0xFF667EEA),
          size: 40,
        );
      },
    );
  }

  Future<void> _selectVehicle(VehicleProfile vehicle) async {
    if (vehicle.id == _activeVehicle?.id) return;

    try {
      await DatabaseService.instance.setActiveVehicle(vehicle.id);
      setState(() {
        _activeVehicle = vehicle;
        _vehicles = _vehicles.map((v) {
          return v.copyWith(isActive: v.id == vehicle.id);
        }).toList();
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Success',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Switched to ${vehicle.name}',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Error',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Error switching vehicle: $e',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF667EEA)),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _editVehicle(VehicleProfile vehicle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVehicleScreen(vehicle: vehicle),
      ),
    );
    if (result == true) {
      _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(VehicleProfile vehicle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Vehicle?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will delete "${vehicle.name}" and all its fill-up records. This cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Color(0xFF667EEA)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService.instance.deleteVehicle(vehicle.id);
        _loadVehicles();
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Deleted',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Vehicle deleted',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xFF667EEA)),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Error',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Error deleting vehicle: $e',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xFF667EEA)),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}