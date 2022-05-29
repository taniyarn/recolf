import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolf/home/models/home_video.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._video) : super(const HomeState()) {
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
        videos:
            videos.map((video) => HomeVideo.fromVideo(video: video)).toList(),
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
    final _newVideos = <HomeVideo>[];
    for (var video in state.videos) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: video.path,
        headers: {
          "USERHEADER1": "user defined header1",
          "USERHEADER2": "user defined header2",
        },
        thumbnailPath: _tempDir,
        imageFormat: ImageFormat.PNG,
      );
      _newVideos.add(video.copyWith(thumbnailPath: thumbnailPath));
    }
    emit(
      HomeState(
        status: HomeStatus.loaded,
        videos: _newVideos,
      ),
    );
  }
}
