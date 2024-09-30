import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

class DummyCameraPreview extends StatefulWidget {
  const DummyCameraPreview({Key? key}) : super(key: key);

  @override
  State<DummyCameraPreview> createState() => _DummyCameraPreviewState();
}

class _DummyCameraPreviewState extends State<DummyCameraPreview> {
  late CameraController controller;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      // Find the front camera
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      controller = CameraController(frontCamera, ResolutionPreset.high);
      await controller.initialize();
      setState(() {
        isCameraInitialized = true;
      });
    } catch (e) {
      if (e is CameraException) {
        print('Camera Error: ${e.description}');
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(controller);
  }
}
