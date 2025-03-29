import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/widgets/bottom_chat_field.dart';
import 'package:chat_message/widgets/chat_app_bar.dart';
import 'package:chat_message/widgets/chat_list_group.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final contactUID = arguments[Constants.contactUID];
    final contactName = arguments[Constants.contactName];
    final contactImage = arguments[Constants.contactImage];
    final groupId = arguments[Constants.groupId];
    // final isGroup = groupId.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(),
        title: ChatAppBar(contactUID: contactUID),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatListGroup(contactUID: contactUID, groupId: groupId),
          ),
          BottomChatField(
            contactUID: contactUID,
            contactName: contactName,
            contactImage: contactImage,
            groupId: groupId,
          ),
        ],
      ),
    );
  }
}
