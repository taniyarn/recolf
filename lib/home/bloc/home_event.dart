part of 'home_bloc.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class VideosFetched extends HomeEvent {}

class SetDeleteMode extends HomeEvent {
  const SetDeleteMode({required this.deleteMode});
  final bool deleteMode;
}

class AddSelectedVideos extends HomeEvent {
  const AddSelectedVideos({required this.video});
  final Video video;
}
