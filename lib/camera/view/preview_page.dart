import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/camera/bloc/camera_bloc.dart';
import 'package:recolf/services/video.dart';
import 'package:video_player/video_player.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({
    Key? key,
    required this.path,
  }) : super(key: key);

  final String path;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) =>
            CameraBloc(RepositoryProvider.of<VideoService>(context)),
        child: PreviewScaffold(path: path),
      );
}

class PreviewScaffold extends StatefulWidget {
  const PreviewScaffold({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<PreviewScaffold> createState() => _PreviewScaffoldState();
}

class _PreviewScaffoldState extends State<PreviewScaffold> {
  late VideoPlayerController _videoPlayerController;
  bool played = false;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(File(widget.path));

    _videoPlayerController
      ..addListener(() {
        print(_videoPlayerController.value.position);
        setState(() {});
      })
      ..setLooping(true)
      ..initialize().then((_) => setState(() {}))
      ..play();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Directory(widget.path).deleteSync(recursive: true);
              context.go('/');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.content_cut),
              onPressed: () => context
                  .go('/trimmer?path=${widget.path}&caller=/camera/preview/'),
            ),
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
            ),
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
                    value: _videoPlayerController
                            .value.position.inMilliseconds /
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
                        played = true;
                        _videoPlayerController.pause();
                      } else {
                        played = false;
                      }
                    },
                    onChangeEnd: (_) {
                      if (played &&
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

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);
  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  bool displayIcon = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: displayIcon
              ? Container(
                  color: Colors.black12,
                  child: Center(
                    child: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.play_arrow
                          : Icons.pause,
                      color: Colors.white,
                      size: 108,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        GestureDetector(
          onTap: () {
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();

            displayIcon = true;
            Future<void>.delayed(const Duration(milliseconds: 500)).then(
              (_) => setState(
                () => displayIcon = false,
              ),
            );
          },
        ),
      ],
    );
  }
}
