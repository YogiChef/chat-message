import 'package:chat_message/utilities/constants.dart';

class MessageReplyModel {
  final String message;
  final String senderUId;
  final String senderName;
  final String senderImage;
  final MessageEnum messageType;
  final bool isMe;

  MessageReplyModel({
    required this.message,
    required this.senderUId,
    required this.senderName,
    required this.senderImage,
    required this.messageType,
    required this.isMe,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.message: message,
      Constants.senderUId: senderUId,
      Constants.senderName: senderName,
      Constants.senderImage: senderImage,
      Constants.messageType: messageType.name,
      Constants.isMe: isMe,
    };
  }

  // from map
  factory MessageReplyModel.fromMap(Map<String, dynamic> map) {
    return MessageReplyModel(
      message: map[Constants.message] ?? '',
      senderUId: map[Constants.senderUId] ?? '',
      senderName: map[Constants.senderName] ?? '',
      senderImage: map[Constants.senderImage] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      isMe: map[Constants.isMe] ?? false,
    );
  }
}
