import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  void initState() {
    authState();
    super.initState();
  }

  void authState() async {
    final authProvider = context.read<AuthProvider>();
    bool isAuth = await authProvider.authState();
    if (isAuth) {
      await authProvider.getUserDataFromFireStore();
      await authProvider.saveUserDataToSharedPreferences();
      navigate(isAuth: isAuth);
    } else {
      navigate(isAuth: isAuth);
    }
  }

  navigate({required bool isAuth}) async {
    if (isAuth) {
      Navigator.of(context).pushReplacementNamed(Constants.explore);
    } else {
      Navigator.of(context).pushReplacementNamed(Constants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            120.h.verticalSpace,
            SizedBox(child: Lottie.asset('lottie/chat.json')),

            SizedBox(
              width: 200,
              child: const LinearProgressIndicator(minHeight: 15),
            ),
          ],
        ),
      ),
    );
  }
}
