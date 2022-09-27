part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class AddVideoEvent extends CameraEvent {
  const AddVideoEvent({
    required this.videoPath,
    required this.thumbnailPath,
  });

  final String videoPath;
  final String thumbnailPath;

  @override
  List<Object?> get props => [videoPath, thumbnailPath];
}
