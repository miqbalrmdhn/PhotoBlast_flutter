import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:photoblastflutter/Model/CaptureScreenModel.dart';

class CaptureScreenView extends StatefulWidget {
  @override
  _CaptureViewState createState() => _CaptureViewState();
}

class _CaptureViewState extends State<CaptureScreenView> {
  late CameraController _cameraController;
  late CameraModel _cameraModel;
  late List<CameraDescription> _cameras;

  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _cameraModel = CameraModel();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_cameraController);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _cameraModel.capturedImages.length,
                          itemBuilder: (context, index) {
                            return Image.file(_cameraModel.capturedImages[index]);
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await _initializeControllerFuture;
                                final path = join(
                                  (await getApplicationDocumentsDirectory()).path,
                                  '${DateTime.now()}.png',
                                );
                                await _cameraController.takePicture();
                                _cameraModel.captureImage(File(path));
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: Icon(Icons.camera),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Set Interval'),
                                    content: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Interval (seconds)',
                                      ),
                                      onChanged: (value) {
                                        _cameraModel.setInterval(int.parse(value));
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.timer),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}