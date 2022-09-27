import 'package:hive/hive.dart';
import 'package:recolf/models/shape.dart';
part 'video.g.dart';

@HiveType(typeId: 0)
class Video extends HiveObject {
  Video({
    required this.id,
    required this.datetime,
    required this.videoPath,
    required this.thumbnailPath,
    List<Shape>? shapes,
  }) : shapes = shapes ?? [];

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime datetime;

  @HiveField(2)
  String videoPath;

  @HiveField(3)
  String thumbnailPath;

  @HiveField(4)
  List<Shape> shapes;

  Video copyWith({
    String? id,
    DateTime? datetime,
    String? videoPath,
    String? thumbnailPath,
    List<Shape>? shapes,
  }) =>
      Video(
        id: id ?? this.id,
        datetime: datetime ?? this.datetime,
        videoPath: videoPath ?? this.videoPath,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
        shapes: shapes ?? this.shapes,
      );
}
