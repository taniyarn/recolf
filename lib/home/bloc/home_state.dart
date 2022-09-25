part of 'home_bloc.dart';

enum HomeStatus { initial, loaded }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.videos = const <Video>[],
    this.deleteMode = false,
    this.selectedVideos = const <Video>[],
  });

  final HomeStatus status;
  final List<Video> videos;
  final bool deleteMode;
  final List<Video> selectedVideos;

  HomeState copyWith({
    HomeStatus? status,
    List<Video>? videos,
    bool? deleteMode,
    List<Video>? selectedVideos,
  }) =>
      HomeState(
        status: status ?? this.status,
        videos: videos ?? this.videos,
        deleteMode: deleteMode ?? this.deleteMode,
        selectedVideos: selectedVideos ?? this.selectedVideos,
      );

  @override
  List<Object?> get props => [status, videos, deleteMode, selectedVideos];
}
