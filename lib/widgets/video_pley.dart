import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlyService extends StatefulWidget {
  final String videoUrl;
  final Color color;
  const VideoPlyService({
    super.key,
    required this.videoUrl,
    required this.color,
  });

  @override
  State<VideoPlyService> createState() => _VideoPlyServiceState();
}

class _VideoPlyServiceState extends State<VideoPlyService> {
  late VideoPlayerController videoController;
  bool isPlaying = false;
  bool isLoaded = true;

  @override
  void initState() {
    videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..addListener(() {})
          ..initialize().then((_) {
            videoController.setVolume(1);
          });
    super.initState();
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: videoController.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(videoController),
          Center(
            child: IconButton(
              onPressed: () {
                setState(() {
                  isPlaying = !isPlaying;
                  isPlaying ? videoController.play() : videoController.pause();
                });
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
