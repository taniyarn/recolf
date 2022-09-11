import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerPage extends StatefulWidget {
  const TrimmerPage({
    Key? key,
    required this.path,
    required this.caller,
    this.id,
  }) : super(key: key);
  final String path;
  final String caller;
  final String? id;

  @override
  State<StatefulWidget> createState() => _TrimmerPageState();
}

class _TrimmerPageState extends State<TrimmerPage> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0;
  double _endValue = 0;

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: File(widget.path));
  }

  void _saveVideo(BuildContext context) {
    const videoFolderName = 'video';

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      videoFolderName: videoFolderName,
      onSave: (outputPath) async {
        Directory(widget.path).deleteSync(recursive: true);
        await File(outputPath!).rename(widget.path);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: VideoViewer(
                    trimmer: _trimmer,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Align(
              alignment: Alignment.topCenter,
              child: TrimEditor(
                fit: BoxFit.cover,
                trimmer: _trimmer,
                viewerWidth: MediaQuery.of(context).size.width - 32,
                durationTextStyle: const TextStyle(
                  fontSize: 0,
                ),
                onChangeStart: (value) {
                  _startValue = value;
                },
                onChangeEnd: (value) {
                  _endValue = value;
                },
                onChangePlaybackState: (_) {},
              ),
            ),
          ),
          SizedBox(
            height: 64,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go(
                    '${widget.caller}?path=${widget.path}&id=${widget.id}',
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
                GestureDetector(
                  onTap: () {
                    _saveVideo(context);
                    context.go(
                      '${widget.caller}?path=${widget.path}&id=${widget.id}',
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
