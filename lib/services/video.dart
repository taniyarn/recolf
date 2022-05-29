import 'package:hive/hive.dart';
import 'package:recolf/models/video.dart';
import 'package:uuid/uuid.dart';

class VideoService {
  late Box<Video> _videos;

  Future<void> init() async {
    Hive.registerAdapter(VideoAdapter());
    _videos = await Hive.openBox<Video>('videos');
  }

  List<Video> getVideos() {
    return _videos.values.toList();
  }

  void addVideo({
    required String path,
  }) {
    final id = const Uuid().v4();
    final datetime = DateTime.now();
    _videos.add(
      Video(
        id: id,
        datetime: datetime,
        path: path,
      ),
    );
  }
}
