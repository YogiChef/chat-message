import 'package:chat_message/models/last_message_model.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/providers/chat_provider.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final isDark = context.watch<ThemeProvider>().isDark;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: CupertinoSearchTextField(),
        ),
        Expanded(
          child: StreamBuilder<List<LastMessageModel>>(
            stream: context.read<ChatProvider>().getChatList(uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                final chats = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final isMe = chat.contactUID == uid;
                    final lastMessage =
                        isMe ? 'You: ${chat.message}' : chat.message;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(chat.contactImage),
                      ),
                      title: Text(
                        chat.contactName,
                        style: styles(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: mainColor,
                        ),
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: messageToShow(
                          message: lastMessage,
                          type: chat.messageType,
                          isDark: isDark,
                        ),
                      ),

                      trailing: Text(
                        DateFormat('HH:mm ').format(chat.timeSent),
                        // dateTime,
                        style: styles(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Constants.chatView,
                          arguments: {
                            Constants.contactUID: chat.contactUID,
                            Constants.contactName: chat.contactName,
                            Constants.contactImage: chat.contactImage,
                            Constants.groupId: '',
                          },
                        );
                      },
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }
}
