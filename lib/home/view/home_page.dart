import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/home/bloc/home_bloc.dart';
import 'package:recolf/home/view/home_grid_view.dart';
import 'package:recolf/home/widgets/thumbnail.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(RepositoryProvider.of<VideoService>(context))
            ..add(VideosFetched()),
      child: Scaffold(
        body: const HomeGridView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/camera'),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
