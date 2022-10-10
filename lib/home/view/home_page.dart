import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/widgets/home_thumbnail.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';

final Map<String, Widget> _cache = {};

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
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/icon.png',
                height: 24,
              ),
              const Text(
                'Recolf',
                style: TextStyle(fontFamily: 'Futura'),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.go('/camera');
            },
            child: const Icon(Icons.add_a_photo_outlined),
          ),
          const SizedBox(
            width: 16,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: state.deleteMode
                        ? const Align(
                            alignment: Alignment.bottomCenter,
                            child: _HomeDeleteBottomSheet(),
                          )
                        : const SizedBox.shrink(),
                  ),
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
      height: 320,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        padding: const EdgeInsets.all(4),
        itemBuilder: (context, listIndex) {
          final video = videos[listIndex];
          if (_cache.containsKey(video.videoPath)) {
            return _cache[video.videoPath]!;
          }
          final item = LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: constraints.maxHeight,
                width: constraints.maxHeight / sqrt2,
                padding: const EdgeInsets.all(4),
                child: HomeThumbnail(
                  video: video,
                ),
              );
            },
          );
          _cache[video.videoPath] = item;

          return item;
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 32, 8, 32),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context
                    .read<HomeBloc>()
                    .add(const SetDeleteMode(deleteMode: false));
              },
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    'cancel'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontFamily: 'Futura',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<HomeBloc>().add(const DeleteSelectedVideos());
              },
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Text(
                    'delete'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Futura',
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
