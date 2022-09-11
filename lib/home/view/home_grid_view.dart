import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/models/home_video.dart';
import 'package:recolf/home/widgets/thumbnail.dart';

class HomeGridView extends StatelessWidget {
  const HomeGridView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        switch (state.status) {
          case HomeStatus.initial:
            return const Center(child: CircularProgressIndicator());
          case HomeStatus.loaded:
            final outputFormat = DateFormat('M/d');
            final videoMap = <String, List<HomeVideo>>{};
            for (final video in state.videos) {
              final date = outputFormat.format(video.datetime);
              if (videoMap.containsKey(date)) {
                videoMap[date]!.add(video);
              } else {
                videoMap[date] = [video];
              }
            }

            final dates = videoMap.keys.toList();

            return ListView.builder(
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final videos = videoMap[dates[index]];
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dates[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: videos!.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, listIndex) {
                          return Container(
                            height: 144,
                            width: 144,
                            padding: const EdgeInsets.all(8),
                            child: Thumbnail(
                              thumbnailPath: videos[listIndex].thumbnailPath!,
                              id: videos[listIndex].id,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
        }
      },
    );
  }
}
