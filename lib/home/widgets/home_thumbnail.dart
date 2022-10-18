import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/models/video.dart';
import 'package:video_player/video_player.dart';

class HomeThumbnail extends StatefulWidget {
  const HomeThumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final Video video;

  @override
  State<HomeThumbnail> createState() => _HomeThumbnailState();
}

class _HomeThumbnailState extends State<HomeThumbnail> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(
      File(widget.video.videoPath),
    );

    _videoPlayerController
      ..addListener(listener)
      ..initialize().then((_) => setState(() {}));

    super.initState();
  }

  void listener() {
    _videoPlayerController.seekTo(
      Duration(
        milliseconds: _videoPlayerController.value.duration.inMilliseconds ~/ 2,
      ),
    );
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () =>
          context.read<HomeBloc>().add(const SetDeleteMode(deleteMode: true)),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (context.read<HomeBloc>().state.deleteMode) {
                  context
                      .read<HomeBloc>()
                      .add(AddSelectedVideos(video: widget.video));
                  return;
                }
                FirebaseAnalytics.instance.logEvent(
                  name: 'screen_transition',
                  parameters: {
                    'from': 'home',
                    'to': 'video',
                  },
                );
                context.go(
                  '/video?path=${widget.video.videoPath}&id=${widget.video.id}',
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Image border
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    height: 1,
                    width: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return state.deleteMode
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Checkbox(
                          fillColor:
                              MaterialStateProperty.resolveWith((states) {
                            const interactiveStates = <MaterialState>{
                              MaterialState.pressed,
                              MaterialState.hovered,
                              MaterialState.focused,
                              MaterialState.selected
                            };
                            if (states.any(interactiveStates.contains)) {
                              return Theme.of(context).primaryColor;
                            }
                            return Colors.white;
                          }),
                          value: state.selectedVideos.contains(widget.video),
                          shape: const CircleBorder(),
                          onChanged: (bool? value) {
                            context.read<HomeBloc>().add(
                                  AddSelectedVideos(video: widget.video),
                                );
                          },
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
