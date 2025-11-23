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

class HistoryScreenState extends State<HistoryScreen> {
  VehicleProfile? _activeVehicle;
  List<FillupRecord> _fillups = [];
  FuelStats? _stats;
  bool _isLoading = true;
  String _sortBy = 'date'; // 'date', 'mpg', 'cost'
  bool _showFullTankOnly = false;
  Map<String, bool> _expandedMonths = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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

  List<FillupRecord> get _filteredFillups {
    var filtered = _fillups;
    
    if (_showFullTankOnly) {
      filtered = filtered.where((f) => f.isFullTank).toList();
    }
    
    switch (_sortBy) {
      case 'mpg':
        filtered.sort((a, b) {
          final aMpg = a.calculateMPG(_fillups[_fillups.indexOf(a) + 1 < _fillups.length ? _fillups.indexOf(a) + 1 : 0]);
          final bMpg = b.calculateMPG(_fillups[_fillups.indexOf(b) + 1 < _fillups.length ? _fillups.indexOf(b) + 1 : 0]);
          return bMpg.compareTo(aMpg);
        });
        break;
      case 'cost':
        filtered.sort((a, b) => b.totalCost.compareTo(a.totalCost));
        break;
      case 'date':
      default:
        // Already sorted by date DESC from database
        break;
    }
    
    return filtered;
  }

  Map<String, List<FillupRecord>> _groupByMonth() {
    final Map<String, List<FillupRecord>> grouped = {};
    
    for (final fillup in _filteredFillups) {
      final monthKey = DateFormat('MMMM yyyy').format(fillup.date);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
        // Only set default to true if not already set
        if (!_expandedMonths.containsKey(monthKey)) {
          _expandedMonths[monthKey] = true;
        }
      }
      grouped[monthKey]!.add(fillup);
    }
    
    return grouped;
  }

  Map<String, dynamic> _calculateMonthStats(List<FillupRecord> monthFillups) {
    double totalCost = 0;
    double totalGallons = 0;
    List<double> mpgValues = [];
    
    for (int i = 0; i < monthFillups.length; i++) {
      final current = monthFillups[i];
      totalCost += current.totalCost;
      totalGallons += current.gallons;
      
      // Find previous fillup from main list
      final mainIndex = _fillups.indexOf(current);
      if (mainIndex < _fillups.length - 1) {
        final previous = _fillups[mainIndex + 1];
        final mpg = current.calculateMPG(previous);
        if (mpg > 0) {
          mpgValues.add(mpg);
        }
      }
    }
    
    return {
      'avgMpg': mpgValues.isNotEmpty ? mpgValues.reduce((a, b) => a + b) / mpgValues.length : 0.0,
      'totalCost': totalCost,
      'totalGallons': totalGallons,
      'fillupCount': monthFillups.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Fill-Up History',
        useNativeToolbar: true,
        actions: [
          AdaptiveAppBarAction(
            onPressed: _showFilterSheet,
            iosSymbol: 'line.3.horizontal.decrease.circle',
            icon: Icons.filter_list,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
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
                            const SizedBox(height: 16),
                            if (_sortBy != 'date' || _showFullTankOnly)
                              _buildActiveFilters(),
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

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          if (_sortBy != 'date')
            Chip(
              label: Text(
                'Sort: ${_sortBy == 'mpg' ? 'MPG' : 'Cost'}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _sortBy = 'date'),
              backgroundColor: const Color(0xFF667EEA),
              labelStyle: const TextStyle(color: Colors.white),
            ),
          if (_showFullTankOnly)
            Chip(
              label: const Text('Full Tanks Only', style: TextStyle(fontSize: 12)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _showFullTankOnly = false),
              backgroundColor: const Color(0xFF10B981),
              labelStyle: const TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'SORT BY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildFilterOption(
                'Date (Newest First)',
                _sortBy == 'date',
                () {
                  setState(() => _sortBy = 'date');
                  setModalState(() {});
                },
              ),
              _buildFilterOption(
                'MPG (Highest First)',
                _sortBy == 'mpg',
                () {
                  setState(() => _sortBy = 'mpg');
                  setModalState(() {});
                },
              ),
              _buildFilterOption(
                'Cost (Highest First)',
                _sortBy == 'cost',
                () {
                  setState(() => _sortBy = 'cost');
                  setModalState(() {});
                },
              ),
              
              const SizedBox(height: 24),
              const Text(
                'FILTER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              SwitchListTile(
                title: const Text(
                  'Full Tanks Only',
                  style: TextStyle(color: Colors.white),
                ),
                value: _showFullTankOnly,
                activeColor: const Color(0xFF10B981),
                onChanged: (value) {
                  setState(() => _showFullTankOnly = value);
                  setModalState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
          ],
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

    // Get last 6 fillups for mini chart (with actual MPG values)
    final recentFillups = _fillups.take(7).toList().reversed.toList();
    List<double> mpgValues = [];
    
    for (int i = 0; i < recentFillups.length - 1; i++) {
      final current = recentFillups[i + 1];
      final previous = recentFillups[i];
      final mpg = current.calculateMPG(previous);
      if (mpg > 0) {
        mpgValues.add(mpg);
      }
    }
    
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
          if (mpgValues.length >= 2) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                mpgValues.length,
                (index) {
                  final mpg = mpgValues[index];
                  
                  // Normalize height based on best MPG
                  final maxMpg = mpgValues.reduce((a, b) => a > b ? a : b);
                  final minMpg = mpgValues.reduce((a, b) => a < b ? a : b);
                  final range = maxMpg - minMpg;
                  
                  final height = range > 0
                      ? ((mpg - minMpg) / range * 30 + 20).clamp(20.0, 50.0)
                      : 35.0;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
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
      width: 32,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF667EEA).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  List<Widget> _buildMonthSections() {
    final groupedFillups = _groupByMonth();
    final List<Widget> sections = [];
    
    groupedFillups.forEach((month, fillups) {
      final stats = _calculateMonthStats(fillups);
      sections.add(_buildMonthSection(month, fillups, stats));
      sections.add(const SizedBox(height: 24));
    });
    
    sections.add(const SizedBox(height: 84));
    
    return sections;
  }

  Widget _buildMonthSection(String month, List<FillupRecord> fillups, Map<String, dynamic> stats) {
    final isExpanded = _expandedMonths[month] ?? true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Header with gradient separator
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF667EEA).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expandedMonths[month] = !(_expandedMonths[month] ?? true);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          month,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF667EEA),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
        
        // Monthly Summary Card
        if (isExpanded) ...[
          _buildMonthlySummary(stats),
          const SizedBox(height: 16),
          
          // Fill-up cards
          ...List.generate(fillups.length, (index) {
            final fillup = fillups[index];
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
      ],
    );
  }

  Widget _buildMonthlySummary(Map<String, dynamic> stats) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Avg MPG',
              stats['avgMpg'] > 0 ? stats['avgMpg'].toStringAsFixed(1) : '--',
              Icons.speed,
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFF2A2A2A)),
          Expanded(
            child: _buildSummaryItem(
              'Total Cost',
              '\$${stats['totalCost'].toStringAsFixed(2)}',
              Icons.attach_money,
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFF2A2A2A)),
          Expanded(
            child: _buildSummaryItem(
              'Fill-Ups',
              '${stats['fillupCount']}',
              Icons.local_gas_station,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildFillupItem(FillupRecord fillup, double mpg) {
    final dateStr = DateFormat('MMM d, yyyy').format(fillup.date);
    
    return Dismissible(
      key: Key(fillup.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditFillupScreen(fillup: fillup),
            ),
          );
          if (result == true) {
            await _loadData();
          }
          return false;
        } else {
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
          try {
            await DatabaseService.instance.deleteFillup(fillup.id);
            await _loadData();
          } catch (e) {
            debugPrint('Error deleting fill-up: $e');
            if (mounted) {
              await _loadData();
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showFillupDetails(fillup, mpg),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667EEA),
                          const Color(0xFF667EEA).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.drop_fill,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${fillup.gallons.toStringAsFixed(1)} gal',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Text(
                              '\$${fillup.totalCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            if (fillup.location != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  fillup.location!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: fillup.isFullTank
                                ? const Color(0xFF10B981).withOpacity(0.2)
                                : const Color(0xFFF59E0B).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: fillup.isFullTank
                                  ? const Color(0xFF10B981).withOpacity(0.4)
                                  : const Color(0xFFF59E0B).withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                fillup.isFullTank ? Icons.local_gas_station : Icons.warning_rounded,
                                size: 12,
                                color: fillup.isFullTank
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                fillup.isFullTank ? 'Full Tank' : 'Partial',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: fillup.isFullTank
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
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
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MPG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 0.5,
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
    // Get previous fillup for calculations
    final fillupIndex = _fillups.indexOf(fillup);
    final previousFillup = fillupIndex < _fillups.length - 1
        ? _fillups[fillupIndex + 1]
        : null;
    
    final milesDriven = previousFillup != null 
        ? fillup.odometer - previousFillup.odometer 
        : 0.0;
    
    final costPerMile = milesDriven > 0 
        ? fillup.totalCost / milesDriven 
        : 0.0;
    
    // Calculate average price per gallon from all fillups for comparison
    final avgPricePerGallon = _stats?.averageCostPerGallon ?? 0.0;
    final priceComparison = avgPricePerGallon > 0 
        ? fillup.pricePerGallon - avgPricePerGallon 
        : 0.0;
    
    // Calculate MPG comparison to average
    final avgMPG = _stats?.averageMPG ?? 0.0;
    final mpgComparison = avgMPG > 0 && mpg > 0
        ? mpg - avgMPG
        : 0.0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUICK STATS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667EEA),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy').format(fillup.date),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FillupDetailScreen(
                                fillup: fillup,
                                mpg: mpg,
                              ),
                            ),
                          );
                          if (result == true) {
                            await _loadData();
                          }
                        },
                        icon: const Icon(
                          Icons.open_in_full,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // MPG Section
                  if (mpg > 0) ...[
                    _buildQuickStatRow(
                      'Fuel Efficiency',
                      '${mpg.toStringAsFixed(1)} MPG',
                      Icons.speed,
                      const Color(0xFF667EEA),
                      subtitle: mpgComparison != 0
                          ? '${mpgComparison > 0 ? '+' : ''}${mpgComparison.toStringAsFixed(1)} vs avg'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Miles Driven
                  if (milesDriven > 0) ...[
                    _buildQuickStatRow(
                      'Miles Driven',
                      '${milesDriven.toStringAsFixed(1)} mi',
                      Icons.straighten,
                      const Color(0xFF10B981),
                      subtitle: 'Since last fill-up',
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Cost Per Mile
                  if (costPerMile > 0) ...[
                    _buildQuickStatRow(
                      'Cost Per Mile',
                      '\$${costPerMile.toStringAsFixed(3)}',
                      Icons.attach_money,
                      const Color(0xFFF59E0B),
                      subtitle: 'For this tank',
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Price Per Gallon Comparison
                  _buildQuickStatRow(
                    'Price Per Gallon',
                    '\$${fillup.pricePerGallon.toStringAsFixed(2)}',
                    Icons.local_gas_station,
                    priceComparison > 0 ? Colors.red : const Color(0xFF10B981),
                    subtitle: priceComparison != 0
                        ? '${priceComparison > 0 ? '+' : ''}${priceComparison.toStringAsFixed(2)} vs avg'
                        : 'Average price',
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditFillupScreen(fillup: fillup),
                              ),
                            );
                            if (result == true) {
                              await _loadData();
                            }
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('EDIT'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF667EEA),
                            side: const BorderSide(color: Color(0xFF667EEA)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1A1A),
                                title: const Text(
                                  'Delete Fill-Up?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  'This will permanently delete this fill-up record.',
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
                            
                            if (confirm == true) {
                              await DatabaseService.instance.deleteFillup(fillup.id);
                              await _loadData();
                            }
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('DELETE'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStatRow(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}