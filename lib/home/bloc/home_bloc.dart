import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/home/models/home_video.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'home_event.dart';
part 'home_state.dart';

var _cache = <HomeVideo>[];

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._video) : super(HomeState(videos: _cache)) {
    on<VideosFetched>(_onVideosFetched);
    on<ThumbnailsFetched>(_onThumbnailsFetched);
  }

  final VideoService _video;

  void _onVideosFetched(
    VideosFetched event,
    Emitter<HomeState> emit,
  ) {
    final videos = _video.getVideos();
    emit(
      HomeState(
        videos: videos.map((video) {
          final v = state.videos
              .firstWhereOrNull((element) => element.id == video.id);

          return HomeVideo.fromVideo(
            video: video,
            thumbnailPath: v?.thumbnailPath,
          );
        }).toList(),
      ),
    );
    add(ThumbnailsFetched());
  }

  Future<void> _onThumbnailsFetched(
    ThumbnailsFetched event,
    Emitter<HomeState> emit,
  ) async {
    var _tempDir = '';
    await getTemporaryDirectory().then((d) => _tempDir = d.path);
    final _newVideos = state.videos;
    for (var video in state.videos) {
      if (video.thumbnailPath != null) {
        continue;
      }
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: video.path,
        thumbnailPath: _tempDir,
      );
      final index = _newVideos.indexOf(video);
      _newVideos[index] = video.copyWith(thumbnailPath: thumbnailPath);
    }
    emit(
      HomeState(
        status: HomeStatus.loaded,
        videos: _newVideos,
      ),
    );
  }

  @override
  Future<void> close() {
    _cache = state.videos;
    return super.close();
  }
}
