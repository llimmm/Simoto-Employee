import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../attendance_page/AttendanceApiService.dart';
import '../attendance_page/SharedAttendanceController.dart';

class AttendanceCameraPage extends StatefulWidget {
  final String shiftId;

  const AttendanceCameraPage({Key? key, required this.shiftId}) : super(key: key);

  @override
  State<AttendanceCameraPage> createState() => _AttendanceCameraPageState();
}

class _AttendanceCameraPageState extends State<AttendanceCameraPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraPermissionGranted = false;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  File? _capturedImage;
  final AttendanceApiService _attendanceService = AttendanceApiService();
  final SharedAttendanceController _attendanceController = SharedAttendanceController.to;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      if (state == AppLifecycleState.resumed) {
        _initializeCamera();
      } else if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached) {
        _cameraController?.dispose();
      }
    } catch (e) {
      debugPrint('Error in lifecycle management: $e');
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();

      if (!mounted) return;

      setState(() {
        _isCameraPermissionGranted = status.isGranted;
        if (_isCameraPermissionGranted) {
          _initializeCamera();
        }
      });
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera permissions: $e')),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use front camera for attendance
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      
      if (!mounted) return;
      
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) return;
      
      // Check if flash is supported
      if (!_cameraController!.value.flashMode.index.isEqual(FlashMode.off.index) && 
          !_cameraController!.value.flashMode.index.isEqual(FlashMode.torch.index)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flash not supported on this device')),
        );
        return;
      }
      
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      // Revert state if failed
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not toggle flash: $e')),
      );
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _checkInWithPhoto() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a photo first')),
      );
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      // Call the API service to check in with photo
      await _attendanceService.checkInWithPhoto(widget.shiftId, _capturedImage!);
      
      // Update attendance status
      await _attendanceController.checkAttendanceStatus();
      
      // Refresh attendance history
      await _attendanceController.loadAttendanceHistory();

      // Return to previous screen with success result
      Get.back(result: true);
      
      // Show success message
      Get.snackbar(
        'Check-in Successful',
        'Your attendance has been recorded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFAED15C),
        colorText: Colors.black,
      );
    } catch (e) {
      debugPrint('Error during check-in with photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during check-in: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
      _cameraController?.dispose();
    } catch (e) {
      debugPrint('Error disposing camera controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Photo'),
        backgroundColor: const Color(0xFFAED15C),
        elevation: 0,
        actions: [
          if (_isCameraInitialized && _capturedImage == null)
            IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isCameraPermissionGranted) {
      return _buildPermissionDeniedUI();
    }

    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_capturedImage != null) {
      return _buildImagePreviewUI();
    }

    return _buildCameraUI();
  }

  Widget _buildPermissionDeniedUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Camera permission is required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please grant camera permission to take attendance photo',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _requestCameraPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAED15C),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraUI() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        Container(
          height: 120,
          width: double.infinity,
          color: Colors.black,
          child: Center(
            child: _isProcessing
                ? const CircularProgressIndicator(color: Color(0xFFAED15C))
                : GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewUI() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          height: 120,
          width: double.infinity,
          color: Colors.black,
          child: _isProcessing
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFAED15C)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _retakePicture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text('Retake'),
                    ),
                    ElevatedButton(
                      onPressed: _checkInWithPhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAED15C),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text('Check In'),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}