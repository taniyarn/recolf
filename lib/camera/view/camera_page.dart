import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _isRecording = false;

  @override
  void initState() {
    _setupCameras();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setupCameras() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.max,
      );
      await _controller.initialize();
      await _controller.prepareForVideoRecording();

      setState(() {
        _isReady = true;
      });
    } on CameraException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            context.go('/');
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _isReady
          ? Stack(
              children: [
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      height: _controller.value.aspectRatio,
                      width: 1,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildRecordButton(context),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildRecordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: GestureDetector(
        onTap: _isRecording ? _stopRecording : _startRecording,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(width: 4, color: Colors.white),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AnimatedContainer(
              width: _isRecording ? 24 : 48,
              height: _isRecording ? 24 : 48,
              duration: const Duration(milliseconds: 100),
              decoration: _isRecording
                  ? const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Colors.red,
                    )
                  : const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      color: Colors.red,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (!_isReady) {
        return;
      }

      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (_) {}
  }

  Future<void> _stopRecording() async {
    try {
      final xfile = await _controller.stopVideoRecording();
      final dir = await getApplicationDocumentsDirectory();
      final path = dir.path;
      final directory = Directory('$path/video');
      await directory.create(recursive: true);
      final newPath = '${directory.path}/${xfile.name}';
      await File(xfile.path).rename(newPath);
      if (!mounted) return;
      context.go('/preview?path=$newPath');
    } catch (_) {}
  }
}
