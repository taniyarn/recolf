part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class AddVideoEvent extends CameraEvent {
  const AddVideoEvent({
    required this.videoPath,
  });

  final String videoPath;

  @override
  List<Object?> get props => [videoPath];
}
