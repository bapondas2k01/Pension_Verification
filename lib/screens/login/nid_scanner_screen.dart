import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_theme.dart';

class NidScannerScreen extends StatefulWidget {
  final bool is17Digit;

  const NidScannerScreen({super.key, required this.is17Digit});

  @override
  State<NidScannerScreen> createState() => _NidScannerScreenState();
}

class _NidScannerScreenState extends State<NidScannerScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _hasPermission = false;
  String? _error;
  String? _detectedNid;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() => _hasPermission = true);

      try {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          setState(() => _error = 'No cameras available');
          return;
        }

        // Use back camera for scanning documents
        final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.nv21,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() => _isInitialized = true);
          _startScanning();
        }
      } catch (e) {
        setState(() => _error = 'Failed to initialize camera: $e');
      }
    } else {
      setState(() {
        _hasPermission = false;
        _error = 'Camera permission denied';
      });
    }
  }

  void _startScanning() {
    _scanTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isProcessing &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        _captureAndProcess();
      }
    });
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract NID number from recognized text
      final nidNumber = _extractNidNumber(recognizedText.text);

      if (nidNumber != null && mounted) {
        setState(() => _detectedNid = nidNumber);
        _scanTimer?.cancel();

        // Show success and return
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, nidNumber);
        }
      }
    } catch (e) {
      // Silently continue scanning
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String? _extractNidNumber(String text) {
    // Remove all non-digit characters and spaces
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Look for the appropriate NID length
    final targetLength = widget.is17Digit ? 17 : 10;

    // Try to find a sequence of digits matching the target length
    final regex = RegExp(r'\d{' + targetLength.toString() + r'}');
    final match = regex.firstMatch(cleanText);

    if (match != null) {
      return match.group(0);
    }

    // If exact match not found, look for consecutive digits
    if (cleanText.length >= targetLength) {
      // Try to find target length consecutive digits
      for (int i = 0; i <= cleanText.length - targetLength; i++) {
        final candidate = cleanText.substring(i, i + targetLength);
        if (RegExp(
          r'^\d{' + targetLength.toString() + r'}$',
        ).hasMatch(candidate)) {
          return candidate;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              color: AppTheme.primaryGreen,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        localizations.translate('scanNidWithCamera'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Camera view
            Expanded(child: _buildCameraView(localizations)),

            // Bottom instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.black87,
              child: Column(
                children: [
                  if (_detectedNid != null) ...[
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryGreen,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'NID Detected: $_detectedNid',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    Text(
                      widget.is17Digit
                          ? 'Position your 17-digit NID card within the frame'
                          : 'Position your 10-digit NID card within the frame',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_isProcessing)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Scanning...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(AppLocalizations localizations) {
    if (_error != null) {
      return _buildErrorView(localizations);
    }

    if (!_hasPermission) {
      return _buildPermissionDeniedView(localizations);
    }

    if (!_isInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    return Stack(
      children: [
        // Camera preview
        SizedBox.expand(child: CameraPreview(_cameraController!)),

        // Scanning overlay
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(
                color: _detectedNid != null
                    ? AppTheme.primaryGreen
                    : Colors.white,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner markers
                ..._buildCornerMarkers(),

                // Center guide text
                if (_detectedNid == null)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Colors.white54,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Align NID Card Here',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Darkened overlay outside the scan area
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerMarkers() {
    const cornerSize = 20.0;
    const cornerWidth = 4.0;
    final color = _detectedNid != null ? AppTheme.primaryGreen : Colors.white;

    return [
      // Top left
      Positioned(
        top: 0,
        left: 0,
        child: Container(width: cornerSize, height: cornerWidth, color: color),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Container(width: cornerWidth, height: cornerSize, color: color),
      ),
      // Top right
      Positioned(
        top: 0,
        right: 0,
        child: Container(width: cornerSize, height: cornerWidth, color: color),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(width: cornerWidth, height: cornerSize, color: color),
      ),
      // Bottom left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(width: cornerSize, height: cornerWidth, color: color),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(width: cornerWidth, height: cornerSize, color: color),
      ),
      // Bottom right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(width: cornerSize, height: cornerWidth, color: color),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(width: cornerWidth, height: cornerSize, color: color),
      ),
    ];
  }

  Widget _buildPermissionDeniedView(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 24),
            Text(
              localizations.translate('cameraPermissionRequired'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.translate('cameraPermissionMessage'),
              style: const TextStyle(color: AppTheme.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings),
              label: Text(localizations.translate('openSettings')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.accentRed,
            ),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'An unexpected error occurred',
              style: const TextStyle(color: AppTheme.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isInitialized = false;
                });
                _initializeCamera();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
