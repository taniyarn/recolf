import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/camera/bloc/camera_bloc.dart';
import 'package:recolf/services/video.dart';
import 'package:recolf/util.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CameraBloc(RepositoryProvider.of<VideoService>(context)),
      child: const CameraScaffold(),
    );
  }
}

class CameraScaffold extends StatefulWidget {
  const CameraScaffold({
    Key? key,
  }) : super(key: key);

  @override
  CameraScaffoldState createState() => CameraScaffoldState();
}

class CameraScaffoldState extends State<CameraScaffold> {
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
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller.initialize();
      await _controller.prepareForVideoRecording();

      if (!mounted) return;
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
        leading: _isReady
            ? GestureDetector(
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'screen_transition',
                    parameters: {
                      'from': 'camera',
                      'to': 'home',
                    },
                  );
                  context.go('/home?caller=/');
                },
                child: const Icon(Icons.photo_library_outlined),
              )
            : const SizedBox.shrink(),
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
                  ? BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: Theme.of(context).primaryColor,
                    )
                  : BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      color: Theme.of(context).primaryColor,
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
      final newVideoPath = '${await generateVideoPath()}.mp4';
      await File(xfile.path).rename(newVideoPath);

      await FirebaseAnalytics.instance.logEvent(
        name: 'screen_transition',
        parameters: {
          'from': 'camera',
          'to': 'home',
        },
      );
      if (!mounted) return;
      context.read<CameraBloc>().add(
            AddVideoEvent(
              videoPath: newVideoPath,
            ),
          );
      context.go('/home?caller=/');
    } catch (_) {}
  }
}
