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
  }

  final VideoService _video;

  Future<void> _onVideosFetched(
    VideosFetched event,
    Emitter<HomeState> emit,
  ) async {
    var _tempDir = '';
    await getTemporaryDirectory().then((d) => _tempDir = d.path);

    final stream = _video.subscribeVideos().asyncMap((videos) async {
      return generateHomeVideo(videos, _tempDir);
    });

    emit(
      HomeState(
        status: HomeStatus.loaded,
        videos: await generateHomeVideo(_video.getVideos(), _tempDir),
      ),
    );

    await emit.forEach(
      stream,
      onData: (List<HomeVideo> data) {
        return HomeState(
          status: HomeStatus.loaded,
          videos: data,
        );
      },
    );
  }

  Future<List<HomeVideo>> generateHomeVideo(
    List<Video> videos,
    String tempDir,
  ) async {
    final homeVideos = <HomeVideo>[];
    for (final video in videos) {
      var v =
          state.videos.firstWhereOrNull((element) => element.id == video.id);
      if (v == null) {
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: video.path,
          thumbnailPath: tempDir,
        );

        v = HomeVideo.fromVideo(
          video: video,
          thumbnailPath: thumbnailPath,
        );
      }
      homeVideos.add(v);
    }

    return homeVideos;
  }

  @override
  Future<void> close() {
    _cache = state.videos;
    return super.close();
  }
}
