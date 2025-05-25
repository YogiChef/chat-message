// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioPlayered extends StatefulWidget {
  final String audioUrl;
  final Color color;

  const AudioPlayered({super.key, required this.audioUrl, required this.color});

  @override
  State<AudioPlayered> createState() => _AudioPlayeredState();
}

class _AudioPlayeredState extends State<AudioPlayered> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = Duration();
  Duration position = Duration();
  bool isPlaying = false;
  DateTime? lastSeek;

  @override
  void initState() {
    initAudio();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = true;
        });
      } else if (state == PlayerState.paused) {
        setState(() {
          isPlaying = false;
        });
      } else if (state == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          position = Duration();
        });
      }
    });
    audioPlayer.onPositionChanged.listen((newposition) {
      setState(() {
        position = newposition;
      });
    });
    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        duration = duration;
      });
    });
    super.initState();
  }

  Future<void> initAudio() async {
    try {
      await audioPlayer
          .setSource(UrlSource(widget.audioUrl))
          .timeout(Duration(seconds: 10));
    } catch (e) {
      print('Error loading audio: $e');
      showSnackBar(context, 'ไม่สามารถโหลดไฟล์เสียงได้');
    }
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void seekToPosition(double seconds) async {
    if (lastSeek != null &&
        DateTime.now().difference(lastSeek!).inMilliseconds < 500) {
      return;
    }
    lastSeek = DateTime.now();
    final newPosition = Duration(seconds: seconds.toInt());
    try {
      await audioPlayer.seek(newPosition).timeout(Duration(seconds: 10));

      if (isPlaying) {
        await audioPlayer.resume();
      }
    } catch (e) {
      print('Error seeking to position: $e');
      showSnackBar(context, 'ไม่สามารถเลื่อนตำแหน่งได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    double sliderValue = position.inSeconds.toDouble().clamp(
      0.0,
      duration.inSeconds.toDouble(),
    );
    double sliderMax =
        duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0;
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              if (!isPlaying) {
                await audioPlayer.play(UrlSource(widget.audioUrl));
              } else {
                await audioPlayer.pause();
              }
            },
            icon: CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              radius: 22.r,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.r,
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: Slider.adaptive(
              value: sliderValue,
              min: 0,
              max: sliderMax,
              onChanged: seekToPosition,
            ),
          ),
          Text(
            formatTime(duration - position),
            style: styles(color: widget.color, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
