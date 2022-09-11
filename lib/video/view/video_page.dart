import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/services/video.dart';
import 'package:recolf/video/bloc/video_bloc.dart';
import 'package:recolf/video/util.dart';
import 'package:recolf/video/view/draw_view.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => VideoBloc(
          videoService: RepositoryProvider.of<VideoService>(context),
          id: id,
        ),
        child: const VideoScaffold(),
      );
}

class VideoScaffold extends StatefulWidget {
  const VideoScaffold({Key? key}) : super(key: key);

  @override
  State<VideoScaffold> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  late VideoPlayerController _videoPlayerController;
  bool played = false;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(
      File(context.read<VideoBloc>().state.video.path),
    );

    _videoPlayerController
      ..addListener(listener)
      ..setLooping(true)
      ..initialize().then((_) => setState(() {}))
      ..play();
    super.initState();
  }

  void listener() {
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController
      ..removeListener(listener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<VideoBloc>().add(
                    const VideoUpdated(),
                  );
              context.go('/');
            },
          ),
          actions: [
            BlocBuilder<VideoBloc, VideoState>(
              builder: (context, state) {
                if (state.mode == VideoMode.drawMode) {
                  final activatedShape =
                      state.video.shapes.where((shape) => shape.active);
                  return Row(
                    children: [
                      if (activatedShape.isEmpty)
                        const SizedBox.shrink()
                      else
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            context.read<VideoBloc>().add(
                                  ShapeRemoved(activatedShape.first),
                                );
                          },
                        ),
                      IconButton(
                        icon: Icon(state.type.getIcon()),
                        onPressed: () {
                          context.read<VideoBloc>().add(
                                ShapeTypeChanged(state.type.next()),
                              );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: BlocBuilder<VideoBloc, VideoState>(
                builder: (context, state) {
                  return Icon(state.mode.getIcon());
                },
              ),
              onPressed: () {
                context.read<VideoBloc>().add(
                      VideoModeChanged(
                        context.read<VideoBloc>().state.mode.next(),
                      ),
                    );
              },
            ),
            IconButton(
              icon: const Icon(Icons.content_cut),
              onPressed: () => context.go(
                '/trimmer?path=${context.read<VideoBloc>().state.video.path}&caller=/video&id=${context.read<VideoBloc>().state.video.id}',
              ),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            VideoPlayer(_videoPlayerController),
            _ControlsOverlay(controller: _videoPlayerController),
            const DrawView(),
            if (_videoPlayerController.value.duration.inMilliseconds == 0 ||
                _videoPlayerController.value.duration.inMilliseconds <
                    _videoPlayerController.value.position.inMilliseconds)
              const SizedBox.shrink()
            else
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 56,
                  child: Slider(
                    activeColor: const Color.fromARGB(255, 255, 0, 0),
                    inactiveColor: Colors.grey[600],
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
                        _videoPlayerController.pause();
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
            context.read<VideoBloc>().add(const ShapesDeactivated());
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
