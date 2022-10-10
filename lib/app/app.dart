import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/camera/view/camera_page.dart';
import 'package:recolf/camera/view/preview_page.dart';
import 'package:recolf/camera/view/trimmer_page.dart';
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
          theme: ThemeData(
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              foregroundColor: Colors.white,
            ),
            textTheme:
                const TextTheme(bodyText1: TextStyle(color: Colors.white)),
            scaffoldBackgroundColor: const Color.fromRGBO(1, 1, 1, 1),
            primaryColor: const Color.fromRGBO(255, 75, 44, 1),
          ),
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
      ),
      GoRoute(
        path: '/preview',
        builder: (BuildContext context, GoRouterState state) {
          final path = state.queryParams['path'];
          return PreviewPage(key: ObjectKey(path), path: path!);
        },
      ),
      GoRoute(
        path: '/video',
        builder: (BuildContext context, GoRouterState state) {
          final path = state.queryParams['path'];
          final id = state.queryParams['id'];
          return VideoPage(videoPath: path!, id: id!);
        },
      ),
      GoRoute(
        path: '/trimmer',
        builder: (BuildContext context, GoRouterState state) {
          final path = state.queryParams['path'];
          final caller = state.queryParams['caller'];
          final id = state.queryParams['id'];
          return TrimmerPage(path: path!, caller: caller!, id: id);
        },
      ),
    ],
  );
}
