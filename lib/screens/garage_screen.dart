// lib/screens/garage_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';
import '../screens/add_vehicle_screen.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> with SingleTickerProviderStateMixin {
  List<VehicleProfile> _vehicles = [];
  VehicleProfile? _activeVehicle;
  Map<String, FuelStats> _vehicleStats = {};
  Map<String, DateTime?> _lastFillupDates = {};
  bool _isLoading = true;
  String _sortBy = 'active'; // 'active', 'newest', 'fillups', 'name'
  bool _showTutorial = false;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loadVehicles();
    _checkTutorial();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicles = await DatabaseService.instance.getAllVehicles();
      final activeVehicle = await DatabaseService.instance.getActiveVehicle();

      // Load stats and last fillup date for each vehicle
      Map<String, FuelStats> statsMap = {};
      Map<String, DateTime?> lastFillupMap = {};
      
      for (var vehicle in vehicles) {
        final stats = await DatabaseService.instance.calculateStats(vehicle.id);
        final fillups = await DatabaseService.instance.getFillupsByVehicle(vehicle.id);
        statsMap[vehicle.id] = stats;
        lastFillupMap[vehicle.id] = fillups.isNotEmpty ? fillups.first.date : null;
      }

      setState(() {
        _vehicles = _sortVehicles(vehicles);
        _activeVehicle = activeVehicle;
        _vehicleStats = statsMap;
        _lastFillupDates = lastFillupMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorDialog('Error loading vehicles: $e');
      }
    }
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('garage_tutorial_seen') ?? false;
    
    if (!hasSeenTutorial && mounted) {
      // Wait a bit for the screen to settle
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showTutorial = true;
          });
        }
      });
    }
  }

  Future<void> _markTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('garage_tutorial_seen', true);
    setState(() {
      _showTutorial = false;
    });
  }

  List<VehicleProfile> _sortVehicles(List<VehicleProfile> vehicles) {
    final sorted = List<VehicleProfile>.from(vehicles);
    
    switch (_sortBy) {
      case 'active':
        sorted.sort((a, b) {
          if (a.isActive && !b.isActive) return -1;
          if (!a.isActive && b.isActive) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'fillups':
        sorted.sort((a, b) {
          final aFillups = _vehicleStats[a.id]?.totalFillups ?? 0;
          final bFillups = _vehicleStats[b.id]?.totalFillups ?? 0;
          return bFillups.compareTo(aFillups);
        });
        break;
      case 'name':
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }
    
    return sorted;
  }

  int get _totalFillups {
    return _vehicleStats.values.fold(0, (sum, stats) => sum + stats.totalFillups);
  }

  double get _totalMiles {
    return _vehicleStats.values.fold(0.0, (sum, stats) => sum + stats.totalMiles);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Garage',
        useNativeToolbar: true,
        actions: [
          AdaptiveAppBarAction(
            onPressed: () {
              setState(() {
                _showTutorial = true;
              });
            },
            iosSymbol: 'questionmark.circle',
            icon: Icons.help_outline,
          ),
          AdaptiveAppBarAction(
            onPressed: _showSortOptions,
            iosSymbol: 'arrow.up.arrow.down',
            icon: Icons.sort,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Container(
              color: const Color(0xFF000000),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667EEA),
                      ),
                    )
                  : _vehicles.isEmpty
                      ? _buildEnhancedEmptyState()
                      : Column(
                          children: [
                            const SizedBox(height: 120),
                            if (_vehicles.isNotEmpty) _buildTopStatsBar(),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  top: 16,
                                  bottom: 140,
                                ),
                                itemCount: _vehicles.length,
                                itemBuilder: (context, index) {
                                  final vehicle = _vehicles[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildEnhancedVehicleCard(vehicle),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          
          // Tutorial overlay
          if (_showTutorial && _vehicles.isNotEmpty)
            _buildTutorialOverlay(),
        ],
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

  Widget _buildTopStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTopStat('Vehicles', '${_vehicles.length}', Icons.directions_car),
          Container(width: 1, height: 30, color: const Color(0xFF2A2A2A)),
          _buildTopStat('Fill-ups', '$_totalFillups', Icons.local_gas_station),
          Container(width: 1, height: 30, color: const Color(0xFF2A2A2A)),
          _buildTopStat('Miles', _totalMiles.toStringAsFixed(0), Icons.straighten),
        ],
      ),
    );
  }

  Widget _buildTopStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF667EEA).withOpacity(0.2),
                    const Color(0xFF667EEA).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.directions_car,
                size: 80,
                color: Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your Garage is Empty',
              style: TextStyle(
                fontSize: 28,
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
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFF667EEA), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'WHY ADD A VEHICLE?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF667EEA),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem('Track multiple vehicles separately'),
                  _buildBenefitItem('Compare efficiency between cars'),
                  _buildBenefitItem('Monitor costs per vehicle'),
                  _buildBenefitItem('Get personalized insights'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'ADD FIRST VEHICLE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF667EEA).withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF667EEA),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedVehicleCard(VehicleProfile vehicle) {
    final isActive = vehicle.id == _activeVehicle?.id;
    final stats = _vehicleStats[vehicle.id];
    final lastFillup = _lastFillupDates[vehicle.id];

    return Dismissible(
      key: Key(vehicle.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right -> Set as active
          if (!isActive) {
            await _setActiveVehicle(vehicle, showToast: true);
          }
          return false;
        } else {
          // Swipe left -> Edit
          _editVehicle(vehicle);
          return false;
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 32),
            const SizedBox(height: 4),
            Text(
              'SET ACTIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 32),
            const SizedBox(height: 4),
            Text(
              'EDIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => isActive ? null : _showSwitchActiveDialog(vehicle),
        onLongPress: () => _showVehicleMenu(vehicle),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? Color.lerp(
                          const Color(0xFF667EEA),
                          const Color(0xFF667EEA).withOpacity(0.5),
                          _pulseController.value,
                        )!
                      : const Color(0xFF2A2A2A),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3 * (1 - _pulseController.value * 0.5)),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Vehicle image
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
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Color(0xFF10B981),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
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
                      
                      // Mini stats for all vehicles
                      if (stats != null && stats.totalFillups > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat(
                                stats.trueMPG > 0 ? stats.trueMPG.toStringAsFixed(1) : '--',
                                'MPG',
                                Icons.speed,
                              ),
                              Container(width: 1, height: 30, color: const Color(0xFF3A3A3A)),
                              _buildMiniStat(
                                '${stats.totalFillups}',
                                'Fill-ups',
                                Icons.local_gas_station,
                              ),
                              Container(width: 1, height: 30, color: const Color(0xFF3A3A3A)),
                              _buildMiniStat(
                                stats.totalMiles.toStringAsFixed(0),
                                'Miles',
                                Icons.straighten,
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Last fillup date
                      if (lastFillup != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Last fillup: ${_formatDate(lastFillup)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Quick actions
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (!isActive)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _setActiveVehicle(vehicle, showToast: true),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF10B981),
                                  side: const BorderSide(color: Color(0xFF10B981)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'SET ACTIVE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (!isActive) const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _showVehicleMenu(vehicle),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.more_horiz, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF667EEA)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _buildImagePlaceholder();
    }

    return FutureBuilder<String>(
      future: _getFullImagePath(imagePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildImagePlaceholder();
        }

        final imageFile = File(snapshot.data!);
        
        if (!imageFile.existsSync()) {
          debugPrint('Vehicle image not found at: ${snapshot.data}');
          return _buildImagePlaceholder();
        }

        return Image.file(
          imageFile,
          key: ValueKey(snapshot.data),
          fit: BoxFit.cover,
          cacheWidth: 300,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading vehicle image: $error');
            return _buildImagePlaceholder();
          },
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.3),
            const Color(0xFF667EEA).withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car,
          color: Color(0xFF667EEA),
          size: 40,
        ),
      ),
    );
  }

  Future<String> _getFullImagePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/vehicle_images/$fileName';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showSwitchActiveDialog(VehicleProfile vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Set Active Vehicle?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Switch to "${vehicle.name}" as your active vehicle? This will update your Home screen and filter History/Stats.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Color(0xFF667EEA)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setActiveVehicle(vehicle, showToast: true);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
            ),
            child: const Text(
              'SWITCH',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setActiveVehicle(VehicleProfile vehicle, {bool showToast = false}) async {
    try {
      await DatabaseService.instance.setActiveVehicle(vehicle.id);
      setState(() {
        _activeVehicle = vehicle;
        _vehicles = _vehicles.map((v) {
          return v.copyWith(isActive: v.id == vehicle.id);
        }).toList();
        _vehicles = _sortVehicles(_vehicles);
      });

      if (showToast && mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${vehicle.name} set as active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        // Auto-dismiss after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.of(context, rootNavigator: true).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error switching vehicle: $e');
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

  void _showVehicleMenu(VehicleProfile vehicle) {
    final isActive = vehicle.id == _activeVehicle?.id;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF667EEA)),
              title: const Text('Edit Vehicle', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _editVehicle(vehicle);
              },
            ),
            
            if (!isActive)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                title: const Text('Set as Active', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _setActiveVehicle(vehicle, showToast: true);
                },
              ),
            
            const Divider(color: Color(0xFF2A2A2A)),
            
            if (!isActive)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Vehicle', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteVehicle(vehicle);
                },
              ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVehicle(VehicleProfile vehicle) async {
    final stats = _vehicleStats[vehicle.id];
    final fillupCount = stats?.totalFillups ?? 0;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Vehicle?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will delete "${vehicle.name}"${fillupCount > 0 ? ' and all $fillupCount fill-up record${fillupCount == 1 ? '' : 's'}' : ''}. This cannot be undone.',
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
            child: const Text(
              'DELETE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.red, width: 2),
              ),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.red, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${vehicle.name} deleted',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          // Auto-dismiss after 1.5 seconds
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.of(context, rootNavigator: true).pop();
          });
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error deleting vehicle: $e');
        }
      }
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'SORT VEHICLES BY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSortOption('Active First', 'active'),
            _buildSortOption('Newest First', 'newest'),
            _buildSortOption('Most Fill-ups', 'fillups'),
            _buildSortOption('Name (A-Z)', 'name'),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? const Color(0xFF667EEA) : Colors.white.withOpacity(0.5),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _sortBy = value;
          _vehicles = _sortVehicles(_vehicles);
        });
        Navigator.pop(context);
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
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

  Widget _buildTutorialOverlay() {
    return GestureDetector(
      onTap: _markTutorialSeen,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: SafeArea(
          child: Stack(
            children: [
              // Swipe left hint
              Positioned(
                top: 300,
                left: 0,
                right: 0,
                child: _buildSwipeHint(
                  'Swipe left to edit',
                  Icons.arrow_back,
                  Alignment.centerRight,
                  const Color(0xFF667EEA),
                ),
              ),
              
              // Swipe right hint
              Positioned(
                top: 400,
                left: 0,
                right: 0,
                child: _buildSwipeHint(
                  'Swipe right to set active',
                  Icons.arrow_forward,
                  Alignment.centerLeft,
                  const Color(0xFF10B981),
                ),
              ),
              
              // Long press hint
              Positioned(
                top: 500,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF59E0B),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: Color(0xFFF59E0B),
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Long press for more options',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Tap to dismiss hint
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Text(
                      'TAP ANYWHERE TO CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeHint(String text, IconData icon, Alignment alignment, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: color, size: 40),
          ] else ...[
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}