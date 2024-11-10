import 'package:flutter/material.dart';
import 'package:photoblastflutter/View/CaptureScreenView.dart';

class HomeController {
  void navigateToSecondScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CaptureScreenView()),
    );
  }
}