import 'package:hive/hive.dart';
import 'package:recolf/models/shape.dart';
part 'video.g.dart';

@HiveType(typeId: 0)
class Video {
  Video({
    required this.id,
    required this.datetime,
    required this.path,
    this.shapes = const [],
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime datetime;

  @HiveField(2)
  String path;

  @HiveField(3)
  List<Shape> shapes;
}
