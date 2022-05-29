import 'package:flutter/material.dart';
import 'package:recolf/models/shape.dart';

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
