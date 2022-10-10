import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/widgets/home_thumbnail.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) =>
            HomeBloc(RepositoryProvider.of<VideoService>(context))
              ..add(VideosFetched()),
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: const _HomePage(),
        ),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            context.go('/');
          },
          child: const Icon(Icons.menu),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.go('/camera');
            },
            child: const Icon(Icons.add_a_photo),
          )
        ],
      );
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          switch (state.status) {
            case HomeStatus.initial:
              return const SizedBox.shrink();
            case HomeStatus.loaded:
              final videoMap = _createVideoMap(state.videos);
              final dates = videoMap.keys.toList();

              return Stack(
                children: [
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final videos = videoMap[date];
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              date,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                          _HomeVideoListView(videos: videos ?? []),
                        ],
                      );
                    },
                  ),
                  if (state.deleteMode)
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: _HomeDeleteBottomSheet(),
                    )
                  else
                    const SizedBox.shrink()
                ],
              );
          }
        },
      );

  Map<String, List<Video>> _createVideoMap(List<Video> videos) {
    final videoMap = <String, List<Video>>{};
    final currentYear = DateTime.now().year;

    for (final video in videos) {
      late String date;
      if (currentYear == video.datetime.year) {
        date = DateFormat('M/d').format(video.datetime);
      } else {
        date = DateFormat('y/M/d').format(video.datetime);
      }

      if (videoMap.containsKey(date)) {
        videoMap[date]!.add(video);
      } else {
        videoMap[date] = [video];
      }
    }

    return videoMap;
  }
}

class _HomeVideoListView extends StatelessWidget {
  const _HomeVideoListView({
    Key? key,
    required this.videos,
  }) : super(key: key);

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, listIndex) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: constraints.maxHeight,
                width: constraints.maxHeight,
                padding: const EdgeInsets.all(8),
                child: HomeThumbnail(
                  video: videos[listIndex],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeDeleteBottomSheet extends StatelessWidget {
  const _HomeDeleteBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<HomeBloc>().add(const DeleteSelectedVideos());
            },
            child: const Icon(Icons.delete),
          )
        ],
      ),
    );
  }
}
