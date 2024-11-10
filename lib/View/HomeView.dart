import 'package:flutter/material.dart';
import 'package:photoblastflutter/Controller/HomeController.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _controller = HomeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'WELCOME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => _controller.navigateToSecondScreen(context),
              child: Text('Mulai'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.grey[300], // Text color
                textStyle: TextStyle(fontSize: 18),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}