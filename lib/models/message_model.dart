// ignore_for_file: equal_keys_in_map

import 'package:chat_message/utilities/constants.dart';

class MessageModel {
  final String senderUId;
  final String senderName;
  final String senderImage;
  final String contactUID;
  final String message;
  final MessageEnum messageType;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  MessageModel({
    required this.senderUId,
    required this.senderName,
    required this.senderImage,
    required this.contactUID,
    required this.message,
    required this.messageType,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
  });
  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.senderUId: senderUId,
      Constants.senderName: senderName,
      Constants.senderImage: senderImage,
      Constants.contactUID: contactUID,
      Constants.message: message,
      Constants.messageType: messageType.name,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
      Constants.messageId: messageId,
      Constants.isSeen: isSeen,
      Constants.repliedMessage: repliedMessage,
      Constants.repliedTo: repliedTo,
      Constants.repliedMessageType: repliedMessageType.name,
    };
  }

  // from map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderUId: map[Constants.senderUId] ?? '',
      senderName: map[Constants.senderName] ?? '',
      senderImage: map[Constants.senderImage] ?? '',
      contactUID: map[Constants.contactUID] ?? '',
      message: map[Constants.message] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map[Constants.timeSent]),
      messageId: map[Constants.messageId] ?? '',
      isSeen: map[Constants.isSeen] ?? false,
      repliedMessage: map[Constants.repliedMessage] ?? '',
      repliedTo: map[Constants.repliedTo] ?? '',
      repliedMessageType:
          map[Constants.repliedMessageType].toString().toMessageEnum(),
    );
  }
  copywith({required String uid}) {
    return MessageModel(
      senderUId: senderUId,
      senderName: senderName,
      senderImage: senderImage,
      contactUID: uid,
      message: message,
      messageType: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: isSeen,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
    );
  }
}
