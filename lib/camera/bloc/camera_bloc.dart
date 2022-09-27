import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recolf/services/video.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc(this._video) : super(CameraState()) {
    on<AddVideoEvent>((event, emit) {
      _video.addVideo(
        videoPath: event.videoPath,
        thumbnailPath: event.thumbnailPath,
      );
    });
  }

  final VideoService _video;
}
