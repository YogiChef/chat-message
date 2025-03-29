import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final _phoneController = TextEditingController();

  Country country = Country(
    phoneCode: '+66',
    countryCode: 'TH',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Thailand',
    example: 'Thailand',
    displayName: 'Thailand',
    displayNameNoCountryCode: 'Thailand',
    e164Key: '',
  );
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              30.verticalSpace,
              Center(
                child: SizedBox(
                  height: height * 0.3,
                  width: height * 0.7,
                  child: Lottie.asset('lottie/chat.json'),
                ),
              ),
              Text(
                'Chat Pro',
                style: styles(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                  color: mainColor,
                ),
              ),
              Text(
                'Add your phone number will send you a code to verify',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 60, 69, 31),
                ),
              ),
              40.verticalSpace,
              TextFormField(
                maxLength: 10,
                controller: _phoneController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    _phoneController.text = value;
                  });
                },
                onFieldSubmitted: (value) {
                  setState(() {
                    _phoneController.text = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: GoogleFonts.openSans(
                    color: mainColor,
                    fontSize: 16.sp,
                  ),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(8.r),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            backgroundColor: Colors.white,
                            bottomSheetHeight: 500.h,
                            flagSize: 20.sp,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                            textStyle: GoogleFonts.openSans(
                              fontSize: 16.sp,
                              color: mainColor,
                            ),
                          ),
                          onSelect: (Country onSelect) {
                            setState(() {
                              country = onSelect;
                            });
                          },
                        );
                      },
                      child: Text(
                        '${country.flagEmoji} ${country.phoneCode}',
                        style: styles(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  suffixIcon:
                      _phoneController.text.length > 9
                          ? authProvider.isLoading
                              ? CircularProgressIndicator(
                                color: mainColor,
                                padding: EdgeInsets.all(12),
                              )
                              : InkWell(
                                onTap: () async {
                                  await authProvider.signInWithPhoneNumber(
                                    phone:
                                        '${country.phoneCode}${_phoneController.text}',
                                    context: context,
                                  );
                                },
                                child: Container(
                                  height: 20.h,
                                  width: 20.w,
                                  margin: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.done,
                                    size: 24.r,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
