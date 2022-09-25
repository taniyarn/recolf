import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/view/home_grid_view.dart';
import 'package:recolf/services/video.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(RepositoryProvider.of<VideoService>(context))
            ..add(VideosFetched()),
      child: Scaffold(
        appBar: AppBar(
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
        ),
        body: const HomeGridView(),
      ),
    );
  }
}
