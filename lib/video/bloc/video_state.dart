part of 'video_bloc.dart';

class VideoState extends Equatable {
  const VideoState(this.video);

  final Video video;

  @override
  List<Object?> get props => [video];
}
