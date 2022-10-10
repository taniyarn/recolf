import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/camera/view/preview_page.dart';
import 'package:recolf/services/video.dart';
import 'package:recolf/video/bloc/video_bloc.dart';
import 'package:recolf/video/util.dart';
import 'package:recolf/video/view/draw_view.dart';
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
  bool played = false;

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
            VideoPlayer(_videoPlayerController),
            ControlsOverlay(controller: _videoPlayerController),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          if (widget.videoPath ==
              context.read<VideoBloc>().state.video.videoPath) {
            context.read<VideoBloc>().add(
                  const VideoUpdated(),
                );
          } else {
            final thumbnailPath = await generateThumbnail(widget.videoPath);
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
                    thumbnailPath: thumbnailPath,
                  ),
                );
          }

          if (!mounted) return;
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
            '/trimmer?path=${widget.videoPath}&caller=/video&id=${context.read<VideoBloc>().state.video.id}',
          ),
        ),
      ],
    );
  }
}
