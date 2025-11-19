// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Statistics',
        useNativeToolbar: true,
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFF000000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
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
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
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
              _buildOverallStatItem('1,947', 'Total Miles', Icons.straighten),
              _buildOverallStatItem('69', 'Gallons', CupertinoIcons.drop_fill),
              _buildOverallStatItem('\$235', 'Total Cost', Icons.attach_money),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverallStatItem('7', 'Fill-Ups', Icons.local_gas_station),
              _buildOverallStatItem('32.7', 'Avg MPG', Icons.speed),
              _buildOverallStatItem('\$0.11', 'Cost/Mile', Icons.payments),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+2.4 MPG vs EPA',
                  style: TextStyle(
                    color: Color(0xFF10B981),
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
            child: CustomPaint(
              size: Size.infinite,
              painter: LineChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'May 2025',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
              ),
              Text(
                'Nov 2025',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
              ),
            ],
          ),
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
              _buildCostItem('\$3.40', 'Avg Price/Gal', const Color(0xFF667EEA)),
              _buildCostItem('\$33.57', 'Avg Fill-up', const Color(0xFF667EEA)),
              _buildCostItem('\$0.105', 'Cost/Mile', const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 24),
          _buildCostBar('Fuel', 235, 100, const Color(0xFF667EEA)),
          const SizedBox(height: 12),
          _buildCostBar('Maintenance', 0, 100, const Color(0xFF667EEA)),
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
              _buildPieSection('City', 78, const Color(0xFF667EEA)),
              _buildPieSection('Highway', 22, const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 24),
          _buildDrivingStatRow('Best City MPG', '34.8', Icons.location_city),
          Divider(height: 24, color: Colors.white.withOpacity(0.2)),
          _buildDrivingStatRow('Best Highway MPG', '39.2', Icons.directions_car),
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
    return Column(
      children: [
        _buildInsightCard(
          '🎯 Efficiency Trend',
          'Your MPG has improved by 8% over the last 3 months',
          'Keep maintaining your vehicle and driving habits!',
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          '💰 Cost Optimization',
          'You\'re spending 15% less than the average driver',
          'Your efficient driving saves ~\$47/month',
          const Color(0xFF667EEA),
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          '📈 Best Performance',
          'Your best efficiency was on Sep 21, 2025',
          '36.0 MPG - mostly highway driving',
          const Color(0xFFF59E0B),
        ),
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
  @override
  void paint(Canvas canvas, Size size) {
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

    // Sample data points (MPG values)
    final points = [31.3, 34.8, 32.0, 29.7, 32.7, 36.0];
    final spacing = size.width / (points.length - 1);

    // Normalize points to fit in chart
    final maxMpg = 40.0;
    final minMpg = 25.0;
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}