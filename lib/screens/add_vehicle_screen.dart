// lib/screens/add_vehicle_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_helper;
import '../services/database_service.dart';
import '../models/fillup_record.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleProfile? vehicle; // If editing
  
  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _tankCapacityController = TextEditingController();
  final _epaCityController = TextEditingController();
  final _epaHighwayController = TextEditingController();
  final _epaCombinedController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.vehicle != null;
  File? _imageFile;
  String? _existingImagePath;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.vehicle!.name;
      _makeController.text = widget.vehicle!.make ?? '';
      _modelController.text = widget.vehicle!.model ?? '';
      _yearController.text = widget.vehicle!.year?.toString() ?? '';
      _tankCapacityController.text = widget.vehicle!.tankCapacity?.toString() ?? '';
      _epaCityController.text = widget.vehicle!.epaCity?.toString() ?? '';
      _epaHighwayController.text = widget.vehicle!.epaHighway?.toString() ?? '';
      _epaCombinedController.text = widget.vehicle!.epaCombined?.toString() ?? '';
      
      // Migrate old absolute paths to new relative paths (just filename)
      if (widget.vehicle!.imagePath != null && widget.vehicle!.imagePath!.contains('/')) {
        // Extract filename from old absolute path
        _existingImagePath = widget.vehicle!.imagePath!.split('/').last;
        debugPrint('Migrated image path from absolute to relative: $_existingImagePath');
      } else {
        _existingImagePath = widget.vehicle!.imagePath;
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String?> _saveImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final vehicleImagesDir = Directory('${directory.path}/vehicle_images');
      
      // Ensure directory exists
      if (!await vehicleImagesDir.exists()) {
        await vehicleImagesDir.create(recursive: true);
        debugPrint('Created vehicle_images directory at: ${vehicleImagesDir.path}');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path_helper.extension(imageFile.path)}';
      final savedImage = File('${vehicleImagesDir.path}/$fileName');
      
      // Copy the image file
      await imageFile.copy(savedImage.path);
      
      // Verify the file was saved
      if (await savedImage.exists()) {
        debugPrint('Image saved successfully at: ${savedImage.path}');
        // Return ONLY the filename, not the full path - we'll reconstruct it when loading
        return fileName;
      } else {
        debugPrint('Image save verification failed');
        return null;
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: _isEditing ? 'Edit Vehicle' : 'Add Vehicle',
        useNativeToolbar: true,
        actions: [
          AdaptiveAppBarAction(
            onPressed: _saveVehicle,
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
              padding: const EdgeInsets.only(
                top: 130,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car photo section
                  _buildPhotoSection(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Basic Information'),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Tank Capacity'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _tankCapacityController,
                    label: 'Tank Capacity (Optional)',
                    hint: 'e.g., 14.5',
                    suffix: 'gallons',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('EPA Ratings'),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveVehicle,
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
                              _isEditing ? 'UPDATE VEHICLE' : 'ADD VEHICLE',
                              style: const TextStyle(
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

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF667EEA),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _buildImageDisplay(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image, color: Color(0xFF667EEA)),
            label: Text(
              _imageFile != null || _existingImagePath != null
                  ? 'Change Photo'
                  : 'Add Photo',
              style: const TextStyle(color: Color(0xFF667EEA)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    // Priority: new selected image > existing image > placeholder
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        key: ValueKey(_imageFile!.path),
        fit: BoxFit.cover,
        cacheWidth: 300,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading new image: $error');
          return _buildPlaceholder();
        },
      );
    }

    if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      // Reconstruct full path from filename
      return FutureBuilder<String>(
        future: _getFullImagePath(_existingImagePath!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final imageFile = File(snapshot.data!);
            if (imageFile.existsSync()) {
              return Image.file(
                imageFile,
                key: ValueKey(snapshot.data),
                fit: BoxFit.cover,
                cacheWidth: 300,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading existing image: $error');
                  return _buildPlaceholder();
                },
              );
            } else {
              debugPrint('Existing image file not found at: ${snapshot.data}');
            }
          }
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  Future<String> _getFullImagePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/vehicle_images/$fileName';
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_a_photo,
          size: 40,
          color: Color(0xFF667EEA),
        ),
        const SizedBox(height: 8),
        Text(
          'Add Photo',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
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

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imagePath = _existingImagePath;

      // Save new image if user selected one
      if (_imageFile != null) {
        debugPrint('=== SAVING NEW IMAGE ===');
        debugPrint('Source file: ${_imageFile!.path}');
        debugPrint('Source exists: ${_imageFile!.existsSync()}');
        
        imagePath = await _saveImage(_imageFile!);
        
        debugPrint('Saved image path: $imagePath');
        if (imagePath != null) {
          final savedFile = File(imagePath);
          debugPrint('Saved file exists: ${savedFile.existsSync()}');
          if (savedFile.existsSync()) {
            debugPrint('Saved file size: ${savedFile.lengthSync()} bytes');
          }
        }
      } else if (_existingImagePath != null) {
        debugPrint('=== KEEPING EXISTING IMAGE ===');
        debugPrint('Existing path: $_existingImagePath');
        final existingFile = File(_existingImagePath!);
        debugPrint('Existing file exists: ${existingFile.existsSync()}');
      }

      if (_isEditing) {
        // Update existing vehicle
        final updatedVehicle = widget.vehicle!.copyWith(
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
          imagePath: imagePath,
        );

        await DatabaseService.instance.updateVehicle(updatedVehicle);
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        // Create new vehicle
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
          isActive: false,
          imagePath: imagePath,
        );

        await DatabaseService.instance.createVehicle(vehicle);
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Error',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Error saving vehicle: $e',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF667EEA)),
                ),
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