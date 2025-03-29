import 'package:chat_message/models/message_model.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:chat_message/widgets/display_message_type.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

class ContactMessage extends StatelessWidget {
  final MessageModel message;
  final Function() onRightSwipe;

  const ContactMessage({
    super.key,
    required this.message,
    required this.onRightSwipe,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = formatDate(message.timeSent, [HH, ':', nn]);
    final isReply = message.repliedTo.isNotEmpty;
    final isDark = context.read<ThemeProvider>().isDark;
    final sendName =
        message.repliedTo == message.senderName
            ? message.senderName
            : message.repliedTo;

    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: userImage(
                imageUrl: message.senderImage,
                radius: 20.r,
                onTap: () {},
              ),
            ),
            6.w.horizontalSpace,
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      message.messageType == MessageEnum.text ||
                              message.messageType == MessageEnum.video
                          ? width * 0.7
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
                            bottom: 4.h,
                            top: 6.h,
                          )
                          : EdgeInsets.only(
                            left: 12.w,
                            right: 12.w,
                            bottom: 12.h,
                          ),

                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.grey[300],
                    borderRadius:
                        message.messageType == MessageEnum.text
                            ? BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )
                            : BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isReply) ...[
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black38,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DisplayMessageType(
                                        message: sendName.substring(
                                          0,
                                          sendName.length > 7
                                              ? 7
                                              : sendName.length,
                                        ),
                                        type: message.messageType,
                                        color: Colors.black,
                                        fontSize: 10.sp,
                                      ),

                                      DisplayMessageType(
                                        message:
                                            '${message.repliedMessage.substring(0, message.repliedMessage.length > 14 ? 14 : message.repliedMessage.length)}...',
                                        type: message.messageType,
                                        color: Colors.black,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 11.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          DisplayMessageType(
                            message: message.message,
                            type: message.messageType,
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),

                          Text(
                            dateTime,
                            style: styles(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
