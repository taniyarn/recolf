import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recolf/util.dart';
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
  late final Trimmer _trimmer;
  late String videoPath;

  double _startValue = 0;
  double _endValue = 0;

  @override
  void initState() {
    super.initState();
    _trimmer = Trimmer();
    videoPath = widget.path;
    _loadVideo();
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: File(widget.path));
  }

  Future<void> saveVideo(BuildContext context) async {
    const videoFolderName = 'video';

    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      videoFileName: generateVideoName(),
      videoFolderName: videoFolderName,
      storageDir: StorageDir.applicationDocumentsDirectory,
      onSave: (outputPath) {
        videoPath = outputPath!;
        debugPrint(outputPath);

        if (mounted) {
          context.go(
            '${widget.caller}?path=$videoPath&id=${widget.id}',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: <Widget>[
          Expanded(
            child: _VideoView(
              trimmer: _trimmer,
              startValue: _startValue,
              endValue: _endValue,
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
                  setState(() {
                    _startValue = value;
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    _endValue = value;
                  });
                },
                onChangePlaybackState: (_) {},
              ),
            ),
          ),
          _BottomActions(
            onCancel: () => context.go(
              '${widget.caller}?path=$videoPath&id=${widget.id}',
            ),
            onSave: () {
              saveVideo(context);
            },
          ),
        ],
      ),
    );
  }
}

class _VideoView extends StatelessWidget {
  const _VideoView({
    Key? key,
    required Trimmer trimmer,
    required double startValue,
    required double endValue,
  })  : _trimmer = trimmer,
        _startValue = startValue,
        _endValue = endValue,
        super(key: key);

  final Trimmer _trimmer;
  final double _startValue;
  final double _endValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({Key? key, this.onCancel, this.onSave})
      : super(key: key);
  final void Function()? onCancel;
  final void Function()? onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
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
            onTap: onSave,
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
    );
  }
}
