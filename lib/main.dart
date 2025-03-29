import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_message/auth/landing%20_view.dart';
import 'package:chat_message/auth/login_view.dart';
import 'package:chat_message/auth/otp_view.dart';
import 'package:chat_message/auth/user_infomation_view.dart';
import 'package:chat_message/firebase_options.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/providers/chat_provider.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/tabs/explore_tab.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/views/chat_view.dart';
import 'package:chat_message/views/friend_request_view.dart';
import 'package:chat_message/views/friend_view.dart';
import 'package:chat_message/views/profile_view.dart';
import 'package:chat_message/views/setting_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return ScreenUtilInit(
      designSize: const Size(375, 825),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (context, child) => AdaptiveTheme(
            light: ThemeData.light(useMaterial3: true).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white,
                textStyle: const TextStyle(color: Colors.black87),
              ),
            ),

            dark: ThemeData.dark(useMaterial3: true).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.grey[900],
                textStyle: const TextStyle(color: Colors.white),
              ),
            ),
            initial: AdaptiveThemeMode.light,
            builder:
                (theme, darkTheme) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  title: 'Chat Message',
                  darkTheme: darkTheme,
                  initialRoute: Constants.landing,
                  routes: {
                    Constants.landing: (context) => LandingView(),
                    Constants.login: (context) => LogInView(),
                    Constants.otpView: (context) => OtpView(),
                    Constants.explore: (context) => ExploreTab(),
                    Constants.userInfo: (context) => UserInfomationView(),
                    Constants.profile: (context) => ProfileView(),
                    Constants.settings: (context) => SettingView(),
                    Constants.friends: (context) => FriendView(),
                    Constants.friendRequest: (context) => FriendRequestView(),
                    Constants.chatView: (context) => ChatView(),
                  },
                ),
          ),
    );
  }
}
