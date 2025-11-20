// lib/screens/add_fillup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';

class AddFillupScreen extends StatefulWidget {
  final Map<String, dynamic>? prefillData;
  
  const AddFillupScreen({super.key, this.prefillData});

  @override
  State<AddFillupScreen> createState() => _AddFillupScreenState();
}

class _AddFillupScreenState extends State<AddFillupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _dteBeforeController = TextEditingController();
  final _dteAfterController = TextEditingController();
  final _gallonsController = TextEditingController();
  final _costController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  double _cityPercent = 50.0;
  bool _isFullTank = true;
  String _fuelGrade = '87 Regular';
  String _paymentMethod = 'Card';
  bool _isLoading = false;
  VehicleProfile? _activeVehicle;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    _loadActiveVehicle();
    
    // Prefill data from receipt scanner if available
    if (widget.prefillData != null) {
      _prefillFromReceipt();
    }
  }

  Future<void> _loadActiveVehicle() async {
    final vehicle = await DatabaseService.instance.getActiveVehicle();
    setState(() {
      _activeVehicle = vehicle;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _prefillFromReceipt() {
    final data = widget.prefillData!;
    
    debugPrint('=== PREFILLING FROM RECEIPT ===');
    debugPrint('Prefill data: $data');
    
    if (data['date'] != null && data['date'] is DateTime) {
      setState(() {
        _selectedDate = data['date'];
        _dateController.text = _formatDate(_selectedDate);
      });
      debugPrint('Prefilled date: ${data['date']}');
    }
    
    if (data['gallons'] != null) {
      _gallonsController.text = data['gallons'].toString();
      debugPrint('Prefilled gallons: ${data['gallons']}');
    }
    
    if (data['totalCost'] != null) {
      _costController.text = data['totalCost'].toString();
      debugPrint('Prefilled cost: ${data['totalCost']}');
    }
    
    if (data['location'] != null) {
      _locationController.text = data['location'];
      debugPrint('Prefilled location: ${data['location']}');
    }
    
    if (data['fuelGrade'] != null) {
      setState(() {
        _fuelGrade = data['fuelGrade'];
      });
      debugPrint('Prefilled fuel grade: ${data['fuelGrade']}');
    }
    
    if (data['paymentMethod'] != null) {
      setState(() {
        _paymentMethod = data['paymentMethod'];
      });
      debugPrint('Prefilled payment method: ${data['paymentMethod']}');
    }
    
    debugPrint('=== PREFILL COMPLETE ===');
  }

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
        top: false, // App bar handles top spacing
        child: Material(
          color: const Color(0xFF000000),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 130, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success banner if prefilled from receipt
                  if (widget.prefillData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RECEIPT SCANNED',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Review and fill in remaining details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Active Vehicle Display
                  if (_activeVehicle != null) _buildActiveVehicleCard(),
                  if (_activeVehicle != null) const SizedBox(height: 24),
                  
                  // Feature Highlight
                  _buildFeatureHighlight(),
                  const SizedBox(height: 24),
                  
                  // Date Field
                  _buildSectionTitle('Fill-Up Date'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dateController,
                        label: 'Date',
                        hint: 'Select date',
                        suffix: Icons.calendar_today,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Odometer Reading
                  _buildSectionTitle('Odometer Reading'),
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
                  _buildSectionTitle('Distance to Empty (Optional)'),
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
                  _buildSectionTitle('Fuel Details'),
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
                  _buildSectionTitle('Driving Split'),
                  const SizedBox(height: 12),
                  _buildCityHighwaySlider(),
                  const SizedBox(height: 24),
                  
                  // Fill Type
                  _buildSectionTitle('Fill Type'),
                  const SizedBox(height: 12),
                  _buildFillTypeToggle(),
                  const SizedBox(height: 24),
                  
                  // Additional Details
                  _buildSectionTitle('Additional Details'),
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
                      onPressed: _isLoading ? null : _saveFillup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF667EEA).withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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

  Widget _buildActiveVehicleCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRACKING FOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _activeVehicle!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    dynamic suffix, // Can be String or IconData
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
              suffixText: suffix is String ? suffix : null,
              suffixIcon: suffix is IconData ? Icon(suffix, color: const Color(0xFF667EEA)) : null,
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
          Text('â€¢ ', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
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

  Future<void> _saveFillup() async {
    if (_activeVehicle == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('No Active Vehicle', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Please add a vehicle first.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF667EEA))),
            ),
          ],
        ),
      );
      return;
    }

    if (_odometerController.text.isEmpty || _gallonsController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Missing Information', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Please enter odometer reading and gallons',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF667EEA))),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentOdo = double.parse(_odometerController.text);
      final gallons = double.parse(_gallonsController.text);
      final cost = _costController.text.isNotEmpty 
          ? double.parse(_costController.text) 
          : 0.0;

      // Create fillup record
      final fillup = FillupRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: _activeVehicle!.id,
        date: _selectedDate, // Use selected date instead of now
        odometer: currentOdo,
        dteBeforeFillup: _dteBeforeController.text.isNotEmpty 
            ? double.tryParse(_dteBeforeController.text) 
            : null,
        dteAfterFillup: _dteAfterController.text.isNotEmpty 
            ? double.tryParse(_dteAfterController.text) 
            : null,
        gallons: gallons,
        totalCost: cost,
        cityDrivingPercent: _cityPercent,
        isFullTank: _isFullTank,
        fuelGrade: _fuelGrade,
        location: _locationController.text.isNotEmpty 
            ? _locationController.text 
            : null,
        paymentMethod: _paymentMethod,
      );

      // Save to database
      await DatabaseService.instance.createFillup(fillup);

      // Get previous fillup to calculate MPG
      final fillups = await DatabaseService.instance.getFillupsByVehicle(_activeVehicle!.id);
      final previousFillup = fillups.length > 1 ? fillups[1] : null;

      // Calculate MPG
      final mpg = fillup.calculateMPG(previousFillup);
      
      // Optional: DTE-based efficiency estimate
      final estimatedMPG = fillup.estimateCurrentMPG();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text('Fill-up Saved!', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mpg > 0) ...[
                  Text(
                    'Tank-to-Tank MPG: ${mpg.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (previousFillup != null)
                    Text(
                      'Based on ${(currentOdo - previousFillup.odometer).toStringAsFixed(1)} miles driven',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                ] else ...[
                  Text(
                    'Fill-up recorded!',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MPG will be calculated after your next full tank fill-up.',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                ],
                if (estimatedMPG != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2A2A2A)),
                  const SizedBox(height: 12),
                  Text(
                    'DTE Estimate: ${estimatedMPG.toStringAsFixed(1)} MPG',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text('OK', style: TextStyle(color: Color(0xFF667EEA))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: Text(
              'Error saving fill-up: $e',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Color(0xFF667EEA))),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _odometerController.dispose();
    _dteBeforeController.dispose();
    _dteAfterController.dispose();
    _gallonsController.dispose();
    _costController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}