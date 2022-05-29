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
  }) : super(VideoState(videoService.getVideoFromId(id))) {
    _videoService = videoService;
    on<VideoUpdated>(_onVideoUpdated);
  }

  late VideoService _videoService;

  Future<void> _onVideoUpdated(
    VideoUpdated event,
    Emitter<VideoState> emit,
  ) async {
    await _videoService.updateVideo(id: event.id, shapes: event.shapes);
  }
}
