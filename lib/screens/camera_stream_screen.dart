import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../constants/app_styles.dart';

class CameraStreamScreen extends StatefulWidget {
  const CameraStreamScreen({super.key});

  @override
  State<CameraStreamScreen> createState() => _CameraStreamScreenState();
}

class _CameraStreamScreenState extends State<CameraStreamScreen> {
  CameraController? _controller;
  bool _isStreaming = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  Future<void> _toggleCamera() async {
    final cameras = await availableCameras();
    final cameraIndex = _isFrontCamera ? 0 : 1;
    
    if (cameras.length < 2) return;

    await _controller?.dispose();
    
    _controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      setState(() => _isFrontCamera = !_isFrontCamera);
    } catch (e) {
      _showError('Failed to switch camera: $e');
    }
  }

  Future<void> _toggleStream() async {
    if (_isStreaming) {
      await WakelockPlus.disable();
      // Add your stream stop logic here
    } else {
      await WakelockPlus.enable();
      // Add your stream start logic here
    }
    
    setState(() => _isStreaming = !_isStreaming);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: AppStyles.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppStyles.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.secondaryColor,
        title: Text('Camera Stream', style: AppStyles.headingStyle),
        foregroundColor: AppStyles.primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              _isFrontCamera ? Icons.camera_rear : Icons.camera_front,
              color: Colors.white,
            ),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppStyles.primaryColor,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppStyles.secondaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StreamControlButton(
                      icon: _isStreaming ? Icons.stop : Icons.play_arrow,
                      label: _isStreaming ? 'Stop Stream' : 'Start Stream',
                      color: _isStreaming ? Colors.red : AppStyles.primaryColor,
                      onPressed: _toggleStream,
                    ),
                  ],
                ),
                if (_isStreaming) ...[
                  const SizedBox(height: 20),
                  const Text(
                    '🔴 Live',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _StreamControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
} 