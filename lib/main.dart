import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recolf/app/app.dart';
import 'package:recolf/models/video.dart';
import 'package:recolf/services/video.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final videoService = VideoService();
  await videoService.init();
  runApp(
    MyApp(
      videoService: videoService,
    ),
  );
}
