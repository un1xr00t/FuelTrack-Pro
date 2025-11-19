// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../services/database_service.dart';
import '../models/fillup_record.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _tankCapacityController = TextEditingController();
  final _epaCityController = TextEditingController();
  final _epaHighwayController = TextEditingController();
  final _epaCombinedController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: SafeArea(
        child: Material(
          color: const Color(0xFF000000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildProgressIndicator(),
                const SizedBox(height: 40),
                _buildCurrentStep(),
                const SizedBox(height: 40),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.local_gas_station,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to\nFuelTrack Pro',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Let\'s set up your first vehicle',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? const Color(0xFF667EEA)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentStep == 0) _buildStep1(),
          if (_currentStep == 1) _buildStep2(),
          if (_currentStep == 2) _buildStep3(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: 'Vehicle Nickname',
          hint: 'e.g., My Camry, Work Truck',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _makeController,
          label: 'Make',
          hint: 'e.g., Toyota, Honda',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _modelController,
          label: 'Model',
          hint: 'e.g., Camry, Accord',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _yearController,
          label: 'Year',
          hint: 'e.g., 2020',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tank Capacity',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This helps with range calculations',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _tankCapacityController,
          label: 'Tank Capacity (Optional)',
          hint: 'e.g., 14.5',
          suffix: 'gallons',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EPA Ratings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Compare your real-world MPG to EPA estimates',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _epaCityController,
          label: 'EPA City (Optional)',
          hint: 'e.g., 28',
          suffix: 'MPG',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _epaHighwayController,
          label: 'EPA Highway (Optional)',
          hint: 'e.g., 39',
          suffix: 'MPG',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _epaCombinedController,
          label: 'EPA Combined (Optional)',
          hint: 'e.g., 32',
          suffix: 'MPG',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? suffix,
    TextInputType? keyboardType,
    bool isRequired = false,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        // Next/Finish button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleNext,
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
                : Text(
                    _currentStep == 2 ? 'FINISH SETUP' : 'NEXT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
        
        // Back button
        if (_currentStep > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _currentStep--;
                      });
                    },
              child: const Text(
                'BACK',
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      // Validate only step 1 (basic info)
      if (_currentStep == 0 && !_formKey.currentState!.validate()) {
        return;
      }
      
      setState(() {
        _currentStep++;
      });
    } else {
      // Finish setup
      _finishSetup();
    }
  }

  Future<void> _finishSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = VehicleProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        make: _makeController.text.trim().isNotEmpty 
            ? _makeController.text.trim() 
            : null,
        model: _modelController.text.trim().isNotEmpty 
            ? _modelController.text.trim() 
            : null,
        year: _yearController.text.trim().isNotEmpty 
            ? int.tryParse(_yearController.text.trim()) 
            : null,
        tankCapacity: _tankCapacityController.text.trim().isNotEmpty 
            ? double.tryParse(_tankCapacityController.text.trim()) 
            : null,
        epaCity: _epaCityController.text.trim().isNotEmpty 
            ? double.tryParse(_epaCityController.text.trim()) 
            : null,
        epaHighway: _epaHighwayController.text.trim().isNotEmpty 
            ? double.tryParse(_epaHighwayController.text.trim()) 
            : null,
        epaCombined: _epaCombinedController.text.trim().isNotEmpty 
            ? double.tryParse(_epaCombinedController.text.trim()) 
            : null,
        isActive: true,
      );

      await DatabaseService.instance.createVehicle(vehicle);
      await DatabaseService.instance.setOnboardingComplete();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving vehicle: $e'),
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
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _tankCapacityController.dispose();
    _epaCityController.dispose();
    _epaHighwayController.dispose();
    _epaCombinedController.dispose();
    super.dispose();
  }
}