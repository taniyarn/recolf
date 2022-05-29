import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/camera/view/camera_page.dart';
import 'package:recolf/camera/view/preview_page.dart';
import 'package:recolf/home/view/home_page.dart';
import 'package:recolf/services/video.dart';
import 'package:recolf/video/view/video_page.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.videoService}) : super(key: key);
  final VideoService videoService;

  @override
  Widget build(BuildContext context) => RepositoryProvider(
        create: (context) => videoService,
        child: MaterialApp.router(
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
        ),
      );

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage(),
      ),
      GoRoute(
        path: '/camera',
        builder: (BuildContext context, GoRouterState state) =>
            const CameraPage(),
        routes: [
          GoRoute(
            path: 'preview',
            builder: (BuildContext context, GoRouterState state) {
              final path = state.queryParams['path'];
              return PreviewPage(path: path!);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/video',
        builder: (BuildContext context, GoRouterState state) {
          final path = state.queryParams['path'];
          final shapes = state.queryParams['shapes'];
          return VideoPage(path: path!);
        },
      ),
    ],
  );
}
