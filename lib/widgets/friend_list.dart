// ignore_for_file: use_build_context_synchronously

import 'package:chat_message/models/user_model.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FriendList extends StatelessWidget {
  final ViewFriend viewFriend;
  const FriendList({super.key, required this.viewFriend});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final future =
        viewFriend == ViewFriend.friends
            ? context.read<AuthProvider>().getFriendList(uid)
            : viewFriend == ViewFriend.friendRequest
            ? context.read<AuthProvider>().getFriendRequestList(uid)
            : context.read<AuthProvider>().getFriendList(uid);
    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: mainColor));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Something went wrong"));
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text("No friends yet"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                leading: userImage(
                  imageUrl: data.image,
                  radius: 40.r,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Constants.profile,
                      arguments: data.uid,
                    );
                  },
                ),
                title: Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).buttonTheme.colorScheme!.primary,
                  ),
                ),
                subtitle: Text(
                  data.aboutMe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styles(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).buttonTheme.colorScheme!.primary,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (viewFriend == ViewFriend.friends) {
                      Navigator.pushNamed(
                        context,
                        Constants.chatView,
                        arguments: {
                          Constants.contactUID: data.uid,
                          Constants.contactName: data.name,
                          Constants.contactImage: data.image,
                          Constants.groupId: '',
                        },
                      );
                    } else if (viewFriend == ViewFriend.friendRequest) {
                      await context
                          .read<AuthProvider>()
                          .acceptFriend(friendId: data.uid)
                          .whenComplete(() {
                            showSnackBar(
                              context,
                              'You are noe friend with ${data.name}',
                            );
                          });
                    } else {}
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    viewFriend == ViewFriend.friends ? 'Chat' : 'Accept',
                    style: styles(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).buttonTheme.colorScheme!.primary,
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Center(child: CircularProgressIndicator(color: mainColor));
      },
    );
  }
}
