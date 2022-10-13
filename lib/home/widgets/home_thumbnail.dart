import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/models/video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Image> generateThumbnail(String videoPath) async {
  final bytes = await VideoThumbnail.thumbnailData(
    video: videoPath,
  );
  final _image = Image.memory(
    bytes!,
    fit: BoxFit.cover,
  );
  return _image;
}

class HomeThumbnail extends StatelessWidget {
  const HomeThumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final Video video;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: generateThumbnail(video.videoPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onLongPress: () => context
                .read<HomeBloc>()
                .add(const SetDeleteMode(deleteMode: true)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      if (context.read<HomeBloc>().state.deleteMode) {
                        context
                            .read<HomeBloc>()
                            .add(AddSelectedVideos(video: video));
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
                        '/video?path=${video.videoPath}&id=${video.id}',
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Image border
                      child: snapshot.data,
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
                                value: state.selectedVideos.contains(video),
                                shape: const CircleBorder(),
                                onChanged: (bool? value) {
                                  context
                                      .read<HomeBloc>()
                                      .add(AddSelectedVideos(video: video));
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
        return const SizedBox.expand();
      },
    );
  }
}
