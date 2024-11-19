import 'dart:io';
import 'package:flutter/material.dart';

class CameraModel with ChangeNotifier {
  List<File> _capturedImages = [];
  int _interval = 0;

  List<File> get capturedImages => _capturedImages;
  int get interval => _interval;

  void addImage(File image) {
    _capturedImages.insert(0, image); // menambahkan gambar terbaru di awal
    if (_capturedImages.length > 3) {
      _capturedImages = _capturedImages.sublist(0, 3); // menyimpan maksimal 3 gambar
    }
    notifyListeners();
  }

  void setInterval(int interval) {
    _interval = interval;
    notifyListeners();
  }
}
