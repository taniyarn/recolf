import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        borderRadius: BorderRadius.circular(16), // Image border
        child: SizedBox.fromSize(
          size: const Size.fromRadius(16), // Image radius
          child: image,
        ),
      ),
    );
  }
}
