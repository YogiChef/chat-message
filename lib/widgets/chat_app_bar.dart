import 'package:chat_message/models/user_model.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatAppBar extends StatefulWidget {
  final String contactUID;
  const ChatAppBar({super.key, required this.contactUID});

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthProvider>().userStream(uid: widget.contactUID),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(
              "Loading..",
              style: styles(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: mainColor,
              ),
            ),
          );
        }

        final userModel = UserModel.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
        );

        DateTime lastSeen = DateTime.fromMillisecondsSinceEpoch(
          int.parse(userModel.lastSeen),
        );

        return AppBar(
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              userImage(
                imageUrl: userModel.image,
                radius: 24.r,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Constants.profile,
                    arguments: userModel.uid,
                  );
                },
              ),
              10.w.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userModel.name,
                    style: styles(
                      fontSize: 16.sp,
                      color: mainColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    userModel.isOnline ? 'Online' : timeago.format(lastSeen),
                    textAlign: TextAlign.start,
                    style: styles(
                      fontSize: 12.sp,
                      color: userModel.isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
