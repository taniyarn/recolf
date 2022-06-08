import 'package:recolf/models/video.dart';

class HomeVideo extends Video {
  HomeVideo({
    required String id,
    required DateTime datetime,
    required String path,
    this.thumbnailPath,
  }) : super(
          id: id,
          datetime: datetime,
          path: path,
        );

  factory HomeVideo.fromVideo({
    required Video video,
    required String? thumbnailPath,
  }) {
    return HomeVideo(
      id: video.id,
      datetime: video.datetime,
      path: video.path,
      thumbnailPath: thumbnailPath,
    );
  }

  HomeVideo copywith({
    String? id,
    DateTime? datetime,
    String? path,
    String? thumbnailPath,
  }) =>
      HomeVideo(
        id: id ?? this.id,
        datetime: datetime ?? this.datetime,
        path: path ?? this.path,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      );

  final String? thumbnailPath;
}
