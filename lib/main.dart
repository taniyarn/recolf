import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recolf/app/app.dart';
import 'package:recolf/firebase_options.dart';
import 'package:recolf/services/video.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await Hive.initFlutter();
    final videoService = VideoService();
    await videoService.init();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    await EasyLocalization.ensureInitialized();
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
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
