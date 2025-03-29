class Constants {
  static const String landing = 'landing';
  static const String login = 'login';
  static const String otpView = 'otpView';
  static const String explore = 'explore';
  static const String userInfo = 'userInfo';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String friends = 'friends';
  static const String friendRequest = 'friendRequest';
  static const String chatView = 'chatView';
  static const String groupView = 'groupView';

  static const String uid = 'uid';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String image = 'image';
  static const String token = 'token';
  static const String aboutMe = 'aboutMe';
  static const String lastSeen = 'lastSeen';
  static const String craetedAt = 'craetedAt';
  static const String isOnline = 'isOnline';
  static const String friendUID = 'friendUID';
  static const String friendRequestUID = 'friendRequestUID';
  static const String sentFriendRequestUID = 'sentFriendRequestUID';

  static const String userModel = 'userModel';
  static const String verifyId = 'verifyId';
  static const String groupId = 'groupId';
  static const String contactName = 'contactName';
  static const String contactImage = 'contactImage';

  static const String senderUId = 'senderUId';
  static const String senderName = 'senderName';
  static const String senderImage = 'senderImage';
  static const String contactUID = 'contactUID';
  static const String message = 'message';
  static const String messageType = 'messageType';
  static const String timeSent = 'timeSent';
  static const String messageId = 'messageId';
  static const String isSeen = 'isSeen';
  static const String repliedMessage = 'repliedMessage';
  static const String repliedTo = 'repliedTo';
  static const String repliedMessageType = 'repliedMessageType';
  static const String isMe = 'isMe';
}

enum ViewFriend { friends, friendRequest, groupView }

enum MessageEnum { text, audio, image, video }

extension MessageEnumExtension on String {
  MessageEnum toMessageEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.text;
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      default:
        return MessageEnum.text;
    }
  }
}
