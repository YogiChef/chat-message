// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  // void getThemeMode() async {
  //   final saveThemeMode = await AdaptiveTheme.getThemeMode();
  //   if (saveThemeMode == AdaptiveThemeMode.dark) {
  //     setState(() {
  //       isDark = true;
  //     });
  //   } else {
  //     setState(() {
  //       isDark = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.userModel;
    final darkTheme = context.watch<ThemeProvider>();
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    if (currentUser == null || uid == null) {
      return Scaffold(
        body: Center(child: Text('ไม่มีข้อมูลผู้ใช้หรือรหัสผู้ใช้')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          'Settings',
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
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(
                            'Sign Out',
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
                            'Are you sure you want to sign out of your account?',
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
                                  color: mainColor,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await authProvider.signOut();
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Constants.landing,
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                icon: CircleAvatar(
                  radius: 24.r,
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
              )
              : const SizedBox(),
        ],
        centerTitle: true,
      ),

      body: Center(
        child: Card(
          child: SwitchListTile(
            secondary: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: darkTheme.isDark ? Colors.white : Colors.black,
              ),
              child: Icon(
                darkTheme.isDark ? Icons.dark_mode : Icons.light_mode,
                color: darkTheme.isDark ? Colors.black : Colors.white,
              ),
            ),
            title: Text(darkTheme.isDark ? 'Dark Mode' : 'Light Mode'),
            value: darkTheme.isDark,
            onChanged: (value) {
              darkTheme.toggleTheme(value, context);
            },
          ),
        ),
      ),
    );
  }
}
