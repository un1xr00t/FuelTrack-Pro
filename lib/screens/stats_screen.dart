// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => StatsScreenState();
}

// Expose state class so main.dart can call refresh
class StatsScreenState extends State<StatsScreen> {
  VehicleProfile? _activeVehicle;
  FuelStats? _stats;
  List<FillupRecord> _fillups = [];
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
        final stats = await DatabaseService.instance.calculateStats(vehicle.id);
        final fillups = await DatabaseService.instance.getFillupsByVehicle(vehicle.id);
        
        setState(() {
          _activeVehicle = vehicle;
          _stats = stats;
          _fillups = fillups;
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

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Statistics',
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
                  : _stats == null || _stats!.totalFillups == 0
                      ? _buildEmptyState('No Data Yet', 'Add fill-ups to see statistics')
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOverallStats(),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Fuel Efficiency Trend'),
                              const SizedBox(height: 16),
                              _buildEfficiencyChart(),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Cost Analysis'),
                              const SizedBox(height: 16),
                              _buildCostChart(),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Driving Breakdown'),
                              const SizedBox(height: 16),
                              _buildDrivingBreakdown(),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Insights & Trends'),
                              const SizedBox(height: 16),
                              _buildInsights(),
                              const SizedBox(height: 100),
                            ],
                          ),
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
                Icons.bar_chart,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildOverallStats() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'OVERALL STATISTICS',
            style: TextStyle(
              color: Color(0xFF8B9DC3),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverallStatItem(
                _stats!.totalMiles.toStringAsFixed(0),
                'Total Miles',
                Icons.straighten,
              ),
              _buildOverallStatItem(
                _stats!.totalGallons.toStringAsFixed(0),
                'Gallons',
                CupertinoIcons.drop_fill,
              ),
              _buildOverallStatItem(
                '\$${_stats!.totalCost.toStringAsFixed(0)}',
                'Total Cost',
                Icons.attach_money,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverallStatItem(
                _stats!.totalFillups.toString(),
                'Fill-Ups',
                Icons.local_gas_station,
              ),
              _buildOverallStatItem(
                _stats!.averageMPG.toStringAsFixed(1),
                'Avg MPG',
                Icons.speed,
              ),
              _buildOverallStatItem(
                '\$${_stats!.averageCostPerMile.toStringAsFixed(2)}',
                'Cost/Mile',
                Icons.payments,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyChart() {
    // Get MPG values from fillups
    List<double> mpgValues = [];
    for (int i = 0; i < _fillups.length - 1; i++) {
      final current = _fillups[i];
      final previous = _fillups[i + 1];
      final mpg = current.calculateMPG(previous);
      if (mpg > 0) {
        mpgValues.add(mpg);
      }
    }
    mpgValues = mpgValues.reversed.toList(); // Oldest to newest
    
    final epaComparison = _activeVehicle?.epaCombined != null
        ? _stats!.trueMPG - _activeVehicle!.epaCombined!
        : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MPG Over Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (epaComparison != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: epaComparison > 0
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${epaComparison > 0 ? '+' : ''}${epaComparison.toStringAsFixed(1)} MPG vs EPA',
                    style: TextStyle(
                      color: epaComparison > 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: mpgValues.length < 2
                ? Center(
                    child: Text(
                      'Need more fill-ups to show trend',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: LineChartPainter(mpgValues),
                  ),
          ),
          if (mpgValues.length >= 2) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oldest',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
                Text(
                  'Newest',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostChart() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Cost Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCostItem(
                '\$${_stats!.averageCostPerGallon.toStringAsFixed(2)}',
                'Avg Price/Gal',
                const Color(0xFF667EEA),
              ),
              _buildCostItem(
                '\$${(_stats!.totalCost / _stats!.totalFillups).toStringAsFixed(2)}',
                'Avg Fill-up',
                const Color(0xFF667EEA),
              ),
              _buildCostItem(
                '\$${_stats!.averageCostPerMile.toStringAsFixed(3)}',
                'Cost/Mile',
                const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCostBar('Fuel', _stats!.totalCost, _stats!.totalCost, const Color(0xFF667EEA)),
        ],
      ),
    );
  }

  Widget _buildCostItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCostBar(String label, double value, double max, Color color) {
    final percentage = (value / max * 100).clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: const Color(0xFF2A2A2A),
            color: color,
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDrivingBreakdown() {
    final cityPercent = _stats!.cityDrivingPercent.toInt();
    final highwayPercent = 100 - cityPercent;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPieSection('City', cityPercent, const Color(0xFF667EEA)),
              _buildPieSection('Highway', highwayPercent, const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 24),
          if (_stats!.bestMPG > 0) ...[
            _buildDrivingStatRow('Best MPG', _stats!.bestMPG.toStringAsFixed(1), Icons.emoji_events),
            Divider(height: 24, color: Colors.white.withOpacity(0.2)),
            _buildDrivingStatRow('Worst MPG', _stats!.worstMPG.toStringAsFixed(1), Icons.trending_down),
          ],
        ],
      ),
    );
  }

  Widget _buildPieSection(String label, int percentage, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 12,
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDrivingStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
          ),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final mpgImprovement = _fillups.length >= 4
        ? _calculateMPGTrend()
        : 0.0;
    
    final epaComparison = _activeVehicle?.epaCombined != null
        ? _stats!.trueMPG - _activeVehicle!.epaCombined!
        : null;

    return Column(
      children: [
        if (mpgImprovement.abs() > 0.5)
          _buildInsightCard(
            'Ã°Å¸Å½Â¯ Efficiency Trend',
            mpgImprovement > 0
                ? 'Your MPG has improved by ${mpgImprovement.toStringAsFixed(1)}%'
                : 'Your MPG has decreased by ${mpgImprovement.abs().toStringAsFixed(1)}%',
            mpgImprovement > 0
                ? 'Keep up the great driving!'
                : 'Consider maintenance or driving adjustments',
            mpgImprovement > 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          ),
        if (mpgImprovement.abs() > 0.5) const SizedBox(height: 12),
        if (epaComparison != null && _stats!.averageCostPerMile < 0.12)
          _buildInsightCard(
            'Ã°Å¸â€™Â° Cost Optimization',
            'You\'re spending less than average',
            'Your efficient driving saves money',
            const Color(0xFF667EEA),
          ),
        if (epaComparison != null && _stats!.averageCostPerMile < 0.12) const SizedBox(height: 12),
        _buildInsightCard(
          'Ã°Å¸â€œË† Best Performance',
          'Your best efficiency: ${_stats!.bestMPG.toStringAsFixed(1)} MPG',
          _stats!.cityDrivingPercent < 50 ? 'Mostly highway driving' : 'Great city efficiency',
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  double _calculateMPGTrend() {
    if (_fillups.length < 4) return 0.0;
    
    // Compare first 2 MPG values with last 2 MPG values
    final recent1 = _fillups[0].calculateMPG(_fillups[1]);
    final recent2 = _fillups[1].calculateMPG(_fillups[2]);
    final old1 = _fillups[_fillups.length - 2].calculateMPG(_fillups[_fillups.length - 1]);
    final old2 = _fillups.length >= 4
        ? _fillups[_fillups.length - 3].calculateMPG(_fillups[_fillups.length - 2])
        : old1;
    
    if (recent1 <= 0 || recent2 <= 0 || old1 <= 0 || old2 <= 0) return 0.0;
    
    final recentAvg = (recent1 + recent2) / 2;
    final oldAvg = (old1 + old2) / 2;
    
    return ((recentAvg - oldAvg) / oldAvg) * 100;
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
            height: 60,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
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
}

class LineChartPainter extends CustomPainter {
  final List<double> points;
  
  LineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF667EEA)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF667EEA).withOpacity(0.3),
          const Color(0xFF667EEA).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final spacing = size.width / (points.length - 1);

    // Normalize points to fit in chart
    final maxMpg = points.reduce((a, b) => a > b ? a : b) + 5;
    final minMpg = points.reduce((a, b) => a < b ? a : b) - 5;
    final range = maxMpg - minMpg;

    path.moveTo(0, size.height - ((points[0] - minMpg) / range * size.height));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - ((points[0] - minMpg) / range * size.height));

    for (int i = 0; i < points.length; i++) {
      final x = i * spacing;
      final y = size.height - ((points[i] - minMpg) / range * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      fillPath.lineTo(x, y);

      // Draw data point circles
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = const Color(0xFF667EEA)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}