part of 'home_bloc.dart';

enum HomeStatus { initial, loaded }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.videos = const <HomeVideo>[],
  });

  final HomeStatus status;
  final List<HomeVideo> videos;

  @override
  List<Object?> get props => [status, videos];
}
