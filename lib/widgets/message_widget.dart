import 'package:chat_message/models/message_model.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/widgets/display_message_type.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

class Mymessage extends StatelessWidget {
  final MessageModel message;
  final Function() onRightSwipe;

  const Mymessage({
    super.key,
    required this.message,
    required this.onRightSwipe,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = formatDate(message.timeSent, [HH, ':', nn]);
    final isReply = message.repliedTo.isNotEmpty;
    final isDark = context.watch<ThemeProvider>().isDark;
    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                message.messageType == MessageEnum.text ||
                        message.messageType == MessageEnum.video
                    ? width * 0.8
                    : message.messageType == MessageEnum.audio
                    ? width * 0.6
                    : width * 0.4,
            minWidth: width * 0.2,
          ),
          child: Container(
            padding:
                message.messageType == MessageEnum.text
                    ? EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 8.h,
                      top: 6.h,
                    )
                    : EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? mainColor : Colors.blue,

              borderRadius:
                  message.messageType == MessageEnum.text
                      ? BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      )
                      : BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding:
                      message.messageType == MessageEnum.text
                          ? EdgeInsets.only(bottom: 24.h)
                          : EdgeInsets.only(bottom: 12.h),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isReply) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              constraints: BoxConstraints(
                                maxWidth: width * 0.4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.repliedTo.substring(
                                      0,
                                      message.repliedTo.length > 7
                                          ? 7
                                          : message.repliedTo.length,
                                    ),
                                    style: styles(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  DisplayMessageType(
                                    message:
                                        '${message.repliedMessage.substring(0, message.repliedMessage.length > 14 ? 14 : message.repliedMessage.length)}...',
                                    type: message.repliedMessageType,
                                    isReply: true,
                                    color: Colors.white,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 10.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          DisplayMessageType(
                            message: message.message,
                            type: message.messageType,
                            isReply: false,
                            color: Colors.white,

                            fontSize: 14.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      message.messageType == MessageEnum.text
                          ? EdgeInsets.zero
                          : EdgeInsets.only(right: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      message.isSeen
                          ? Icon(
                            Icons.done_all,
                            color: Colors.white,
                            size: 18.sp,
                          )
                          : SizedBox.shrink(),
                      6.w.horizontalSpace,
                      Text(
                        dateTime,
                        style: styles(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
