import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/services/video.dart';
import 'package:recolf/video/bloc/video_bloc.dart';
import 'package:recolf/video/util.dart';
import 'package:recolf/video/view/draw_view.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({Key? key, required this.videoPath, required this.id})
      : super(key: key);
  final String videoPath;
  final String id;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => VideoBloc(
          videoService: RepositoryProvider.of<VideoService>(context),
          id: id,
        ),
        child: VideoScaffold(videoPath: videoPath),
      );
}

class VideoScaffold extends StatefulWidget {
  const VideoScaffold({Key? key, required this.videoPath}) : super(key: key);
  final String videoPath;

  @override
  State<VideoScaffold> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(
      File(widget.videoPath),
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
        appBar: _buildAppBar(context),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  height: 1,
                  width: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                ),
              ),
            ),
            ControlsOverlay(
              controller: _videoPlayerController,
              onTap: () =>
                  context.read<VideoBloc>().add(const ShapesDeactivated()),
            ),
            const DrawView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SmoothVideoProgressSlider(
                videoPlayerController: _videoPlayerController,
              ),
            ),
          ],
        ),
      );

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios),
        onTap: () async {
          if (widget.videoPath ==
              context.read<VideoBloc>().state.video.videoPath) {
            context.read<VideoBloc>().add(
                  const VideoUpdated(),
                );
          } else {
            final dir = await getApplicationDocumentsDirectory();
            final path = dir.path;
            final directory = Directory('$path/video');
            await directory.create(recursive: true);
            final videoFileName = widget.videoPath.split('/').last;
            final newVideoPath = '${directory.path}/$videoFileName';
            await File(widget.videoPath).rename(newVideoPath);

            if (!mounted) return;
            context.read<VideoBloc>().add(
                  VideoUpdated(
                    videoPath: newVideoPath,
                  ),
                );
          }

          if (!mounted) return;
          unawaited(
            FirebaseAnalytics.instance.logEvent(
              name: 'screen_transition',
              parameters: {
                'from': 'video',
                'to': 'home',
              },
            ),
          );
          context.go('/home?caller=/video');
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
                    GestureDetector(
                      child: const Icon(Icons.delete_outline),
                      onTap: () {
                        context.read<VideoBloc>().add(
                              ShapeRemoved(activatedShape.first),
                            );
                      },
                    ),
                  const SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    child: Icon(state.type.getIcon()),
                    onTap: () {
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
        const SizedBox(
          width: 16,
        ),
        GestureDetector(
          child: BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              return Icon(state.mode.getIcon());
            },
          ),
          onTap: () {
            context.read<VideoBloc>().add(
                  VideoModeChanged(
                    context.read<VideoBloc>().state.mode.next(),
                  ),
                );
          },
        ),
        const SizedBox(
          width: 16,
        ),
        GestureDetector(
          child: const Icon(Icons.content_cut),
          onTap: () {
            FirebaseAnalytics.instance.logEvent(
              name: 'screen_transition',
              parameters: {
                'from': 'video',
                'to': 'trimmer',
              },
            );
            context.go(
              '/trimmer?path=${widget.videoPath}&caller=/video&id=${context.read<VideoBloc>().state.video.id}',
            );
          },
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }
}

class SmoothVideoProgressSlider extends StatelessWidget {
  const SmoothVideoProgressSlider({
    Key? key,
    required VideoPlayerController videoPlayerController,
  })  : _videoPlayerController = videoPlayerController,
        super(key: key);

  final VideoPlayerController _videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: SmoothVideoProgress(
        controller: _videoPlayerController,
        builder: (context, position, duration, _) => _VideoProgressSlider(
          position: position,
          duration: duration,
          controller: _videoPlayerController,
          swatch: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _VideoProgressSlider extends StatelessWidget {
  const _VideoProgressSlider({
    required this.position,
    required this.duration,
    required this.controller,
    required this.swatch,
  });

  final Duration position;
  final Duration duration;
  final VideoPlayerController controller;
  final Color swatch;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max).toDouble();
    return Slider(
      max: max,
      value: value,
      onChanged: (value) =>
          controller.seekTo(Duration(milliseconds: value.toInt())),
      onChangeStart: (_) => controller.pause(),
      onChangeEnd: (_) => controller.play(),
      activeColor: swatch,
      inactiveColor: Colors.white,
    );
  }
}

class ControlsOverlay extends StatefulWidget {
  const ControlsOverlay({
    Key? key,
    required this.controller,
    this.onTap,
  }) : super(key: key);
  final VideoPlayerController controller;
  final VoidCallback? onTap;
  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
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
            widget.onTap?.call();
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
