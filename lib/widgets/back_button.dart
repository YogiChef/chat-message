import 'dart:io';
import 'package:chat_message/services/sevice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BackButton extends StatelessWidget {
  final Function()? onPressed;
  const BackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,

      icon: Icon(
        Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new,
        size: 30.r,
        color: mainColor,
      ),
    );
  }
}
