import 'dart:io';

import 'package:flutter/material.dart';
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
  _TrimmerPageState createState() => _TrimmerPageState();
}

class _TrimmerPageState extends State<TrimmerPage> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0;
  double _endValue = 0;
  bool _isPlaying = false;

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
        debugPrint('OUTPUT PATH: $outputPath');
        Directory(widget.path).deleteSync(recursive: true);
        await File(outputPath!).rename(widget.path);
        context.go('${widget.caller}?path=${widget.path}&id=${widget.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: VideoViewer(
                    padding: const EdgeInsets.all(32),
                    borderColor: Colors.blue,
                    trimmer: _trimmer,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final playbackState = await _trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
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
                onChangePlaybackState: (value) {
                  setState(() {
                    _isPlaying = value;
                  });
                },
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    context.go('${widget.caller}?path=${widget.path}'),
                icon: const Icon(Icons.close),
              ),
              const Expanded(child: SizedBox.shrink()),
              IconButton(
                onPressed: () => _saveVideo(context),
                icon: const Icon(Icons.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
