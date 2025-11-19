// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  VehicleProfile? _activeVehicle;
  List<FillupRecord> _fillups = [];
  FuelStats? _stats;
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
        final fillups = await DatabaseService.instance.getFillupsByVehicle(vehicle.id);
        final stats = await DatabaseService.instance.calculateStats(vehicle.id);
        
        setState(() {
          _activeVehicle = vehicle;
          _fillups = fillups;
          _stats = stats;
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

  Map<String, List<FillupRecord>> _groupByMonth() {
    final Map<String, List<FillupRecord>> grouped = {};
    
    for (final fillup in _fillups) {
      final monthKey = DateFormat('MMMM yyyy').format(fillup.date);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(fillup);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Fill-Up History',
        useNativeToolbar: true,
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFF000000),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF667EEA),
                  ),
                )
              : _activeVehicle == null
                  ? _buildEmptyState('No Active Vehicle', 'Select a vehicle in the Garage')
                  : _fillups.isEmpty
                      ? _buildEmptyState('No Fill-Ups Yet', 'Tap + to add your first fill-up')
                      : ListView(
                          padding: const EdgeInsets.only(top: 16),
                          children: [
                            _buildRecentEfficiency(),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildMonthSections(),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
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
                Icons.history,
                size: 64,
                color: Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
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

  Widget _buildRecentEfficiency() {
    final bestMPG = _stats?.bestMPG ?? 0.0;
    final lastMPG = _fillups.length >= 2
        ? _fillups[0].calculateMPG(_fillups[1])
        : 0.0;

    // Get last 6 fillups for mini chart
    final recentFillups = _fillups.take(6).toList().reversed.toList();
    
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Recent Fuel Efficiency',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEfficiencyStat(
                'BEST MPG',
                bestMPG > 0 ? bestMPG.toStringAsFixed(1) : '--',
                const Color(0xFF10B981),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF2A2A2A)),
              _buildEfficiencyStat(
                'LAST MPG',
                lastMPG > 0 ? lastMPG.toStringAsFixed(1) : '--',
                const Color(0xFF667EEA),
              ),
            ],
          ),
          if (recentFillups.length >= 2) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                recentFillups.length >= 2 ? recentFillups.length - 1 : 0,
                (index) {
                  final fillup = recentFillups[index + 1];
                  final previous = recentFillups[index];
                  final mpg = fillup.calculateMPG(previous);
                  
                  // Normalize height (25-50 range)
                  final height = mpg > 0
                      ? ((mpg / (bestMPG > 0 ? bestMPG : 40)) * 25 + 25).clamp(25.0, 50.0)
                      : 25.0;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildBar(mpg.toInt(), height),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEfficiencyStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBar(int value, double height) {
    return Container(
      width: 40,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  List<Widget> _buildMonthSections() {
    final groupedFillups = _groupByMonth();
    final List<Widget> sections = [];
    
    groupedFillups.forEach((month, fillups) {
      sections.add(_buildMonthSection(month, fillups));
      sections.add(const SizedBox(height: 16));
    });
    
    // Add bottom padding
    sections.add(const SizedBox(height: 84));
    
    return sections;
  }

  Widget _buildMonthSection(String month, List<FillupRecord> fillups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            month,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...List.generate(fillups.length, (index) {
          final fillup = fillups[index];
          final previousFillup = index < fillups.length - 1
              ? fillups[index + 1]
              : null;
          final mpg = fillup.calculateMPG(previousFillup);
          
          return Padding(
            padding: EdgeInsets.only(bottom: index < fillups.length - 1 ? 12 : 0),
            child: _buildFillupItem(fillup, mpg),
          );
        }),
      ],
    );
  }

  Widget _buildFillupItem(FillupRecord fillup, double mpg) {
    final dateStr = DateFormat('MMM d, yyyy').format(fillup.date);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to detail screen or show details
            _showFillupDetails(fillup, mpg);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left side - Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.drop_fill,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Middle - Details
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
                        '${fillup.gallons.toStringAsFixed(1)} gal • \$${fillup.totalCost.toStringAsFixed(2)}${fillup.location != null ? ' • ${fillup.location}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            fillup.isFullTank ? Icons.local_gas_station : Icons.warning,
                            size: 14,
                            color: fillup.isFullTank
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            fillup.isFullTank ? 'Full Tank' : 'Partial Fill',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: fillup.isFullTank
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right side - MPG
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
          ),
        ),
      ),
    );
  }

  void _showFillupDetails(FillupRecord fillup, double mpg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Fill-Up Details',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Date', DateFormat('MMM d, yyyy h:mm a').format(fillup.date)),
            _buildDetailRow('Odometer', '${fillup.odometer.toStringAsFixed(1)} mi'),
            _buildDetailRow('Gallons', '${fillup.gallons.toStringAsFixed(2)} gal'),
            _buildDetailRow('Cost', '\$${fillup.totalCost.toStringAsFixed(2)}'),
            _buildDetailRow('Price/Gal', '\$${fillup.pricePerGallon.toStringAsFixed(2)}'),
            if (mpg > 0) _buildDetailRow('MPG', mpg.toStringAsFixed(1)),
            _buildDetailRow('Fuel Grade', fillup.fuelGrade),
            _buildDetailRow('Fill Type', fillup.isFullTank ? 'Full Tank' : 'Partial'),
            _buildDetailRow('City/Highway', '${fillup.cityDrivingPercent.toInt()}% / ${(100 - fillup.cityDrivingPercent).toInt()}%'),
            if (fillup.location != null) _buildDetailRow('Location', fillup.location!),
            if (fillup.paymentMethod != null) _buildDetailRow('Payment', fillup.paymentMethod!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF667EEA)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
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
      ),
    );
  }
}