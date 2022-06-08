import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/my_flutter_app_icons.dart';
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
    await _videoPlayerController.initialize();

    await _videoPlayerController.setLooping(true);
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
                const DrawView(),
              ],
            );
          }
        },
      ),
    );
  }
}
