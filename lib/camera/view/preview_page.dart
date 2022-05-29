import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recolf/camera/bloc/camera_bloc.dart';
import 'package:recolf/models/video.dart';
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

  Future<void> _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.path));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.black26,
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
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );
  }
}
