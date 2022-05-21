import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/models/video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<List<Image>> genThumbnails() async {
    final _images = <Image>[];
    final videoBox = Hive.box<Video>('videoBox');

    final box = videoBox.toMap();

    for (final b in box.values) {
      var _tempDir = '';
      await getTemporaryDirectory().then((d) => _tempDir = d.path);
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: b.path,
        headers: {
          "USERHEADER1": "user defined header1",
          "USERHEADER2": "user defined header2",
        },
        thumbnailPath: _tempDir,
        imageFormat: ImageFormat.PNG,
      );
      print("thumbnail file is located: $thumbnailPath");

      final file = File(thumbnailPath!);
      final bytes = file.readAsBytesSync();
      final _image = Image.memory(
        bytes,
        fit: BoxFit.cover,
      );
      _images.add(_image);
    }

    return _images;
  }

  @override
  Widget build(BuildContext context) {
    final videoBox = Hive.box<Video>('videoBox');
    return Scaffold(
      body: FutureBuilder<List<Image>>(
        future: genThumbnails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ValueListenableBuilder(
              valueListenable: videoBox.listenable(),
              builder: (context, Box<Video> box, _) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    crossAxisCount: 4,
                  ),
                  padding: EdgeInsets.all(4),
                  itemCount: box.length,
                  itemBuilder: (context, listIndex) {
                    return snapshot.data![listIndex];
                  },
                );
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/draw'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
