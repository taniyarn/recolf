import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/camera/bloc/camera_bloc.dart';
import 'package:recolf/services/video.dart';
import 'package:video_player/video_player.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CameraBloc(RepositoryProvider.of<VideoService>(context)),
      child: PreviewScaffold(path: path),
    );
  }
}

class PreviewScaffold extends StatefulWidget {
  const PreviewScaffold({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<PreviewScaffold> createState() => _PreviewScaffoldState();
}

class _PreviewScaffoldState extends State<PreviewScaffold> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.path));

    _videoPlayerController
      ..addListener(() {
        setState(() {});
      })
      ..setLooping(true);
    _videoPlayerController.initialize().then((_) => setState(() {}));
    _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              context.read<CameraBloc>().add(
                    AddVideoEvent(
                      path: widget.path,
                    ),
                  );
              context.go('/');
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          VideoPlayer(_videoPlayerController),
          _ControlsOverlay(controller: _videoPlayerController),
          if (_videoPlayerController.value.duration.inMilliseconds == 0)
            const SizedBox.shrink()
          else
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 56,
                child: Slider(
                  value: _videoPlayerController.value.position.inMilliseconds /
                      _videoPlayerController.value.duration.inMilliseconds,
                  onChanged: (progress) {
                    _videoPlayerController.seekTo(
                      _videoPlayerController.value.duration * progress,
                    );
                  },
                  onChangeStart: (_) {
                    if (!_videoPlayerController.value.isInitialized) {
                      return;
                    }
                    if (_videoPlayerController.value.isPlaying) {
                      _videoPlayerController.pause();
                    }
                  },
                  onChangeEnd: (_) {
                    if (_videoPlayerController.value.isPlaying &&
                        _videoPlayerController.value.position !=
                            _videoPlayerController.value.duration) {
                      _videoPlayerController.play();
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
