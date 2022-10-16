import 'dart:math';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/widgets/home_thumbnail.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';
import 'package:url_launcher/url_launcher.dart';

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
          drawer: _buildDrawer(context),
          body: const _HomePage(),
        ),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const Icon(Icons.menu),
            );
          },
        ),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/icon_transparent.png',
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
              FirebaseAnalytics.instance.logEvent(
                name: 'screen_transition',
                parameters: {
                  'from': 'home',
                  'to': 'camera',
                },
              );
              context.go('/');
            },
            child: const Icon(Icons.add_a_photo_outlined),
          ),
          const SizedBox(
            width: 16,
          )
        ],
      );

  Widget _buildDrawer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(32)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          SizedBox(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon/icon_transparent.png',
                  height: 24,
                ),
                const Text(
                  'Recolf',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'Futura',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 32),
            horizontalTitleGap: 32,
            leading: Icon(
              Icons.info_outline,
              color: Colors.grey[800],
            ),
            title: Text(
              'policy'.tr(),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final _url = Uri.parse('https://recolf.com/privacy');
              if (!await launchUrl(_url)) {
                // ignore: only_throw_errors
                throw 'Could not launch $_url';
              }
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 32),
            horizontalTitleGap: 32,
            leading: Icon(
              Icons.mail_outline,
              color: Colors.grey[800],
            ),
            title: Text(
              'contact'.tr(),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final _url = Uri.parse('https://recolf.com/contact');
              if (!await launchUrl(_url)) {
                // ignore: only_throw_errors
                throw 'Could not launch $_url';
              }
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
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
                      final videos = videoMap[date]
                        ?..sort((a, b) => b.datetime.compareTo(a.datetime));
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
                  if (state.deleteMode)
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: _HomeDeleteBottomSheet(),
                    )
                  else
                    const SizedBox.shrink(),
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
        date = DateFormat(
          window.locale.languageCode == 'ja' ? 'M/d' : 'MMM d',
        ).format(video.datetime);
      } else {
        date = DateFormat(
          window.locale.languageCode == 'ja' ? 'y/M/d' : 'MMM d, yyyy',
        ).format(video.datetime);
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
