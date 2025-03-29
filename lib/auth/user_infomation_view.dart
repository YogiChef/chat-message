import 'dart:io';

import 'package:chat_message/models/user_model.dart';
import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/widgets/display_user_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class UserInfomationView extends StatefulWidget {
  const UserInfomationView({super.key});

  @override
  State<UserInfomationView> createState() => _UserInfomationViewState();
}

class _UserInfomationViewState extends State<UserInfomationView> {
  final _nameController = TextEditingController();
  String userImage = '';
  File? imageFile;
  bool isLoading = false;

  selectImage(bool camera) async {
    imageFile = await pickImages(
      camera: camera,
      onFail: (e) {
        showSnackBar(context, e);
      },
    );
    if (imageFile != null) {
      // ตรวจสอบ null ก่อน
      await cropImage(
        imageFile!.path,
      ); // ใช้ ! ได้อย่างปลอดภัย เพราะตรวจสอบแล้ว
    }
  }

  Future<void> cropImage(String? filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          imageFile = File(croppedFile.path);
        });
      }
      popDialog();
    }
  }

  popDialog() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'User Infomation',
          style: styles(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: mainColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              30.verticalSpace,
              DisplayUserImage(
                onPressed: () {
                  showBottomShet();
                },
                radius: 24.r,
                imageFile: imageFile,
              ),
              50.verticalSpace,
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: styles(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              50.verticalSpace,
              isLoading
                  ? CircularProgressIndicator(color: mainColor)
                  : ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.isEmpty ||
                          imageFile == null ||
                          _nameController.text.length < 3) {
                        showSnackBar(context, 'Please fill in all fields');
                      } else {
                        showSnackBar(context, 'Success');
                        await Future.delayed(Duration(seconds: 2));
                        saveUserDataToFireStore();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      minimumSize: Size(double.infinity, 40.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: styles(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  showBottomShet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SizedBox(
            height: height / 3,
            child: Column(
              children: [
                20.h.verticalSpace,
                ListTile(
                  onTap: () {
                    selectImage(true);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    selectImage(false);
                  },
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                ),
              ],
            ),
          ),
    );
  }

  saveUserDataToFireStore() async {
    setState(() {
      isLoading = true;
    });
    final authProvider = context.read<AuthProvider>();
    UserModel userModel = UserModel(
      name: _nameController.text.trim(),
      phone: authProvider.phone!,
      uid: authProvider.uid!,
      image: '',
      token: '', // ต้องเพิ่ม token ด้วย
      aboutMe: 'Hey there! I am using Chat Message App',
      lastSeen: '',
      craetedAt: '',
      isOnline: true,
      friendUID: [],
      friendRequestUID: [],
      sentFriendRequestUID: [],
    );

    await authProvider.saveUserDataToFireStore(
      userModel: userModel,
      image: imageFile,
      onSuccess: () async {
        showSnackBar(context, 'User data saved successfully');
        await Future.delayed(Duration(seconds: 2));
        navigateToHome();
      },
      onFail: () async {
        showSnackBar(context, 'Failed to save user data');
        await Future.delayed(Duration(seconds: 2));
      },
    );
  }

  navigateToHome() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Constants.explore, (route) => false);
  }
}
