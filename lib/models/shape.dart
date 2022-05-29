import 'package:hive/hive.dart';
part 'shape.g.dart';

@HiveType(typeId: 1)
class Vector extends HiveObject {
  Vector(this.x, this.y);

  @HiveField(0)
  double x;

  @HiveField(1)
  double y;

  Vector operator +(Vector other) => Vector(x + other.x, y + other.y);
}

abstract class Shape extends HiveObject {
  Shape({
    required this.active,
  });
  @HiveField(0)
  bool active;
}

@HiveType(typeId: 2)
class Line extends Shape {
  Line({
    required this.p1,
    required this.p2,
    required bool active,
  }) : super(active: active);

  @HiveField(1)
  Vector p1;
  @HiveField(2)
  Vector p2;
}

@HiveType(typeId: 3)
class Circle extends Shape {
  Circle({
    required this.topLeft,
    required this.bottomRight,
    required bool active,
  }) : super(active: active);

  @HiveField(1)
  Vector topLeft;

  @HiveField(2)
  Vector bottomRight;
}
