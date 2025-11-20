// lib/screens/fillup_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:intl/intl.dart';
import '../models/fillup_record.dart';
import '../services/database_service.dart';

class FillupDetailScreen extends StatelessWidget {
  final FillupRecord fillup;
  final double mpg;

  const FillupDetailScreen({
    super.key,
    required this.fillup,
    required this.mpg,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(fillup.date);
    final timeStr = DateFormat('h:mm a').format(fillup.date);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Fill-Up Details',
        useNativeToolbar: true,
        actions: [
          AdaptiveAppBarAction(
            onPressed: () => _showDeleteConfirmation(context),
            iosSymbol: 'trash',
            icon: Icons.delete,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          color: const Color(0xFF000000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 130,
              left: 16,
              right: 16,
              bottom: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Time Header
                _buildHeaderCard(dateStr, timeStr),
                const SizedBox(height: 24),

                // MPG Featured Card
                if (mpg > 0) _buildMPGCard(),
                if (mpg > 0) const SizedBox(height: 24),

                // Fill Type Badge
                _buildFillTypeCard(),
                const SizedBox(height: 24),

                // Main Stats
                const Text(
                  'FUEL DETAILS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatsGrid(),
                const SizedBox(height: 24),

                // Additional Info
                const Text(
                  'ADDITIONAL INFO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAdditionalInfo(),
                const SizedBox(height: 24),

                // DTE Info (if available)
                if (fillup.dteBeforeFillup != null || fillup.dteAfterFillup != null) ...[
                  const Text(
                    'DISTANCE TO EMPTY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDTECard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String dateStr, String timeStr) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.drop_fill,
              color: Colors.white,
              size: 32,
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
                const SizedBox(height: 4),
                Text(
                  timeStr,
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
    );
  }

  Widget _buildMPGCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'FUEL EFFICIENCY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B9DC3),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mpg.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Miles Per Gallon',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B9DC3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFillTypeCard() {
    return Container(
      decoration: BoxDecoration(
        color: fillup.isFullTank
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fillup.isFullTank
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            fillup.isFullTank ? Icons.local_gas_station : Icons.warning,
            color: fillup.isFullTank
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fillup.isFullTank ? 'FULL TANK FILL-UP' : 'PARTIAL FILL-UP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: fillup.isFullTank
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fillup.isFullTank
                      ? 'Tank filled to capacity'
                      : 'Partial fill - MPG calculated separately',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatRow(
            'Odometer',
            '${fillup.odometer.toStringAsFixed(1)} mi',
            Icons.speed,
          ),
          const Divider(height: 32, color: Color(0xFF2A2A2A)),
          _buildStatRow(
            'Gallons',
            '${fillup.gallons.toStringAsFixed(2)} gal',
            CupertinoIcons.drop_fill,
          ),
          const Divider(height: 32, color: Color(0xFF2A2A2A)),
          _buildStatRow(
            'Total Cost',
            '\$${fillup.totalCost.toStringAsFixed(2)}',
            Icons.attach_money,
          ),
          const Divider(height: 32, color: Color(0xFF2A2A2A)),
          _buildStatRow(
            'Price Per Gallon',
            '\$${fillup.pricePerGallon.toStringAsFixed(2)}',
            Icons.local_gas_station,
          ),
          const Divider(height: 32, color: Color(0xFF2A2A2A)),
          _buildStatRow(
            'Fuel Grade',
            fillup.fuelGrade,
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667EEA),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(
            'Driving Mix',
            '${fillup.cityDrivingPercent.toInt()}% City / ${(100 - fillup.cityDrivingPercent).toInt()}% Highway',
            Icons.map,
          ),
          if (fillup.location != null) ...[
            const Divider(height: 32, color: Color(0xFF2A2A2A)),
            _buildInfoRow(
              'Location',
              fillup.location!,
              Icons.location_on,
            ),
          ],
          if (fillup.paymentMethod != null) ...[
            const Divider(height: 32, color: Color(0xFF2A2A2A)),
            _buildInfoRow(
              'Payment Method',
              fillup.paymentMethod!,
              Icons.payment,
            ),
          ],
          if (fillup.temperature != null) ...[
            const Divider(height: 32, color: Color(0xFF2A2A2A)),
            _buildInfoRow(
              'Temperature',
              '${fillup.temperature!.toStringAsFixed(0)}°F',
              Icons.thermostat,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF667EEA),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDTECard() {
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
      child: Row(
        children: [
          if (fillup.dteBeforeFillup != null) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    'BEFORE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${fillup.dteBeforeFillup!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'miles',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (fillup.dteBeforeFillup != null && fillup.dteAfterFillup != null)
            Container(
              width: 1,
              height: 60,
              color: const Color(0xFF2A2A2A),
            ),
          if (fillup.dteAfterFillup != null) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    'AFTER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${fillup.dteAfterFillup!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'miles',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
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

    if (confirm == true && context.mounted) {
      try {
        await DatabaseService.instance.deleteFillup(fillup.id);
        if (context.mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } catch (e) {
        debugPrint('Error deleting fill-up: $e');
      }
    }
  }
}