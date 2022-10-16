import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/camera/view/camera_page.dart';
import 'package:recolf/home/view/home_page.dart';
import 'package:recolf/services/video.dart';
import 'package:recolf/video/view/trimmer_page.dart';
import 'package:recolf/video/view/video_page.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.videoService}) : super(key: key);
  final VideoService videoService;

  @override
  Widget build(BuildContext context) => RepositoryProvider(
        create: (context) => videoService,
        child: MaterialApp.router(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              foregroundColor: Colors.white,
            ),
            textTheme:
                const TextTheme(bodyText1: TextStyle(color: Colors.white)),
            scaffoldBackgroundColor: Colors.black,
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
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) {
          final caller = state.queryParams['caller'];
          return _buildPageWithAnimation(
            const HomePage(),
            Offset(caller == '/' ? -1 : 1, 0),
          );
        },
      ),
      GoRoute(
        path: '/video',
        builder: (context, state) {
          final path = state.queryParams['path'];
          final id = state.queryParams['id'];
          return VideoPage(videoPath: path!, id: id!);
        },
        // builder: (BuildContext context, GoRouterState state) {
        //   final path = state.queryParams['path'];
        //   final id = state.queryParams['id'];

        //   return VideoPage(videoPath: path!, id: id!);
        // },
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

CustomTransitionPage<void> _buildPageWithAnimation(Widget page, Offset begin) {
  return CustomTransitionPage<void>(
    child: page,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1, 0),
          ).animate(secondaryAnimation),
          child: child,
        ),
      );
    },
  );
}
