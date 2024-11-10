import 'dart:io';
import 'package:flutter/material.dart';

class CameraModel with ChangeNotifier {
  List<File> _capturedImages = [];
  File? _currentImage;
  int _interval = 0;

  List<File> get capturedImages => _capturedImages;
  File? get currentImage => _currentImage;
  int get interval => _interval;

  void captureImage(File image) {
    _currentImage = image;
    _capturedImages.add(image);
    notifyListeners();
  }

  void setInterval(int interval) {
    _interval = interval;
    notifyListeners();
  }
}