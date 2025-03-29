import 'package:chat_message/utilities/constants.dart';

class UserModel {
  String uid;
  String name;
  String phone;
  String image;
  String token;
  String aboutMe;
  String lastSeen;
  String craetedAt;
  bool isOnline;

  List<String> friendUID;
  List<String> friendRequestUID;
  List<String> sentFriendRequestUID;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.image,
    required this.token,
    required this.aboutMe,
    required this.lastSeen,
    required this.craetedAt,
    required this.isOnline,
    required this.friendUID,
    required this.friendRequestUID,
    required this.sentFriendRequestUID,
  });
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[Constants.uid] ?? '',
      name: map[Constants.name] ?? '',
      phone: map[Constants.phone] ?? '',
      image: map[Constants.image] ?? '',
      token: map[Constants.token] ?? '',
      aboutMe: map[Constants.aboutMe] ?? '',
      lastSeen: map[Constants.lastSeen] ?? '',
      craetedAt: map[Constants.craetedAt] ?? '',
      isOnline: map[Constants.isOnline] ?? false,
      friendUID: List<String>.from(map[Constants.friendUID] ?? []),
      friendRequestUID: List<String>.from(
        map[Constants.friendRequestUID] ?? [],
      ),
      sentFriendRequestUID: List<String>.from(
        map[Constants.sentFriendRequestUID] ?? [],
      ),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.phone: phone,
      Constants.image: image,
      Constants.token: token,
      Constants.aboutMe: aboutMe,
      Constants.lastSeen: lastSeen,
      Constants.craetedAt: craetedAt,
      Constants.isOnline: isOnline,
      Constants.friendUID: friendUID,
      Constants.friendRequestUID: friendRequestUID,
      Constants.sentFriendRequestUID: sentFriendRequestUID,
    };
  }
}
