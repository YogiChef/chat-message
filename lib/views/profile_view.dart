// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:chat_message/models/user_model.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.userModel;
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    if (authProvider == null || currentUser == null) {
      return Scaffold(body: Center(child: Text('ไม่มีข้อมูลผู้ใช้')));
    }

    if (uid == null) {
      return Scaffold(body: Center(child: Text('ไม่พบรหัสผู้ใช้')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          currentUser.name,
          style: styles(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: mainColor,
          ),
        ),
        actions: [
          currentUser.uid == uid
              ? IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Constants.settings,
                    arguments: uid,
                  );
                },
                icon: Icon(Icons.settings, color: mainColor),
              )
              : const SizedBox(),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: context.read<AuthProvider>().userStream(uid: uid),
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

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text("No user data available"));
          }

          final userModel = UserModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 20.h),
            child: Column(
              children: [
                Center(
                  child: userImage(
                    imageUrl: userModel.image,
                    radius: 60.r,
                    onTap: () {},
                  ),
                ),
                20.h.verticalSpace,
                Text(
                  userModel.phone,
                  textAlign: TextAlign.center,
                  style: styles(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).buttonTheme.colorScheme!.primary,
                  ),
                ),
                10.h.verticalSpace,
                ...[
                  buildFriendsRequest(
                    currentUid: currentUser,
                    userModel: userModel,
                  ),
                  10.h.verticalSpace,
                  buildFriendButton(
                    currentUid: currentUser,
                    userModel: userModel,
                  ),
                ],
                20.h.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40.w,
                      child: Divider(color: Colors.indigo, thickness: 1.5),
                    ),

                    Text(
                      ' About Me ',
                      style: styles(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).buttonTheme.colorScheme!.primary,
                      ),
                    ),
                    SizedBox(
                      width: 40.w,
                      child: Divider(
                        color:
                            Theme.of(context).buttonTheme.colorScheme!.primary,
                        thickness: 1.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  userModel.aboutMe,
                  textAlign: TextAlign.center,
                  style: styles(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).buttonTheme.colorScheme!.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildFriendsRequest({
    required UserModel currentUid,
    required UserModel userModel,
  }) {
    if (currentUid.uid == userModel.uid &&
        userModel.friendRequestUID.isNotEmpty) {
      return elevateButton(
        onPressed: () {
          Navigator.pushNamed(context, Constants.friendRequest);
        },
        label: 'Requests',
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // friend button
  Widget buildFriendButton({
    required UserModel currentUid,
    required UserModel userModel,
  }) {
    if (currentUid.uid == userModel.uid && userModel.friendUID.isNotEmpty) {
      return elevateButton(
        onPressed: () {
          Navigator.pushNamed(context, Constants.friends);
        },
        label: 'View',
      );
    } else {
      if (currentUid.uid != userModel.uid) {
        if (userModel.friendRequestUID.contains(currentUid.uid)) {
          return elevateButton(
            onPressed: () async {
              await context
                  .read<AuthProvider>()
                  .cancelFriend(friendId: userModel.uid)
                  .whenComplete(() {
                    showSnackBar(context, 'Friend Request Cancelled');
                  });
            },
            label: 'Cancel',
            color: Colors.amber,
          );
        } else if (userModel.sentFriendRequestUID.contains(currentUid.uid)) {
          return elevateButton(
            onPressed: () async {
              await context
                  .read<AuthProvider>()
                  .acceptFriend(friendId: userModel.uid)
                  .whenComplete(() {
                    showSnackBar(
                      context,
                      'You are already friend with ${userModel.name}',
                    );
                  });
            },
            label: 'Accept',
            color: mainColor,
          );
        } else if (userModel.friendUID.contains(currentUid.uid)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              elevateButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(
                            'Unfriend',
                            textAlign: TextAlign.center,
                            style: styles(
                              fontSize: 20.sp,
                              color:
                                  Theme.of(
                                    context,
                                  ).buttonTheme.colorScheme!.primary,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to Unfriend ${userModel.name}?.',
                            style: styles(
                              fontSize: 13.sp,
                              color:
                                  Theme.of(
                                    context,
                                  ).buttonTheme.colorScheme!.primary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: styles(
                                  fontSize: 13.sp,
                                  color:
                                      Theme.of(
                                        context,
                                      ).buttonTheme.colorScheme!.primary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await context
                                    .read<AuthProvider>()
                                    .removeFriend(friendId: userModel.uid)
                                    .whenComplete(() {
                                      showSnackBar(context, 'Friend Removed');
                                    });
                              },
                              child: Text(
                                'Unfriend',
                                style: styles(
                                  fontSize: 13.sp,
                                  color:
                                      Theme.of(
                                        context,
                                      ).buttonTheme.colorScheme!.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                label: 'Unfriend',
                color: Colors.red,
                width: 130.w,
              ),
              elevateButton(
                onPressed: () async {
                  Navigator.pushNamed(
                    context,
                    Constants.chatView,
                    arguments: {
                      Constants.contactUID: userModel.uid,
                      Constants.contactName: userModel.name,
                      Constants.contactImage: userModel.image,
                      Constants.groupId: '',
                    },
                  );
                },
                label: 'Chat',
                color: Colors.green,
                width: 120.w,
              ),
            ],
          );
        } else {
          return elevateButton(
            onPressed: () async {
              await context
                  .read<AuthProvider>()
                  .sendFriendRequest(friendId: userModel.uid)
                  .whenComplete(() {
                    showSnackBar(context, 'Friend Request Sent');
                  });
            },

            label: 'Add Friend',
            color: Colors.indigo,
          );
        }
      } else {
        return SizedBox.shrink();
      }
    }
  }

  Widget elevateButton({
    required VoidCallback onPressed,
    required String label,
    double? width,
    Color? color,
  }) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width / 2.0,
      height: 35.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: styles(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
