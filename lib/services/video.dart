import 'dart:io';

import 'package:hive/hive.dart';
import 'package:recolf/models/shape.dart';
import 'package:recolf/models/video.dart';
import 'package:uuid/uuid.dart';

class VideoService {
  late Box<Video> _videos;

  Future<void> init() async {
    Hive
      ..registerAdapter(VideoAdapter())
      ..registerAdapter(LineAdapter())
      ..registerAdapter(CircleAdapter())
      ..registerAdapter(VectorAdapter());
    _videos = await Hive.openBox<Video>('videos');
  }

  List<Video> getVideos() {
    return _videos.values.toList();
  }

  Stream<List<Video>> subscribeVideos() {
    return _videos.watch().map((_) => _videos.values.toList());
  }

  Video getVideoFromId(String id) {
    return _videos.values.firstWhere((video) => video.id == id);
  }

  void addVideo({
    required String videoPath,
  }) {
    final id = const Uuid().v4();
    final datetime = DateTime.now();
    _videos.add(
      Video(
        id: id,
        datetime: datetime,
        videoPath: videoPath,
      ),
    );
  }

  Future<void> updateVideo({
    required String id,
    required String? videoPath,
    required List<Shape> shapes,
  }) async {
    final videoToEdit = _videos.values.firstWhere((v) => v.id == id);
    final index = videoToEdit.key as int;

    await _videos.put(
      index,
      videoToEdit.copyWith(
        videoPath: videoPath,
        shapes: shapes,
      ),
    );

    if (videoPath != null && videoPath != videoToEdit.videoPath) {
      Directory(videoToEdit.videoPath).deleteSync(recursive: true);
    }
  }

  void deleteVideos({
    required List<Video> deletedVideos,
  }) {
    final videos = _videos.values.where(
      (video) =>
          deletedVideos.any((deletedVideo) => deletedVideo.id == video.id),
    );
    final keys = videos.map((video) => video.key as int);

    _videos.deleteAll(keys);
  }
}
