import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';

import 'package:photoblastflutter/Model/CaptureScreenModel.dart';

class CameraControllerService {
  late CameraController _controller;
  late Future<void> initializeControllerFuture;
  bool _isInitialized = false;

  CameraControllerService(CameraDescription camera) {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      initializeControllerFuture = _controller.initialize();
      await initializeControllerFuture;
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw CameraException(
        'initializationError',
        'Failed to initialize camera: $e',
      );
    }
  }

  Future<void> reinitialize() async {
    if (_isInitialized) {
      await _controller.dispose();
    }
    await _initializeCamera();
  }

  Future<File> takePicture() async {
    if (!_isInitialized) {
      throw CameraException(
        'cameraNotInitialized',
        'Camera is not initialized',
      );
    }

    try {
      final image = await _controller.takePicture();
      return File(image.path);
    } catch (e) {
      throw CameraException(
        'captureError',
        'Failed to capture image: $e',
      );
    }
  }

  Future<List<File>> takePicturesWithInterval(
      CameraModel model,
      int count,
      int intervalSeconds,
      ) async {
    List<File> capturedImages = [];

    try {
      for (int i = 0; i < count; i++) {
        if (i > 0) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        }

        final image = await takePicture();
        capturedImages.add(image);
        model.addImage(image);
      }
      return capturedImages;
    } catch (e) {
      throw CameraException(
        'intervalCaptureError',
        'Failed during interval capture: $e',
      );
    }
  }

  Widget get cameraPreview {
    if (!_isInitialized) {
      return const Center(child: Text('Camera initialization failed'));
    }
    return CameraPreview(_controller);
  }

  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;
}