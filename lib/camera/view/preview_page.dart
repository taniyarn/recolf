import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/camera/bloc/camera_bloc.dart';
import 'package:recolf/services/video.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<String> generateThumbnail(String videoPath) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = dir.path;
  final directory = Directory('$path/video');
  await directory.create(recursive: true);
  final thumbnailPath = await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: directory.path,
  );

  return thumbnailPath!;
}

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
          leading: GestureDetector(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              Directory(widget.path).deleteSync(recursive: true);
              context.go('/');
            },
          ),
          actions: [
            GestureDetector(
              child: const Icon(Icons.content_cut),
              onTap: () => context
                  .go('/trimmer?path=${widget.path}&caller=/camera/preview/'),
            ),
            GestureDetector(
              child: const Icon(Icons.check),
              onTap: () async {
                final thumbnailPath = await generateThumbnail(widget.path);
                context.read<CameraBloc>().add(
                      AddVideoEvent(
                        videoPath: widget.path,
                        thumbnailPath: thumbnailPath,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 112,
                child: SmoothVideoProgress(
                  controller: _videoPlayerController,
                  builder: (context, position, duration, _) =>
                      _VideoProgressSlider(
                    position: position,
                    duration: duration,
                    controller: _videoPlayerController,
                    swatch: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
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
