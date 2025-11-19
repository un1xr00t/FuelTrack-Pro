// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Fill-Up History',
        useNativeToolbar: true,
        actions: [
          AdaptiveAppBarAction(
            icon: CupertinoIcons.search,
            onPressed: () {},
          ),
          AdaptiveAppBarAction(
            icon: CupertinoIcons.slider_horizontal_3,
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFF000000),
          child: ListView(
            padding: const EdgeInsets.only(top: 60),
            children: [
              _buildRecentEfficiency(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthSection('November 2025', [
                      _buildFillupItem(
                        date: 'Nov 19, 2025',
                        gallons: 9.621,
                        cost: 31.35,
                        mpg: 36.0,
                        location: 'Shell',
                        dteCorrected: true,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildMonthSection('October 2025', [
                      _buildFillupItem(
                        date: 'Oct 21, 2025',
                        gallons: 9.621,
                        cost: 31.35,
                        mpg: 36.0,
                        location: 'Shell',
                        dteCorrected: true,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildMonthSection('September 2025', [
                      _buildFillupItem(
                        date: 'Sep 21, 2025',
                        gallons: 9.621,
                        cost: 31.35,
                        mpg: 36.0,
                        location: 'Shell',
                        dteCorrected: true,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildMonthSection('August 2025', [
                      _buildFillupItem(
                        date: 'Aug 31, 2025',
                        gallons: 8.275,
                        cost: 28.13,
                        mpg: 32.7,
                        location: 'BP',
                        dteCorrected: true,
                      ),
                      const SizedBox(height: 12),
                      _buildFillupItem(
                        date: 'Aug 12, 2025',
                        gallons: 10.506,
                        cost: 35.71,
                        mpg: 29.7,
                        location: 'Exxon',
                        dteCorrected: false,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildMonthSection('July 2025', [
                      _buildFillupItem(
                        date: 'Jul 14, 2025',
                        gallons: 10.238,
                        cost: 35.82,
                        mpg: 32.0,
                        location: 'Chevron',
                        dteCorrected: true,
                      ),
                    ]),
                    const SizedBox(height: 100), // Bottom padding for FAB
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEfficiency() {
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
              _buildEfficiencyStat('BEST MPG', '36.0', const Color(0xFF10B981)),
              Container(width: 1, height: 40, color: const Color(0xFF2A2A2A)),
              _buildEfficiencyStat('LAST MPG', '36.0', const Color(0xFF667EEA)),
            ],
          ),
          const SizedBox(height: 16),
          // Mini bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(32, 40),
              const SizedBox(width: 4),
              _buildBar(34, 42),
              const SizedBox(width: 4),
              _buildBar(36, 45),
              const SizedBox(width: 4),
              _buildBar(33, 41),
              const SizedBox(width: 4),
              _buildBar(35, 43),
              const SizedBox(width: 4),
              _buildBar(36, 45),
            ],
          ),
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

  Widget _buildMonthSection(String month, List<Widget> items) {
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
        ...items,
      ],
    );
  }

  Widget _buildFillupItem({
    required String date,
    required double gallons,
    required double cost,
    required double mpg,
    required String location,
    required bool dteCorrected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to detail screen
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
                        date,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gallons.toStringAsFixed(1)} gal • \$${cost.toStringAsFixed(2)} • $location',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            dteCorrected ? Icons.local_gas_station : Icons.warning,
                            size: 14,
                            color: dteCorrected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dteCorrected ? 'Full Tank' : 'Partial Fill',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dteCorrected
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
                      mpg.toStringAsFixed(1),
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
}