import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/models/video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final Video video;

  Future<String> temp() async {
    var _tempDir = '';
    await getTemporaryDirectory().then((d) => _tempDir = d.path);
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: video.path,
      thumbnailPath: _tempDir,
    );

    return thumbnailPath!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: temp(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final file = File(snapshot.data!);
          final bytes = file.readAsBytesSync();
          final image = Image.memory(
            bytes,
            fit: BoxFit.cover,
          );
          return GestureDetector(
            onTap: () {
              context.go('/video?id=${video.id}');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Image border
              child: SizedBox.fromSize(
                size: const Size.fromRadius(16), // Image radius
                child: image,
              ),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(16), // Image border
          child: Container(
            color: Colors.grey[300],
          ),
        );
      },
    );
  }
}
