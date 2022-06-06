part of 'video_bloc.dart';

enum VideoMode { viewMode, drawMode }
enum ShapeType { line, circle }

extension ShapeTypeEx on ShapeType {
  ShapeType next() {
    switch (this) {
      case ShapeType.line:
        return ShapeType.circle;
      case ShapeType.circle:
        return ShapeType.line;
    }
  }
}

class VideoState extends Equatable {
  const VideoState({
    required this.video,
    this.mode = VideoMode.viewMode,
    this.type = ShapeType.line,
  });

  final Video video;
  final VideoMode mode;
  final ShapeType type;

  VideoState copyWith({
    Video? video,
    VideoMode? mode,
    ShapeType? type,
  }) =>
      VideoState(
        video: video ?? this.video,
        mode: mode ?? this.mode,
        type: type ?? this.type,
      );

  @override
  List<Object?> get props => [video, mode, type];
}
