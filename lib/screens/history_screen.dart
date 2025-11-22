// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';
import 'package:intl/intl.dart';
import 'fillup_detail_screen.dart';
import 'edit_fillup_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

// Expose state class so main.dart can call refresh
class HistoryScreenState extends State<HistoryScreen> {
  VehicleProfile? _activeVehicle;
  List<FillupRecord> _fillups = [];
  FuelStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Public method to refresh data from outside
  void refreshData() {
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
        top: false, // App bar handles top spacing
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
                          padding: const EdgeInsets.only(top: 120),
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
          
          // FIX: Get previous fillup from the main _fillups list, not the month's fillups
          final fillupIndexInMain = _fillups.indexOf(fillup);
          final previousFillup = fillupIndexInMain < _fillups.length - 1
              ? _fillups[fillupIndexInMain + 1]
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
    
    return Dismissible(
      key: Key(fillup.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Edit
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditFillupScreen(fillup: fillup),
            ),
          );
          if (result == true) {
            await _loadData();
          }
          return false; // Don't dismiss
        } else {
          // Swipe left - Delete
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Delete Fill-Up?',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'This will permanently delete this fill-up record. This cannot be undone.',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
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
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 32,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete was confirmed
          try {
            await DatabaseService.instance.deleteFillup(fillup.id);
            await _loadData(); // Reload data after deletion
          } catch (e) {
            debugPrint('Error deleting fill-up: $e');
            if (mounted) {
              await _loadData(); // Reload to restore the item
            }
          }
        }
      },
      child: Container(
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
      ),
    );
  }

  Future<void> _showFillupDetails(FillupRecord fillup, double mpg) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FillupDetailScreen(
          fillup: fillup,
          mpg: mpg,
        ),
      ),
    );
    
    // If deleted, reload data
    if (result == true) {
      await _loadData();
    }
  }
}