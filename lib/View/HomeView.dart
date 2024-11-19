import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../Model/CaptureScreenModel.dart';
import '../View/CaptureScreenView.dart';
import '../Services/CameraControlService.dart';

class HomeScreen extends StatelessWidget {
  Future<void> navigateToSecondScreen(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Get available cameras
      final cameras = await availableCameras();

      // Pop loading dialog
      Navigator.of(context).pop();

      if (cameras.isEmpty) {
        throw CameraException(
          'noCamera',
          'No cameras found on device',
        );
      }

      // Check if camera is available
      bool cameraAvailable = false;
      CameraDescription? usableCamera;

      for (var camera in cameras) {
        try {
          // Try to create a controller for each camera
          final testController = CameraController(
            camera,
            ResolutionPreset.medium,
            enableAudio: false,
          );

          await testController.initialize();
          await testController.dispose();

          usableCamera = camera;
          cameraAvailable = true;
          break;
        } catch (e) {
          print('Camera ${camera.name} test failed: $e');
          continue;
        }
      }

      if (!cameraAvailable || usableCamera == null) {
        throw CameraException(
          'cameraNotAvailable',
          'No working camera found on device',
        );
      }

      var cameraService = CameraControllerService(usableCamera);

      // Navigate to capture screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CaptureScreenView(cameraService: cameraService),
        ),
      );

    } catch (e) {
      // Pop loading dialog if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Camera Error'),
            content: Text(_getCameraErrorMessage(e)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  String _getCameraErrorMessage(dynamic error) {
    if (error is CameraException) {
      switch (error.code) {
        case 'noCamera':
          return 'No camera found on this device.';
        case 'cameraNotAvailable':
          return 'Camera is not available. Please check your device settings and permissions.';
        case 'cameraNotReadable':
          return 'Cannot access camera. Please try restarting your device.';
        default:
          return 'Camera error: ${error.description}';
      }
    }
    return 'An unexpected error occurred: $error';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhotoBlast'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigateToSecondScreen(context),
              child: const Text('Start Camera'),
            ),
            const SizedBox(height: 16),
            Text(
              'If camera doesn\'t work, please check:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Camera permissions in app settings'),
                  Text('• Device camera is not in use by other apps'),
                  Text('• Device is not in power saving mode'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}