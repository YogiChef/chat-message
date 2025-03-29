// ignore_for_file: unnecessary_null_comparison

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/tabs/people_tab.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/tabs/chat_tab.dart';
import 'package:chat_message/tabs/goups_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final pageController = PageController();
  int index = 0;

  final List<Widget> page = [ChatTab(), GroupTab(), PeoPleTap()];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        context.read<AuthProvider>().updateUerOnline(isOnline: true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        context.read<AuthProvider>().updateUerOnline(isOnline: false);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final authProvided = context.watch<AuthProvider>();

    if (authProvided == null || authProvided.userModel == null) {
      return Scaffold(body: Center(child: Text('User data not available')));
    }

    final userModel = authProvided.userModel!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userModel.name,
          style: styles(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: mainColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Constants.profile,
                arguments: userModel.uid,
              );
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userModel.image),
            ),
          ),
          20.w.horizontalSpace,
        ],
        centerTitle: true,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            index = index;
          });
        },
        children: page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              index == 0 ? IconlyBold.chat : IconlyLight.chat,
              size: 30,
            ),
            label: 'Chat',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              index == 1 ? IconlyBold.user3 : IconlyLight.user3,
              size: 30,
            ),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              index == 2 ? CupertinoIcons.globe : CupertinoIcons.globe,

              size: 30,
            ),
            label: 'People',
          ),
        ],

        currentIndex: index,
        onTap: (value) {
          pageController.animateToPage(
            value,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
          setState(() {
            index = value;
          });
        },
      ),
    );
  }
}
