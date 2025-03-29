import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/widgets/friend_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendRequestView extends StatefulWidget {
  const FriendRequestView({super.key});

  @override
  State<FriendRequestView> createState() => _FriendRequestViewState();
}

class _FriendRequestViewState extends State<FriendRequestView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          'Friend Request',
          style: styles(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: mainColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: CupertinoSearchTextField(),
          ),
          Expanded(child: FriendList(viewFriend: ViewFriend.friendRequest)),
        ],
      ),
    );
  }
}
