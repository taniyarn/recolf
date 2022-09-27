import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/models/video.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final Video video;

  @override
  Widget build(BuildContext context) {
    final file = File(video.thumbnailPath);
    final bytes = file.readAsBytesSync();
    final image = Image.memory(
      bytes,
      fit: BoxFit.cover,
    );

    return GestureDetector(
      onLongPress: () =>
          context.read<HomeBloc>().add(const SetDeleteMode(deleteMode: true)),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                context.go('/video?id=${video.id}');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16), // Image border
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(16), // Image radius
                  child: image,
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
                    ? Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.amber,
                        value: state.selectedVideos.contains(video),
                        shape: const CircleBorder(),
                        onChanged: (bool? value) {
                          context
                              .read<HomeBloc>()
                              .add(AddSelectedVideos(video: video));
                        },
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
