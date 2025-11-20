// lib/screens/edit_fillup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';

class EditFillupScreen extends StatefulWidget {
  final FillupRecord fillup;
  
  const EditFillupScreen({super.key, required this.fillup});

  @override
  State<EditFillupScreen> createState() => _EditFillupScreenState();
}

class _EditFillupScreenState extends State<EditFillupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _odometerController;
  late final TextEditingController _dteBeforeController;
  late final TextEditingController _dteAfterController;
  late final TextEditingController _gallonsController;
  late final TextEditingController _costController;
  late final TextEditingController _locationController;
  
  late double _cityPercent;
  late bool _isFullTank;
  late String _fuelGrade;
  late String _paymentMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing fillup data
    _odometerController = TextEditingController(text: widget.fillup.odometer.toString());
    _dteBeforeController = TextEditingController(
      text: widget.fillup.dteBeforeFillup?.toString() ?? ''
    );
    _dteAfterController = TextEditingController(
      text: widget.fillup.dteAfterFillup?.toString() ?? ''
    );
    _gallonsController = TextEditingController(text: widget.fillup.gallons.toString());
    _costController = TextEditingController(text: widget.fillup.totalCost.toString());
    _locationController = TextEditingController(text: widget.fillup.location ?? '');
    
    _cityPercent = widget.fillup.cityDrivingPercent;
    _isFullTank = widget.fillup.isFullTank;
    _fuelGrade = widget.fillup.fuelGrade;
    _paymentMethod = widget.fillup.paymentMethod ?? 'Card';
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Edit Fill-Up',
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
        top: false,
        child: Material(
          color: const Color(0xFF000000),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 130, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              'UPDATE FILL-UP',
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

  Future<void> _saveFillup() async {
    if (_odometerController.text.isEmpty || _gallonsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter odometer reading and gallons'),
          backgroundColor: Colors.red,
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

      // Create updated fillup record
      final updatedFillup = widget.fillup.copyWith(
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

      // Update in database
      await DatabaseService.instance.updateFillup(updatedFillup);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating fill-up: $e'),
            backgroundColor: Colors.red,
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
    _odometerController.dispose();
    _dteBeforeController.dispose();
    _dteAfterController.dispose();
    _gallonsController.dispose();
    _costController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}