// show snack bar
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Widget userImage({
  required String imageUrl,
  required double radius,
  required Function() onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage:
          imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : AssetImage('images/profile.webp') as ImageProvider,
    ),
  );
}

// pick image gallery or camera
Future<File?> pickImages({
  required bool camera,
  required Function(String) onFail,
}) async {
  if (camera) {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        onFail('No image selected');
        return null;
      } else {
        return File(image.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  } else {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        onFail('No image selected');
        return null;
      } else {
        return File(image.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  }
  return null;
}

Future<File?> pickVideo({required Function(String) onFail}) async {
  File? filevideo;
  try {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video == null) {
      onFail('No video selected');
      return null;
    } else {
      filevideo = File(video.path);
    }
  } catch (e) {
    onFail(e.toString());
  }
  return filevideo;
}

Padding builDateTime(groupByValue, bool isDark) {
  return Padding(
    padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h),
    child: Text(
      formatDate(groupByValue.timeSent, [d, ' ', M, ' ', yy]),
      textAlign: TextAlign.center,
      style: styles(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark ? Colors.grey : Colors.black45,
      ),
    ),
  );
}

Widget messageToShow({
  required String message,
  required MessageEnum type,
  required bool isDark,
}) {
  switch (type) {
    case MessageEnum.text:
      return Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: styles(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black,
        ),
      );
    case MessageEnum.image:
      return CachedNetworkImage(
        imageUrl: message,
        width: 40.w,
        height: 30.h,
        fit: BoxFit.fitWidth,
      );
    case MessageEnum.video:
      return Icon(Icons.video_library_outlined);
    case MessageEnum.audio:
      return CircleAvatar(
        radius: 16.r,
        backgroundColor: Colors.amber[300],
        child: CircleAvatar(
          radius: 14.r,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.play_arrow, color: Colors.pink, size: 20.r),
        ),
      );
  }
}
