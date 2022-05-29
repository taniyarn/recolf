import 'dart:ui';

abstract class Shape {
  Shape({
    required this.active,
  });
  bool active;
}

class Line extends Shape {
  Line({
    required this.p1,
    required this.p2,
    required bool active,
  }) : super(active: active);
  Offset p1;
  Offset p2;
}

class Circle extends Shape {
  Circle({
    required this.topLeft,
    required this.bottomRight,
    required bool active,
  }) : super(active: active);
  Offset topLeft;
  Offset bottomRight;
}
