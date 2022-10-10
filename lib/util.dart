import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

String generateVideoName() {
  final dateTime = DateTime.now();
  return DateFormat('yyyy-dd-H-m-s').format(dateTime);
}

Future<String> generateVideoPath() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = dir.path;
  final directory = Directory('$path/video');
  await directory.create(recursive: true);

  return '${directory.path}/${generateVideoName()}';
}
