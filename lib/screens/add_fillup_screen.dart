// lib/screens/add_fillup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

class AddFillupScreen extends StatefulWidget {
  const AddFillupScreen({super.key});

  @override
  State<AddFillupScreen> createState() => _AddFillupScreenState();
}

class _AddFillupScreenState extends State<AddFillupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _dteBeforeController = TextEditingController();
  final _dteAfterController = TextEditingController();
  final _gallonsController = TextEditingController();
  final _costController = TextEditingController();
  final _locationController = TextEditingController();
  
  double _cityPercent = 50.0;
  bool _isFullTank = true;
  String _fuelGrade = '87 Regular';
  String _paymentMethod = 'Card';

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'New Fill-Up',
        useNativeToolbar: true,
        actions: [
          AdaptiveAppBarAction(
            onPressed: _saveFillup,
            iosSymbol: 'checkmark',
            icon: Icons.check,
          ),
        ],
      ),
      body: SafeArea(
        child: Material(
          color: const Color(0xFF000000),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature Highlight
                  _buildFeatureHighlight(),
                  const SizedBox(height: 24),
                  
                  // Odometer Reading
                  _buildSectionTitle('📍 Odometer Reading'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _odometerController,
                    label: 'Current Odometer',
                    hint: 'e.g., 4686',
                    keyboardType: TextInputType.number,
                    suffix: 'miles',
                  ),
                  const SizedBox(height: 24),
                  
                  // DTE Section (Optional)
                  _buildSectionTitle('📊 Distance to Empty (Optional)'),
                  const SizedBox(height: 8),
                  _buildInfoBox(
                    'Real-Time Monitoring',
                    'DTE helps track efficiency between fill-ups and predict your range. Not required for accurate MPG calculations.',
                    const Color(0xFF667EEA),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _dteBeforeController,
                    label: 'DTE Before Fill-Up (Optional)',
                    hint: 'e.g., 45 miles remaining',
                    keyboardType: TextInputType.number,
                    suffix: 'mi',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _dteAfterController,
                    label: 'DTE After Fill-Up (Optional)',
                    hint: 'e.g., 425 miles on full tank',
                    keyboardType: TextInputType.number,
                    suffix: 'mi',
                  ),
                  const SizedBox(height: 24),
                  
                  // Fuel Details
                  _buildSectionTitle('⛽ Fuel Details'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _gallonsController,
                          label: 'Gallons',
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          suffix: 'gal',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _costController,
                          label: 'Total Cost',
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          prefix: '\$',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // City/Highway Split
                  _buildSectionTitle('🚗 Driving Split'),
                  const SizedBox(height: 12),
                  _buildCityHighwaySlider(),
                  const SizedBox(height: 24),
                  
                  // Fill Type
                  _buildSectionTitle('⛽ Fill Type'),
                  const SizedBox(height: 12),
                  _buildFillTypeToggle(),
                  const SizedBox(height: 24),
                  
                  // Additional Details
                  _buildSectionTitle('📝 Additional Details'),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Fuel Grade',
                    value: _fuelGrade,
                    items: ['87 Regular', '89 Plus', '91 Premium', '93 Premium', 'Diesel', 'E85'],
                    onChanged: (value) => setState(() => _fuelGrade = value!),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location (Optional)',
                    hint: 'Gas station name',
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Payment Method',
                    value: _paymentMethod,
                    items: ['Card', 'Cash', 'App'],
                    onChanged: (value) => setState(() => _paymentMethod = value!),
                  ),
                  const SizedBox(height: 24),
                  
                  // Advanced Features Info
                  _buildAdvancedFeaturesInfo(),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveFillup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF667EEA).withOpacity(0.4),
                      ),
                      child: const Text(
                        'CALCULATE & SAVE FILL-UP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.star, color: Color(0xFF667EEA), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACCURATE TRACKING',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'For best accuracy, always fill tank completely. Partial fills are tracked separately.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? prefix,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixText: prefix,
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String title, String description, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityHighwaySlider() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${_cityPercent.toInt()}% City / ${(100 - _cityPercent).toInt()}% Highway',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          Slider(
            value: _cityPercent,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: const Color(0xFF667EEA),
            inactiveColor: const Color(0xFF2A2A2A),
            onChanged: (value) {
              setState(() {
                _cityPercent = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFillTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleOption('Full Tank', _isFullTank, () {
            setState(() => _isFullTank = true);
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleOption('Partial', !_isFullTank, () {
            setState(() => _isFullTank = false);
          }),
        ),
      ],
    );
  }

  Widget _buildToggleOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : const Color(0xFF2A2A2A),
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFeaturesInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFF667EEA), size: 20),
              SizedBox(width: 8),
              Text(
                'SMART FEATURES',
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFeatureItem('Real-time MPG monitoring with DTE'),
          _buildFeatureItem('Weather impact tracking'),
          _buildFeatureItem('Route efficiency comparison'),
          _buildFeatureItem('Driving style insights'),
          _buildFeatureItem('Maintenance alerts from efficiency drops'),
          _buildFeatureItem('Cost forecasting and budgeting'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveFillup() {
    if (_odometerController.text.isEmpty ||
        _gallonsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter odometer reading and gallons'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate MPG using tank-to-tank method
    final currentOdo = double.parse(_odometerController.text);
    final gallons = double.parse(_gallonsController.text);
    
    // Mock previous data for demo
    final lastOdo = 4300.0;
    
    // Simple, accurate tank-to-tank calculation
    final mpg = (currentOdo - lastOdo) / gallons;
    
    // Optional: DTE-based efficiency estimate
    String dteMessage = '';
    if (_dteAfterController.text.isNotEmpty) {
      final dteAfter = double.parse(_dteAfterController.text);
      final estimatedMPG = dteAfter / gallons;
      dteMessage = '\n\nDTE Estimate: ${estimatedMPG.toStringAsFixed(1)} MPG';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Fill-up Saved!', style: TextStyle(color: Colors.white)),
        content: Text(
          'Calculated MPG: ${mpg.toStringAsFixed(1)}'
          '\nBased on ${(currentOdo - lastOdo).toStringAsFixed(1)} miles driven'
          '$dteMessage',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF667EEA))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _dteBeforeController.dispose();
    _dteAfterController.dispose();
    _gallonsController.dispose();
    _costController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}