import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:async';
import 'dart:io';
import '../../l10n/app_localizations.dart';
import '../../providers/pensioner_provider.dart';
import '../../utils/app_theme.dart';

class VerificationCameraScreen extends StatefulWidget {
  const VerificationCameraScreen({super.key});

  @override
  State<VerificationCameraScreen> createState() =>
      _VerificationCameraScreenState();
}

class _VerificationCameraScreenState extends State<VerificationCameraScreen> {
  int _currentStep = 0;
  bool _isProcessing = false;
  bool _verificationComplete = false;
  bool _verificationSuccess = false;

  // Camera related
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;
  String? _cameraError;

  // Face detection
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.15,
    ),
  );
  Timer? _detectionTimer;
  bool _faceMatchesCriteria = false;
  int _criteriaMatchCount = 0;
  static const int _requiredMatchCount =
      3; // Need 3 consecutive matches for stability
  String? _capturedPhotoPath; // Store the first captured photo

  final List<String> _steps = ['lookStraight', 'turnLeft', 'turnRight'];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();

    if (status.isGranted) {
      try {
        // Get available cameras
        final cameras = await availableCameras();

        if (cameras.isEmpty) {
          setState(() {
            _cameraError = 'No camera found on this device';
          });
          return;
        }

        // Find front camera
        CameraDescription? frontCamera;
        for (var camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.front) {
            frontCamera = camera;
            break;
          }
        }

        // Use front camera if available, otherwise use first camera
        final selectedCamera = frontCamera ?? cameras.first;

        _cameraController = CameraController(
          selectedCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
          _startFaceDetection(); // Start automatic face detection
        }
      } catch (e) {
        setState(() {
          _cameraError = 'Failed to initialize camera: $e';
        });
      }
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isCameraPermissionDenied = true;
      });
    } else {
      setState(() {
        _isCameraPermissionDenied = true;
      });
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  void _startFaceDetection() {
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isProcessing &&
          _cameraController != null &&
          _cameraController!.value.isInitialized &&
          !_verificationComplete) {
        _detectAndCapture();
      }
    });
  }

  Future<void> _detectAndCapture() async {
    if (_isProcessing || _cameraController == null) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        // No face detected - reset criteria match counter
        setState(() {
          _faceMatchesCriteria = false;
          _criteriaMatchCount = 0;
        });
      } else {
        final face = faces.first;
        final bool matchesCriteria = _checkFaceCriteria(face);

        if (matchesCriteria) {
          _criteriaMatchCount++;

          if (_criteriaMatchCount >= _requiredMatchCount) {
            // Face matches criteria for required number of times - auto capture!
            // Save the first captured photo (when looking straight)
            if (_currentStep == 0 && _capturedPhotoPath == null) {
              _capturedPhotoPath = image.path;
            }
            setState(() => _faceMatchesCriteria = true);
            await Future.delayed(const Duration(milliseconds: 300));
            _nextStep();
            return; // Don't reset processing flag yet
          }
        } else {
          // Face doesn't match criteria - reset counter
          setState(() {
            _faceMatchesCriteria = false;
            _criteriaMatchCount = 0;
          });
        }
      }
    } catch (e) {
      // Error in detection - continue trying
      debugPrint('Face detection error: $e');
    }

    setState(() => _isProcessing = false);
  }

  bool _checkFaceCriteria(Face face) {
    // Check basic criteria
    // 1. Face should be reasonably sized (user is close enough)
    if (face.boundingBox.width < 200 || face.boundingBox.height < 200) {
      return false;
    }

    // 2. Check head rotation based on current step
    if (_currentStep == 0) {
      // Look straight: head should be mostly straight
      final headYaw = face.headEulerAngleY ?? 0;
      final headPitch = face.headEulerAngleX ?? 0;

      // Allow some tolerance: head should be within ±15 degrees
      if (headYaw.abs() > 15 || headPitch.abs() > 15) {
        return false;
      }
    } else if (_currentStep == 1) {
      // Turn left: head should be turned left (negative yaw)
      final headYaw = face.headEulerAngleY ?? 0;

      // Head should be turned left between 15-45 degrees
      if (headYaw > -15 || headYaw < -50) {
        return false;
      }
    } else if (_currentStep == 2) {
      // Turn right: head should be turned right (positive yaw)
      final headYaw = face.headEulerAngleY ?? 0;

      // Head should be turned right between 15-45 degrees
      if (headYaw < 15 || headYaw > 50) {
        return false;
      }
    }

    // 3. Check if eyes are open (if classification is available)
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      final leftEyeOpen = (face.leftEyeOpenProbability ?? 0) > 0.5;
      final rightEyeOpen = (face.rightEyeOpenProbability ?? 0) > 0.5;

      if (!leftEyeOpen || !rightEyeOpen) {
        return false;
      }
    }

    return true;
  }

  void _nextStep() async {
    _detectionTimer?.cancel(); // Stop detection during processing

    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _criteriaMatchCount = 0; // Reset counter for next step
        _faceMatchesCriteria = false;
        _isProcessing = false;
      });
      _startFaceDetection(); // Restart detection for next step
    } else {
      // Complete verification
      setState(() => _isProcessing = true);

      final provider = Provider.of<PensionerProvider>(context, listen: false);

      // Read selfie bytes from captured photo
      Uint8List? selfieBytes;
      if (_capturedPhotoPath != null) {
        try {
          final file = File(_capturedPhotoPath!);
          selfieBytes = await file.readAsBytes();
        } catch (e) {
          debugPrint('Error reading selfie: $e');
        }
      }

      // Perform verification with Supabase (upload selfie)
      final success = await provider.performLifeVerification(
        selfieBytes: selfieBytes,
        locationData: {
          'timestamp': DateTime.now().toIso8601String(),
          'device': 'mobile_app',
        },
      );

      // Update pensioner photo with captured image
      if (success && _capturedPhotoPath != null) {
        provider.updatePensionerPhoto(_capturedPhotoPath!);
      }

      setState(() {
        _isProcessing = false;
        _verificationComplete = true;
        _verificationSuccess = success;
      });

      // Auto navigate back after showing result
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
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
                        localizations.translate('lifeVerification'),
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

            // Camera preview area
            Expanded(
              child: _verificationComplete
                  ? _buildResultView(localizations)
                  : _isCameraPermissionDenied
                  ? _buildPermissionDeniedView(localizations)
                  : _cameraError != null
                  ? _buildErrorView(localizations)
                  : _buildCameraView(localizations),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView(AppLocalizations localizations) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 24),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please grant camera permission to use life verification feature. Go to Settings > Apps > Pension Verification > Permissions and enable Camera.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _initializeCamera();
                },
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations localizations) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                _cameraError ?? 'Camera Error',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _cameraError = null;
                  });
                  _initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView(AppLocalizations localizations) {
    // Show loading while camera initializes
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryGreen),
              SizedBox(height: 24),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize?.height ?? 100,
              height: _cameraController!.value.previewSize?.width ?? 100,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),

        // Overlay with face guide
        Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Face outline guide
                Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryGreen, width: 3),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
                const SizedBox(height: 40),

                // Instruction
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Text(
                        localizations.translate(_steps[_currentStep]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _faceMatchesCriteria
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: _faceMatchesCriteria
                                ? AppTheme.primaryGreen
                                : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _faceMatchesCriteria
                                ? 'Position correct! Capturing...'
                                : 'Adjust your position',
                            style: TextStyle(
                              color: _faceMatchesCriteria
                                  ? AppTheme.primaryGreen
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Progress indicator
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (index) {
              return Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index <= _currentStep
                      ? AppTheme.primaryGreen
                      : Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),

        // Auto-capture status indicator
        if (_isProcessing)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                      strokeWidth: 2,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultView(AppLocalizations localizations) {
    return Container(
      color: _verificationSuccess ? AppTheme.lightGreen : Colors.red[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _verificationSuccess ? Icons.check_circle : Icons.error,
              size: 100,
              color: _verificationSuccess ? AppTheme.primaryGreen : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              localizations.translate(
                _verificationSuccess
                    ? 'verificationSuccess'
                    : 'verificationFailed',
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _verificationSuccess
                    ? AppTheme.primaryGreen
                    : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
