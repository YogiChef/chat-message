import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PeoPleTap extends StatefulWidget {
  const PeoPleTap({super.key});

  @override
  State<PeoPleTap> createState() => _PeoPleTapState();
}

class _PeoPleTapState extends State<PeoPleTap> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().userModel;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: CupertinoSearchTextField(),
            ),
            // list of people
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: context.read<AuthProvider>().allUserStream(
                  userId: currentUser!.uid,
                ),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text("Loading"));
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No user found",
                        textAlign: TextAlign.center,
                        style: styles(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return ListTile(
                            leading: userImage(
                              imageUrl: data[Constants.image],
                              radius: 40.r,
                              onTap: () {},
                            ),
                            title: Text(
                              data[Constants.name],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: styles(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).buttonTheme.colorScheme!.primary,
                              ),
                            ),
                            subtitle: Text(
                              data[Constants.aboutMe],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: styles(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(
                                      context,
                                    ).buttonTheme.colorScheme!.secondary,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Constants.profile,
                                arguments: data[Constants.uid],
                              );
                            },
                          );
                        }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
