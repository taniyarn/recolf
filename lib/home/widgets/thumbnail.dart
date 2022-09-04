import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/models/shape.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.thumbnailPath,
    required this.id,
  }) : super(key: key);

  final String thumbnailPath;
  final String id;

  @override
  Widget build(BuildContext context) {
    final file = File(thumbnailPath);
    final bytes = file.readAsBytesSync();
    final image = Image.memory(
      bytes,
      fit: BoxFit.cover,
    );
    return GestureDetector(
        onTap: () {
          context.go('/video?id=$id');
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32), // Image border
          child: SizedBox.fromSize(
            size: Size.fromRadius(48), // Image radius
            child: image,
          ),
        ));
  }
}
