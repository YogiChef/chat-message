import 'dart:io';

import 'package:chat_message/services/sevice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisplayUserImage extends StatelessWidget {
  final File? imageFile;
  final Function() onPressed;
  final double radius;
  const DisplayUserImage({
    super.key,
    this.imageFile,
    required this.onPressed,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        imageFile != null
            ? CircleAvatar(
              radius: 70.r,
              backgroundColor: Colors.grey[200],

              backgroundImage: FileImage(File(imageFile!.path)),
            )
            : CircleAvatar(
              radius: 70.r,
              backgroundColor: Colors.grey[200],

              backgroundImage: AssetImage('images/profile.png'),
            ),

        imageFile == null
            ? GestureDetector(
              onTap: onPressed,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: mainColor,

                child: Icon(Icons.camera_alt, size: 30.r, color: Colors.white),
              ),
            )
            : CircleAvatar(
              radius: radius,
              backgroundColor: Colors.red,

              child: Icon(Icons.edit, size: 30.r, color: Colors.white),
            ),
      ],
    );
  }
}
