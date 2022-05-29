import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    Key? key,
  }) : super(key: key);

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _isReady = false;

  @override
  void initState() {
    _setupCameras();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setupCameras() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
      );
      await _controller.initialize();
    } on CameraException catch (_) {
      // do something on error.
    }

    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: _isReady
          ? SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: CameraPreview(
                _controller,
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          try {
            if (!_isReady) {
              return;
            }

            await _controller.startVideoRecording();
            await Future<void>.delayed(Duration(seconds: 3));

            final xfile = await _controller.stopVideoRecording();

            context.go('/camera/preview?path=${xfile.path}');
          } catch (e) {
            // Todo: error handling
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
