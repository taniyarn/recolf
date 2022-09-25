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
    on<SetDeleteMode>(_onSetDeleteMode);
    on<AddSelectedVideos>(_onAddSelectedVideos);
    on<DeleteSelectedVideos>(_onDeleteSelectedVideos);
  }

  final VideoService _video;

  Future<void> _onVideosFetched(
    VideosFetched event,
    Emitter<HomeState> emit,
  ) async {
    final stream = _video.subscribeVideos();
    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        videos: _video.getVideos(),
      ),
    );

    await emit.forEach(
      stream,
      onData: (List<Video> data) {
        return state.copyWith(
          status: HomeStatus.loaded,
          videos: data,
        );
      },
    );
  }

  Future<void> _onSetDeleteMode(
    SetDeleteMode event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        deleteMode: event.deleteMode,
        selectedVideos: [],
      ),
    );
  }

  Future<void> _onAddSelectedVideos(
    AddSelectedVideos event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(selectedVideos: [...state.selectedVideos, event.video]),
    );
  }

  Future<void> _onDeleteSelectedVideos(
    DeleteSelectedVideos event,
    Emitter<HomeState> emit,
  ) async {
    _video.deleteVideos(
      deletedVideos: state.selectedVideos,
    );
    add(const SetDeleteMode(deleteMode: false));
  }

  @override
  Future<void> close() {
    _cache = state.videos;
    return super.close();
  }
}
