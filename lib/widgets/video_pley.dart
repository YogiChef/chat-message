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
    videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    initVideo();
    super.initState();
  }

  Future<void> initVideo() async {
    try {
      await videoController.initialize().timeout(Duration(seconds: 10));
      setState(() {});
      videoController.setVolume(1);
    } catch (e) {
      print('Error initializing video: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถโหลดวิดีโอได้: $e')));
    }
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoController.value.isInitialized
        ? AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(videoController),
              Center(
                child: IconButton(
                  onPressed: () {
                    if (!videoController.value.isInitialized) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('วิดีโอยังโหลดไม่เสร็จ')),
                      );
                      return;
                    }
                    setState(() {
                      isPlaying = !isPlaying;
                      isPlaying
                          ? videoController.play()
                          : videoController.pause();
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
        )
        : Center(child: CircularProgressIndicator(color: widget.color));
  }
}
