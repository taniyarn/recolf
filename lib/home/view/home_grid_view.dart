import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/widgets/thumbnail.dart';

class HomeGridView extends StatelessWidget {
  const HomeGridView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      switch (state.status) {
        case HomeStatus.initial:
          return const CircularProgressIndicator();
        case HomeStatus.loaded:
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              crossAxisCount: 4,
            ),
            padding: const EdgeInsets.all(4),
            itemCount: state.videos.length,
            itemBuilder: (context, listIndex) {
              return Thumbnail(
                thumbnailPath: state.videos[listIndex].thumbnailPath,
                path: state.videos[listIndex].path,
                shapes: const [],
              );
            },
          );
      }
    });
  }
}
