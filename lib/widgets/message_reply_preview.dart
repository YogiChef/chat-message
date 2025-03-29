import 'package:chat_message/models/message_reply_model.dart';
import 'package:chat_message/providers/chat_provider.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({super.key, required this.messageReply});

  final MessageReplyModel? messageReply;

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    return Consumer<ChatProvider>(
      builder: (context, chat, child) {
        final messageReply = chat.messageReplyModel;
        final isMe = messageReply!.isMe;
        final type = messageReply.messageType;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMe ? 'You' : messageReply.senderName.substring(0, 6),

              style: styles(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : Colors.black54,
              ),
            ),
            12.w.horizontalSpace,
            Expanded(
              child: messageToShow(
                message: messageReply.senderImage,
                type: type,
                isDark: isDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                chat.setMessageReplyModel(null);
              },
              child: CircleAvatar(radius: 20.r, child: Icon(Icons.close)),
            ),
          ],
        );
      },
    );
  }
}
