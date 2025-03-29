import 'package:chat_message/models/user_model.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/*class GroupChatAppBar extends StatefulWidget {
  final String groupId;
  const GroupChatAppBar({super.key, required this.groupId});

  @override
  State<GroupChatAppBar> createState() => _GroupChatAppBarState();
}

class _GroupChatAppBarState extends State<GroupChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthProvider>().userStream(uid: widget.groupId),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading"));
        }

        final groupModel = GroupModel.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
        );
        return AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              userImage(imageUrl: groupModel.image, radius: 24.r, onTap: () {}),
              10.w.horizontalSpace,
              Column(
                children: [
                  Text(groupModel.name),
                  Text(
                    'Online',
                    style: styles(fontSize: 12.sp, color: Colors.green),
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
*/
