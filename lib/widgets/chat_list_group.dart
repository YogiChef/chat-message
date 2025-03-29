import 'package:chat_message/models/message_model.dart';
import 'package:chat_message/models/message_reply_model.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/providers/chat_provider.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:chat_message/widgets/contact_message.dart';
import 'package:chat_message/widgets/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatListGroup extends StatefulWidget {
  final String contactUID;
  final String groupId;
  const ChatListGroup({
    super.key,
    required this.contactUID,
    required this.groupId,
  });

  @override
  State<ChatListGroup> createState() => _ChatListGroupState();
}

class _ChatListGroupState extends State<ChatListGroup> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final isDark = context.read<ThemeProvider>().isDark;

    return StreamBuilder<List<MessageModel>>(
      stream: context.read<ChatProvider>().getMessageList(
        senderId: uid,
        contactUID: widget.contactUID,
        isGroup: widget.groupId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Start a conversation',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            curve: Curves.easeOut,
            duration: Duration(milliseconds: 200),
          );
        });

        if (snapshot.hasData) {
          final messages = snapshot.data!;
          return GroupedListView<dynamic, DateTime>(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            elements: messages,
            controller: _scrollController,
            // reverse: true,
            groupBy: (element) {
              return DateTime(
                element.timeSent.year,
                element.timeSent.month,
                element.timeSent.day,
              );
            },
            groupHeaderBuilder:
                (dynamic groupByValue) => builDateTime(groupByValue, isDark),
            itemBuilder: (context, dynamic element) {
              final isMe = element.senderUId == uid;
              if (!element.isSeen && element.senderUId != uid) {
                context.read<ChatProvider>().setMessageAsSeen(
                  userId: uid,
                  contactUID: widget.contactUID,
                  messageId: element.messageId,
                  groupId: widget.groupId,
                );
              }
              return isMe
                  ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    child: Mymessage(
                      message: element,
                      onRightSwipe: () {
                        final reply = MessageReplyModel(
                          message: element.message,
                          senderUId: element.senderUId,
                          senderName: element.senderName,
                          senderImage: element.senderImage,
                          messageType: element.messageType,
                          isMe: isMe,
                        );
                        context.read<ChatProvider>().setMessageReplyModel(
                          reply,
                        );
                      },
                    ),
                  )
                  : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: ContactMessage(
                      message: element,
                      onRightSwipe: () {
                        final reply = MessageReplyModel(
                          message: element.message,
                          senderUId: element.senderUId,
                          senderName: element.senderName,
                          senderImage: element.senderImage,
                          messageType: element.messageType,
                          isMe: isMe,
                        );
                        context.read<ChatProvider>().setMessageReplyModel(
                          reply,
                        );
                      },
                    ),
                  );
            },
            // itemComparator: (item1, item2) {
            //   var firstItem = item1.timeSent;
            //   var secondItem = item2.timeSent;
            //   return secondItem.compareTo(firstItem);
            // }, // optional
            useStickyGroupSeparators: true, // optional
            floatingHeader: true, // optional
            order: GroupedListOrder.ASC, // optional
          );
        }
        return Container();
      },
    );
  }
}
