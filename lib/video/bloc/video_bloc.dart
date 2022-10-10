import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recolf/models/shape.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc({
    required VideoService videoService,
    required String id,
  }) : super(VideoState(video: videoService.getVideoFromId(id))) {
    _videoService = videoService;
    on<VideoUpdated>(_onVideoUpdated);
    on<VideoModeChanged>(_onVideoModeChanged);
    on<ShapeTypeChanged>(_onShapeTypeChanged);
    on<ShapesChanged>(_onShapesChanged);
    on<ShapesDeactivated>(_onShapesDeactivated);
    on<ShapeRemoved>(_onShapeRemoved);
  }

  late VideoService _videoService;

  Future<void> _onVideoUpdated(
    VideoUpdated event,
    Emitter<VideoState> emit,
  ) async {
    await _videoService.updateVideo(
      id: state.video.id,
      videoPath: event.videoPath,
      thumbnailPath: event.thumbnailPath,
      shapes: state.video.shapes.map((shape) {
        shape.active = false;
        return shape;
      }).toList(),
    );
  }

  Future<void> _onVideoModeChanged(
    VideoModeChanged event,
    Emitter<VideoState> emit,
  ) async {
    emit(state.copyWith(mode: event.mode));
  }

  Future<void> _onShapeTypeChanged(
    ShapeTypeChanged event,
    Emitter<VideoState> emit,
  ) async {
    emit(state.copyWith(type: event.type));
  }

  Future<void> _onShapesChanged(
    ShapesChanged event,
    Emitter<VideoState> emit,
  ) async {
    emit(state.copyWith(video: state.video.copyWith(shapes: event.shapes)));
  }

  Future<void> _onShapesDeactivated(
    ShapesDeactivated event,
    Emitter<VideoState> emit,
  ) async {
    emit(
      state.copyWith(
        video: state.video.copyWith(
          shapes: state.video.shapes.map((shape) {
            shape.active = false;
            return shape;
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _onShapeRemoved(
    ShapeRemoved event,
    Emitter<VideoState> emit,
  ) async {
    state.video.shapes.remove(event.shape);
    emit(
      state.copyWith(
        video: state.video.copyWith(
          shapes: state.video.shapes,
        ),
      ),
    );
  }
}
