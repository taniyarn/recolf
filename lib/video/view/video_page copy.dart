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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoBloc(
        videoService: RepositoryProvider.of<VideoService>(context),
        id: id,
      ),
      child: const VideoScaffold(),
    );
  }
}

class VideoScaffold extends StatefulWidget {
  const VideoScaffold({Key? key}) : super(key: key);

  @override
  State<VideoScaffold> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(
      File(context.read<VideoBloc>().state.video.path),
    );
    // _videoPlayerController.addListener(() {
    //   setState(() {});
    // });
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              if (state.mode == VideoMode.drawMode) {
                return IconButton(
                  icon: Icon(state.type.getIcon()),
                  onPressed: () {
                    context.read<VideoBloc>().add(
                          ShapeTypeChanged(state.type.next()),
                        );
                  },
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
            icon: const Icon(Icons.check),
            onPressed: () {
              context.go('/');
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Stack(
              children: [
                VideoPlayer(_videoPlayerController),
                _ControlsOverlay(controller: _videoPlayerController),
                const DrawView(),
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
                            _videoPlayerController.value.duration * progress);
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
            );
          }
        },
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
