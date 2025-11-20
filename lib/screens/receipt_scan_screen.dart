// lib/screens/receipt_scan_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/receipt_parser_service.dart';
import 'add_fillup_screen.dart';

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 100, // Max quality for OCR
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _errorMessage = null;
        });
        await _processReceipt();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _processReceipt() async {
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      debugPrint('=== RECEIPT PROCESSING STARTED ===');
      debugPrint('Image path: ${_imageFile!.path}');
      debugPrint('File exists: ${_imageFile!.existsSync()}');
      debugPrint('File size: ${_imageFile!.lengthSync()} bytes');
      
      // Initialize text recognizer
      debugPrint('Initializing text recognizer...');
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      debugPrint('Text recognizer initialized');
      
      debugPrint('Creating input image...');
      final inputImage = InputImage.fromFile(_imageFile!);
      debugPrint('Input image created');
      
      // Perform OCR
      debugPrint('Starting OCR processing...');
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      debugPrint('OCR completed!');
      debugPrint('Recognized text length: ${recognizedText.text.length} characters');
      debugPrint('Raw OCR text:\n${recognizedText.text}');
      
      // Parse receipt data
      debugPrint('Parsing receipt data...');
      final receiptData = ReceiptParserService.parseReceipt(recognizedText.text);
      debugPrint('Parsing completed!');
      debugPrint('Extracted data: $receiptData');
      
      // Clean up
      debugPrint('Cleaning up text recognizer...');
      await textRecognizer.close();
      debugPrint('Text recognizer closed');

      if (mounted) {
        if (receiptData.isEmpty) {
          debugPrint('ERROR: No data extracted from receipt');
          setState(() {
            _errorMessage = 'Could not extract fuel data from receipt. Please try again or enter manually.';
            _isProcessing = false;
          });
        } else {
          debugPrint('SUCCESS: Navigating to add fillup screen with data');
          
          // Reset processing state before navigation
          setState(() {
            _isProcessing = false;
          });
          
          // Navigate to add fillup with pre-filled data
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFillupScreen(
                prefillData: receiptData,
              ),
            ),
          );
          
          // If fillup was saved successfully, go back to home
          if (result == true && mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== RECEIPT PROCESSING ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _errorMessage = 'Error processing receipt: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Scan Receipt',
        useNativeToolbar: true,
      ),
      body: SafeArea(
        top: false,
        child: Material(
          color: const Color(0xFF000000),
          child: _isProcessing
              ? _buildProcessingView()
              : _imageFile == null
                  ? _buildImageSourceSelection()
                  : _buildImagePreview(),
        ),
      ),
    );
  }

  Widget _buildImageSourceSelection() {
    return Padding(
      padding: const EdgeInsets.only(top: 130, left: 24, right: 24),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Scan Gas Receipt',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Automatically extract fill-up details from your receipt',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 48),
          
          // Camera button
          _buildSourceButton(
            icon: Icons.camera_alt,
            label: 'Take Photo',
            subtitle: 'Use camera to scan receipt',
            color: const Color(0xFF667EEA),
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          
          // Gallery button
          _buildSourceButton(
            icon: Icons.photo_library,
            label: 'Choose from Gallery',
            subtitle: 'Select an existing photo',
            color: const Color(0xFF10B981),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const Spacer(),
          
          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: Color(0xFF667EEA),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TIPS FOR BEST RESULTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF667EEA),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTip('Ensure good lighting'),
                _buildTip('Keep receipt flat and straight'),
                _buildTip('Capture entire receipt clearly'),
                _buildTip('Avoid shadows and glare'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 130, left: 24, right: 24, bottom: 24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                        _errorMessage = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Color(0xFF667EEA),
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'RETAKE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _processReceipt,
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
                      'PROCESS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF667EEA),
            strokeWidth: 6,
          ),
          const SizedBox(height: 32),
          const Text(
            'Processing Receipt...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Extracting fill-up details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                _buildProcessingStep('Reading text', true),
                const SizedBox(height: 12),
                _buildProcessingStep('Analyzing data', true),
                const SizedBox(height: 12),
                _buildProcessingStep('Extracting details', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStep(String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF667EEA) : const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}