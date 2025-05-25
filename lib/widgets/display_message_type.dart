import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/widgets/audio_player.dart';
import 'package:chat_message/widgets/video_pley.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisplayMessageType extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final Color color;
  final bool isReply;
  final int? maxLines;
  final TextOverflow? overflow;
  final double fontSize;

  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
    required this.color,
    required this.isReply,
    this.maxLines,
    this.overflow,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget messageToShow() {
      switch (type) {
        case MessageEnum.text:
          return Text(
            message,
            style: styles(color: color, fontSize: 14.sp),
            maxLines: maxLines,
            overflow: overflow,
          );
        case MessageEnum.image:
          return isReply
              ? Icon(Icons.image)
              : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(imageUrl: message, fit: BoxFit.cover),
              );
        case MessageEnum.video:
          return isReply
              ? Icon(Icons.video_collection)
              : VideoPlyService(videoUrl: message, color: color);
        case MessageEnum.audio:
          return isReply
              ? Icon(Icons.audiotrack)
              : AudioPlayered(audioUrl: message, color: color);
        default:
          return Text(
            message,
            style: styles(color: color, fontSize: 14.sp),
            maxLines: maxLines,
            overflow: overflow,
          );
      }
    }

    return messageToShow();
  }
}
