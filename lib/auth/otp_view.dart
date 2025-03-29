// ignore_for_file: use_build_context_synchronously

import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final pinput = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    pinput.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verifyId = args[Constants.verifyId] as String;
    final phone = args[Constants.phone] as String;
    final isDark = context.watch<ThemeProvider>().isDark;

    final authProvider = context.watch<AuthProvider>();
    final defaultPinTheme = PinTheme(
      width: 56.h,
      height: 60.h,
      textStyle: GoogleFonts.openSans(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? mainColor : Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  50.h.verticalSpace,
                  Text(
                    'Verification',
                    style: GoogleFonts.openSans(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  40.h.verticalSpace,
                  Text(
                    'Enter the OTP code sent to your number',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  20.h.verticalSpace,
                  Text(
                    phone,
                    style: GoogleFonts.openSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  30.h.verticalSpace,
                  SizedBox(
                    height: 56.h,
                    child: Pinput(
                      length: 6,
                      controller: pinput,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      onCompleted: (pin) {
                        setState(() {
                          otpCode = pin;
                        });
                        verifyOtpCode(otpCode: otpCode!, verifyId: verifyId);
                      },
                      focusedPinTheme: defaultPinTheme.copyWith(
                        height: 56.h,
                        width: 60.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyWith(
                        height: 56.h,
                        width: 60.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                    ),
                  ),
                  20.h.verticalSpace,
                  authProvider.isLoading
                      ? CircularProgressIndicator(color: mainColor)
                      : SizedBox.shrink(),
                  authProvider.isSuccessful
                      ? Container(
                        height: 50.h,
                        width: 50.h,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30.r,
                        ),
                      )
                      : Text(
                        'Invalid OTP code',
                        style: GoogleFonts.openSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.red,
                        ),
                      ),
                  authProvider.isSuccessful
                      ? SizedBox.shrink()
                      : Text(
                        'Didn\'t receive the code?',
                        style: GoogleFonts.openSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  10.h.verticalSpace,
                  authProvider.isSuccessful
                      ? SizedBox.shrink()
                      : TextButton(
                        onPressed: () {},
                        child: Text(
                          'Resend code',
                          style: GoogleFonts.openSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: mainColor,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ), // Add OTP screen UI here
    );
  }

  void verifyOtpCode({
    required String otpCode,
    required String verifyId,
  }) async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.verifyOtpCode(
        otpCode: otpCode,
        verifyId: verifyId,
        context: context,
        onSuccess: () async {
          bool userExist = await authProvider.checkUserExist();
          if (userExist) {
            await authProvider.getUserDataFromFireStore();
            await authProvider.saveUserDataToSharedPreferences();
            navigate(userExist: true);
          } else {
            navigate(userExist: false);
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  navigate({required bool userExist}) {
    if (userExist) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.explore,
        (predicate) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.userInfo,
        (predicate) => false,
      );
    }
  }
}
