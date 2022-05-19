import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recolf/models/video.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Video>('videoBox');
    return Scaffold(
      body: ListView.builder(
        itemCount: box.length,
        itemBuilder: (context, listIndex) {
          return ListTile(
            title: Text(box.getAt(listIndex)!.path),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/camera'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
