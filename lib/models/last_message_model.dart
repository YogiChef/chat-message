import 'package:chat_message/utilities/constants.dart';

class LastMessageModel {
  String senderUId;
  String contactUID;
  String contactName;
  String contactImage;
  String message;
  MessageEnum messageType;
  DateTime timeSent;
  bool isSeen;

  LastMessageModel({
    required this.senderUId,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.message,
    required this.messageType,
    required this.timeSent,
    required this.isSeen,
  });

  //to map
  Map<String, dynamic> toMap() {
    return {
      Constants.senderUId: senderUId,
      Constants.contactUID: contactUID,
      Constants.contactName: contactName,
      Constants.contactImage: contactImage,
      Constants.message: message,
      Constants.messageType: messageType.name,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
      Constants.isSeen: isSeen,
    };
  }

  // from map
  factory LastMessageModel.fromMap(Map<String, dynamic> map) {
    return LastMessageModel(
      senderUId: map[Constants.senderUId] ?? '',
      contactUID: map[Constants.contactUID] ?? '',
      contactName: map[Constants.contactName] ?? '',
      contactImage: map[Constants.contactImage] ?? '',
      message: map[Constants.message] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map[Constants.timeSent]),
      isSeen: map[Constants.isSeen] ?? false,
    );
  }
  copywith({
    required String contactUID,
    required String contactName,
    required String contactImage,
  }) {
    return LastMessageModel(
      senderUId: senderUId,
      contactUID: contactUID,
      contactName: contactName,
      contactImage: contactImage,
      message: message,
      messageType: messageType,
      timeSent: timeSent,
      isSeen: isSeen,
    );
  }
}
