import 'package:hive/hive.dart';
part 'video.g.dart';

@HiveType(typeId: 1)
class Video {
  @HiveField(0)
  DateTime datetime;

  @HiveField(1)
  String path;
  Video({required this.datetime, required this.path});
}
