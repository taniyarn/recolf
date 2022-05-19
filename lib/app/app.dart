import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/camera/view/video_page.dart';
import 'package:recolf/camera/view/camera_page.dart';

import 'package:recolf/home/view/home_page.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
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
              path: 'video',
              builder: (BuildContext context, GoRouterState state) {
                final path = state.queryParams['path'];
                return VideoPage(path: path!);
              }),
        ],
      ),
    ],
  );
}
