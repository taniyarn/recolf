part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class VideoUpdated extends VideoEvent {
  const VideoUpdated({
    required this.id,
    required this.shapes,
  });
  final String id;
  final List<Shape> shapes;

  @override
  List<Object?> get props => [shapes];
}