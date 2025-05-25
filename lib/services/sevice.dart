import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

String userDropOffAdress = '';
String cloudMessagingServerToken = ''; //Todo

double height = 825.h;
double width = 375.w;

Color mainColor = const Color.fromARGB(255, 17, 170, 197);
Color mainTag = Color(0xffeee302);

styles({
  double? letterSpacing,
  double? fontSize,
  double? height,
  FontWeight? fontWeight = FontWeight.w400,
  Color? color,
}) {
  return GoogleFonts.roboto(
    height: height,
    letterSpacing: letterSpacing,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? Colors.black,
  );
}

textstyles({
  double? letterSpacing,
  double? fontSize,
  double? height,
  FontWeight? fontWeight = FontWeight.w400,
  Color? color = Colors.black87,
}) {
  return TextStyle(
    height: height,
    letterSpacing: letterSpacing,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

void callVendor(String phone) async {
  final String url = 'tel:$phone';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw ('Could not launch phone call');
  }
}

extension AppContext on BuildContext {
  Future push(Widget widget) async {
    return Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  void pop() async {
    return Navigator.pop(this);
  }
}

extension ContextExtension on BuildContext {
  showSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
