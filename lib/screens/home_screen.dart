// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:path_provider/path_provider.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';
import '../screens/add_vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VehicleProfile? _activeVehicle;
  FuelStats? _stats;
  List<FillupRecord> _recentFillups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = await DatabaseService.instance.getActiveVehicle();
      
      if (vehicle != null) {
        final stats = await DatabaseService.instance.calculateStats(vehicle.id);
        final fillups = await DatabaseService.instance.getFillupsByVehicle(vehicle.id);
        
        setState(() {
          _activeVehicle = vehicle;
          _stats = stats;
          _recentFillups = fillups.take(3).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getFullImagePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/vehicle_images/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: '',
        useNativeToolbar: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF667EEA),
                ),
              )
            : _activeVehicle == null
                ? _buildEmptyState()
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Vehicle name and mileage
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _activeVehicle!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Odometer â€¢ ${_stats?.totalMiles.toStringAsFixed(0) ?? '0'} mi',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Vehicle Image Display (Toyota-style)
                            _buildVehicleDisplay(),
                            
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          color: const Color(0xFF000000),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeaturedCard(),
                              const SizedBox(height: 16),
                              _buildStatsGrid(),
                              const SizedBox(height: 24),
                              _buildQuickInsights(),
                              const SizedBox(height: 24),
                              _buildRecentActivity(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildVehicleDisplay() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Vehicle Image
          if (_activeVehicle?.imagePath != null)
            FutureBuilder<String>(
              future: _getFullImagePath(_activeVehicle!.imagePath!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final imageFile = File(snapshot.data!);
                  if (imageFile.existsSync()) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderVehicle();
                          },
                        ),
                      ),
                    );
                  }
                }
                return _buildPlaceholderVehicle();
              },
            )
          else
            _buildPlaceholderVehicle(),
          
          // Info button overlay (bottom center)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddVehicleScreen(vehicle: _activeVehicle),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF667EEA),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Info',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderVehicle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 100,
            color: const Color(0xFF667EEA).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Add vehicle photo in Garage',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
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
              'No Active Vehicle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a vehicle in the Garage to start tracking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    final trueMPG = _stats?.trueMPG ?? 0.0;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'COMBINED MPG',
                style: TextStyle(
                  color: Color(0xFF8B9DC3),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TANK-TO-TANK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            trueMPG > 0 ? trueMPG.toStringAsFixed(1) : '--',
            style: const TextStyle(
              color: Color(0xFF667EEA),
              fontSize: 64,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trueMPG > 0
                ? 'Accurate tank-to-tank measurement'
                : 'Add fill-ups to calculate MPG',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'AVG MPG',
          _stats?.averageMPG.toStringAsFixed(1) ?? '--',
          'Overall average',
          Icons.speed,
        ),
        _buildStatCard(
          'BEST MPG',
          _stats?.bestMPG.toStringAsFixed(1) ?? '--',
          'Personal record',
          Icons.emoji_events,
        ),
        _buildStatCard(
          'FUEL COST',
          '\$${_stats?.totalCost.toStringAsFixed(0) ?? '0'}',
          '${_stats?.totalGallons.toStringAsFixed(0) ?? '0'} gallons',
          Icons.attach_money,
        ),
        _buildStatCard(
          'COST/MILE',
          '\$${_stats?.averageCostPerMile.toStringAsFixed(2) ?? '0.00'}',
          _stats != null && _stats!.averageCostPerMile < 0.12
              ? 'Efficient!'
              : 'Track more',
          Icons.trending_down,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInsights() {
    final cityPercent = _stats?.cityDrivingPercent ?? 0.0;
    final epaComparison = _activeVehicle?.epaCombined != null && _stats != null
        ? _stats!.trueMPG - _activeVehicle!.epaCombined!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (_stats != null && _stats!.totalFillups > 0) ...[
          _buildInsightCard(
            'ðŸŽ¯ Driving Efficiency',
            '${cityPercent.toStringAsFixed(0)}% city / ${(100 - cityPercent).toStringAsFixed(0)}% highway',
            cityPercent > 70
                ? 'Mostly city driving'
                : cityPercent < 30
                    ? 'Mostly highway driving'
                    : 'Balanced driving mix',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          if (epaComparison != null)
            _buildInsightCard(
              'ðŸ“Š Compared to EPA',
              epaComparison > 0
                  ? '+${epaComparison.toStringAsFixed(1)} MPG above rating'
                  : '${epaComparison.toStringAsFixed(1)} MPG below rating',
              epaComparison > 0
                  ? 'You\'re beating the EPA estimate!'
                  : 'Try to match the EPA rating',
              const Color(0xFF667EEA),
            ),
          if (epaComparison != null) const SizedBox(height: 12),
          _buildInsightCard(
            'ðŸ’¡ Total Fill-Ups',
            '${_stats!.totalFillups} recorded',
            'Keep tracking for better insights!',
            const Color(0xFFF59E0B),
          ),
        ] else ...[
          _buildInsightCard(
            'ðŸš€ Get Started',
            'No fill-ups yet',
            'Add your first fill-up to start tracking!',
            const Color(0xFF667EEA),
          ),
        ],
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, String detail, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Fill-Ups',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (_recentFillups.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No fill-ups yet. Tap + to add your first!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...List.generate(_recentFillups.length, (index) {
            final fillup = _recentFillups[index];
            final previousFillup = index < _recentFillups.length - 1
                ? _recentFillups[index + 1]
                : null;
            final mpg = fillup.calculateMPG(previousFillup);

            return Padding(
              padding: EdgeInsets.only(bottom: index < _recentFillups.length - 1 ? 12 : 0),
              child: _buildActivityItem(
                fillup.date,
                fillup.gallons,
                fillup.totalCost,
                fillup.location,
                mpg,
                fillup.isFullTank,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActivityItem(
    DateTime date,
    double gallons,
    double cost,
    String? location,
    double mpg,
    bool isFullTank,
  ) {
    final dateStr = '${date.month}/${date.day}/${date.year}';
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${gallons.toStringAsFixed(1)} gal â€¢ \$${cost.toStringAsFixed(2)}${location != null ? ' â€¢ $location' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isFullTank ? Icons.local_gas_station : Icons.warning,
                      size: 14,
                      color: isFullTank
                          ? const Color(0xFF10B981)
                          : const Color(0xFDF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFullTank ? 'Full Tank' : 'Partial Fill',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFullTank
                            ? const Color(0xFF10B981)
                            : const Color(0xFDF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                mpg > 0 ? mpg.toStringAsFixed(1) : '--',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              Text(
                'MPG',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}