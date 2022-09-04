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
      appBar: AppBar(),
      body: _isReady
          ? Stack(
              children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: CameraPreview(
                    _controller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _isRecording
                        ? RecordButton(
                            onTap: () async {
                              try {
                                final xfile =
                                    await _controller.stopVideoRecording();

                                context
                                    .go('/camera/preview?path=${xfile.path}');
                              } catch (e) {
                                print(e);
                              }
                            },
                            isStarted: true,
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
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class RecordButton extends StatelessWidget {
  RecordButton({
    Key? key,
    this.isStarted = false,
    this.onTap,
  }) : super(key: key);
  bool isStarted;
  VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(width: 4, color: Colors.white),
          shape: BoxShape.circle,
        ),
        child: isStarted
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Colors.red),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.red),
              ),
      ),
    );
  }
}
