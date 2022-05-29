import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/models/shape.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.thumbnailPath,
    required this.path,
    required this.shapes,
  }) : super(key: key);

  final String thumbnailPath;
  final String path;
  final List<Shape> shapes;

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
        context.go('/video?path=$path');
      },
      child: image,
    );
  }
}
