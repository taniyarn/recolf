import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/widgets/thumbnail.dart';
import 'package:recolf/models/video.dart';

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
            return const SizedBox.shrink();
          case HomeStatus.loaded:
            final currentFormat = DateFormat('M/d');
            final previousFormat = DateFormat('y/M/d');
            final videoMap = <String, List<Video>>{};
            final currentYear = DateTime.now().year;
            for (final video in state.videos) {
              late String date;
              if (currentYear == video.datetime.year) {
                date = currentFormat.format(video.datetime);
              } else {
                date = previousFormat.format(video.datetime);
              }

              if (videoMap.containsKey(date)) {
                videoMap[date]!.add(video);
              } else {
                videoMap[date] = [video];
              }
            }

            final dates = videoMap.keys.toList();

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
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
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: videos!.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, listIndex) {
                          return Container(
                            height: 144,
                            width: 144,
                            padding: const EdgeInsets.all(8),
                            child: Thumbnail(
                              video: videos[listIndex],
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
