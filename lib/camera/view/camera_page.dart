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
        ResolutionPreset.max,
      );
      await _controller.initialize();
      await _controller.prepareForVideoRecording();
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
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _isRecording
                        ? RecordButton(
                            onTap: () async {
                              try {
                                final xfile =
                                    await _controller.stopVideoRecording();
                                final dir =
                                    await getApplicationDocumentsDirectory();
                                final path = dir.path;
                                final directory = Directory('$path/video');
                                await directory.create(recursive: true);
                                final newPath =
                                    '${directory.path}/${xfile.name}';
                                await File(xfile.path).rename(newPath);
                                context.go('/camera/preview?path=$newPath');
                              } catch (e) {
                                print(e);
                              }
                            },
                            isRecording: true,
                          )
                        : RecordButton(
                            onTap: () async {
                              try {
                                if (!_isReady) {
                                  return;
                                }

                                await _controller.startVideoRecording();
                                setState(() {
                                  _isRecording = true;
                                });
                              } catch (e) {
                                print(e);
                              }
                            },
                          ),
                  ),
                )
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class RecordButton extends StatelessWidget {
  const RecordButton({
    Key? key,
    this.isRecording = false,
    this.onTap,
  }) : super(key: key);
  final bool isRecording;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(width: 4, color: Colors.white),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AnimatedContainer(
            width: isRecording ? 24 : 48,
            height: isRecording ? 24 : 48,
            duration: const Duration(milliseconds: 100),
            decoration: isRecording
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
    );
  }
}
