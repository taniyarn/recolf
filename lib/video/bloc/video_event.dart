part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class VideoUpdated extends VideoEvent {
  const VideoUpdated({this.videoPath, this.thumbnailPath});

  final String? videoPath;
  final String? thumbnailPath;
}

class VideoModeChanged extends VideoEvent {
  const VideoModeChanged(this.mode);

  final VideoMode mode;
}

class ShapeTypeChanged extends VideoEvent {
  const ShapeTypeChanged(this.type);

  final ShapeType type;
}

class ShapesChanged extends VideoEvent {
  const ShapesChanged(this.shapes);

  final List<Shape> shapes;

  @override
  List<Object?> get props => [shapes];
}

class ShapesDeactivated extends VideoEvent {
  const ShapesDeactivated();
}

class ShapeRemoved extends VideoEvent {
  const ShapeRemoved(this.shape);

  final Shape shape;
}
