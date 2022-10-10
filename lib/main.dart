import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recolf/app/app.dart';
import 'package:recolf/services/video.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  await EasyLocalization.ensureInitialized();
  final videoService = VideoService();
  await videoService.init();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ja')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(
        videoService: videoService,
      ),
    ),
  );
  FlutterNativeSplash.remove();
}
