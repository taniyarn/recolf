import 'package:flutter/material.dart';
import 'package:recolf/models/shape.dart';
import 'package:recolf/my_flutter_app_icons.dart';
import 'package:recolf/video/bloc/video_bloc.dart';

extension ExtentionOffset on Offset {
  Vector toVector() {
    return Vector(dx, dy);
  }
}

extension ExtentionVector on Vector {
  Offset toOffset() {
    return Offset(x, y);
  }
}

extension VideoModeEx on VideoMode {
  VideoMode next() {
    switch (this) {
      case VideoMode.viewMode:
        return VideoMode.drawMode;
      case VideoMode.drawMode:
        return VideoMode.viewMode;
    }
  }

  IconData getIcon() {
    switch (this) {
      case VideoMode.viewMode:
        return Icons.edit_off;
      case VideoMode.drawMode:
        return Icons.edit;
    }
  }
}

extension ShapeTypeEx on ShapeType {
  ShapeType next() {
    switch (this) {
      case ShapeType.line:
        return ShapeType.circle;
      case ShapeType.circle:
        return ShapeType.line;
    }
  }

  IconData getIcon() {
    switch (this) {
      case ShapeType.line:
        return MyFlutterApp.flow_line;
      case ShapeType.circle:
        return Icons.circle_outlined;
    }
  }
}

extension Ex on List<Shape> {
  void deactivate() {
    forEach((e) => e.active = false);
  }

  void sortByActivate() {
    sort(
      (a, b) {
        if (a.active) {
          return 1;
        } else if (b.active) {
          return -1;
        }
        return 0;
      },
    );
  }
}
