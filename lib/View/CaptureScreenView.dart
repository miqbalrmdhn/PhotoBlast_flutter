import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photoblastflutter/Model/CaptureScreenModel.dart';
import '../Services/CameraControlService.dart';

class CaptureScreenView extends StatefulWidget {
  final CameraControllerService cameraService;

  const CaptureScreenView({super.key, required this.cameraService});

  @override
  _CaptureScreenViewState createState() => _CaptureScreenViewState();
}

class _CaptureScreenViewState extends State<CaptureScreenView> {
  @override
  void dispose() {
    widget.cameraService.dispose(); // Properly dispose of the camera service
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final cameraModel = Provider.of<CameraModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('PhotoBlast!'),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.green,
      ),
      body: Row(
        children: [
          // Left Column - Display Last Captured Image
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cameraModel.capturedImages
                  .map((file) => Container(
                margin: EdgeInsets.all(8),
                child: Image.file(file, height: 100, width: 100),
              ))
                  .toList(),
            ),
          ),

          // Middle Column - Camera Preview
          Expanded(
            flex: 2,
            child: FutureBuilder(
              future: widget.cameraService.initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return widget.cameraService.cameraPreview;
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          // Right Column - Control Buttons
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer Button
                ElevatedButton(
                  onPressed: () {
                    _setTimerInterval(context, cameraModel);
                  },
                  child: Column(
                    children: [
                      Icon(Icons.timer),
                      Text('${cameraModel.interval}s'),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Capture Image Button
                ElevatedButton(
                  onPressed: () async {
                    final image = await widget.cameraService.takePicture();
                    cameraModel.addImage(image);
                  },
                  child: Icon(Icons.camera_alt),
                ),
                SizedBox(height: 20),

                // Capture 5 Images Automatically Button
                ElevatedButton(
                  onPressed: () async {
                    await widget.cameraService.takePicturesWithInterval(
                      CameraModel(),
                      5,
                      cameraModel.interval,
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.camera),
                      Text('5x'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to set timer interval
  void _setTimerInterval(BuildContext context, CameraModel model) {
    showDialog(
      context: context,
      builder: (context) {
        int? interval;
        return AlertDialog(
          title: Text('Set Timer Interval'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Interval (seconds)',
            ),
            onChanged: (value) {
              interval = int.tryParse(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (interval != null) model.setInterval(interval!);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}