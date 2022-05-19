import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recolf/app/app.dart';
import 'package:recolf/models/video.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VideoAdapter());
  await Hive.openBox<Video>('videoBox');
  runApp(MyApp());
}
