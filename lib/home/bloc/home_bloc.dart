import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';

part 'home_event.dart';
part 'home_state.dart';

var _cache = <Video>[];

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._video) : super(HomeState(videos: _cache)) {
    on<VideosFetched>(_onVideosFetched);
  }

  final VideoService _video;

  Future<void> _onVideosFetched(
    VideosFetched event,
    Emitter<HomeState> emit,
  ) async {
    final stream = _video.subscribeVideos();
    emit(
      HomeState(
        status: HomeStatus.loaded,
        videos: _video.getVideos(),
      ),
    );
    await emit.forEach(
      stream,
      onData: (List<Video> data) {
        return HomeState(
          status: HomeStatus.loaded,
          videos: data,
        );
      },
    );
  }

  @override
  Future<void> close() {
    _cache = state.videos;
    return super.close();
  }
}
