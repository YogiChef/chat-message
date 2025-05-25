// ignore_for_file: avoid_print
import 'dart:io';

import 'package:chat_message/providers/auth_provider.dart';
import 'package:chat_message/providers/chat_provider.dart';
import 'package:chat_message/providers/theme_provider.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  final String contactUID;
  final String contactName;
  final String contactImage;
  final String groupId;

  const BottomChatField({
    super.key,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.groupId,
  });

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  FlutterSoundRecord? _soundRecorder;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _selectedMenuItem = '';
  final List<String> _menuItems = ['Camera', 'Gallery', 'Video'];
  File? imageFile;
  String filePath = '';
  bool isRecording = false;
  bool isShowSand = false;
  bool isAudioSending = false;

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _soundRecorder = FlutterSoundRecord();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _soundRecorder!.dispose();
    super.dispose();
  }

  // check microphone permission
  Future<bool> checkMicrophonePermission() async {
    bool hasPermission = await Permission.microphone.isGranted;
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      hasPermission = true;
    } else {
      hasPermission = false;
    }
    return hasPermission;
  }

  // record audio
  Future<void> recordAudio() async {
    final hasPermission = await checkMicrophonePermission();
    if (hasPermission) {
      var tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/audio.aac';
      await _soundRecorder!.start(path: filePath);
      setState(() {
        isRecording = true;
      });
    }
  }

  // stop audio
  Future<void> stopAudio() async {
    await _soundRecorder!.stop();
    setState(() {
      isRecording = false;
      isAudioSending = true;
    });
    sendFileMessage(messageType: MessageEnum.audio);
  }

  void sendMessage() {
    final currentUser = context.read<AuthProvider>().userModel;
    final chatProvider = context.read<ChatProvider>();

    if (_controller.text.isNotEmpty) {
      chatProvider.sendTextMessage(
        sender: currentUser,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        message: _controller.text,
        messageType: MessageEnum.text,
        groupId: widget.groupId,
        onSucces: () {
          _controller.clear();
          _focusNode.unfocus();
          chatProvider.setMessageReplyModel(null);
        },
        onError: (e) {
          showSnackBar(context, e.toString());
        },
      );
    } else {
      showSnackBar(context, 'Please type a message');
    }
  }

  void sendFileMessage({required MessageEnum messageType}) {
    final currentUser = context.read<AuthProvider>().userModel;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendFileMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      file: File(filePath),
      messageType: messageType,
      groupId: widget.groupId,
      onSucces: () {
        _controller.clear();
        filePath.isEmpty;
        _focusNode.unfocus();
        setState(() {
          isAudioSending = false;
        });
      },
      onError: (e) {
        setState(() {
          isAudioSending = false;
        });
        showSnackBar(context, e.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    return Consumer<ChatProvider>(
      builder: (context, chat, child) {
        final messageReply = chat.messageReplyModel;
        final isMessageReply = messageReply != null;

        return Container(
          padding: const EdgeInsets.all(12),

          color: Colors.green.withAlpha(100),

          child: Row(
            children: [
              Expanded(
                child:
                    isMessageReply
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  messageReply.senderName,
                                  style: styles(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    chat.setMessageReplyModel(null);
                                    _controller.clear();
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 24.r,
                                    color:
                                        isDark ? Colors.grey : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            messageToShow(
                              message: messageReply.message,
                              type: messageReply.messageType,
                              isDark: isDark,
                            ),
                            12.h.verticalSpace,

                            TextFormField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: styles(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                setState(() {
                                  isShowSand = value.isNotEmpty;
                                });
                              },

                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),

                                contentPadding: EdgeInsets.only(right: 12.w),

                                hintText: 'Type a message',
                                hintStyle: styles(
                                  color: isDark ? Colors.grey : Colors.black38,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: PopupMenuButton<String>(
                                  initialValue: _selectedMenuItem,
                                  onSelected: (String item) {
                                    _selectedMenuItem = item;
                                  },
                                  itemBuilder:
                                      (BuildContext context) =>
                                          _menuItems.map((String item) {
                                            return PopupMenuItem<String>(
                                              value: item,

                                              child: Container(
                                                color:
                                                    isDark
                                                        ? Colors.grey[900]
                                                        : Colors.white,
                                                child: Row(
                                                  children: [
                                                    20.w.horizontalSpace,
                                                    Icon(
                                                      item == 'Camera'
                                                          ? Icons.camera_alt
                                                          : item == 'Gallery'
                                                          ? Icons.image
                                                          : item == 'Video'
                                                          ? Icons.videocam
                                                          : Icons.camera_alt,

                                                      size: 24.r,
                                                    ),
                                                    20.w.horizontalSpace,
                                                    Text(
                                                      item,
                                                      style: TextStyle(
                                                        color:
                                                            isDark
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                if (item == 'Camera') {
                                                  selectImage(true);
                                                } else if (item == 'Gallery') {
                                                  selectImage(false);
                                                } else {
                                                  item == 'Video';
                                                  selectVideo();
                                                }
                                              },
                                            );
                                          }).toList(),
                                  child: Icon(
                                    Icons.attachment,
                                    size: 30.r,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap:
                                      isShowSand
                                          ? sendMessage
                                          : (isRecording
                                              ? stopAudio
                                              : recordAudio),

                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: SizedBox(
                                      width: 40.r,
                                      height: 40.r,

                                      child: CircleAvatar(
                                        backgroundColor:
                                            isRecording
                                                ? Colors.green
                                                : Theme.of(
                                                  context,
                                                ).primaryColor,
                                        radius: 12.r,
                                        child:
                                            isShowSand
                                                ? const Icon(
                                                  Icons.arrow_upward,
                                                  size: 20,
                                                  color: Colors.white,
                                                )
                                                : Icon(
                                                  Icons.mic,
                                                  size: 20.r,
                                                  color: Colors.white,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                  minWidth: 40.w,
                                  minHeight: 40.h,
                                ),

                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        )
                        : TextFormField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: styles(color: Colors.black54, fontSize: 16),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,

                          onChanged: (value) {
                            setState(() {
                              isShowSand = value.isNotEmpty;
                            });
                          },

                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),

                            contentPadding: EdgeInsets.zero,

                            hintText: 'Type a message',
                            hintStyle: styles(
                              color: isDark ? Colors.grey : Colors.black38,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: PopupMenuButton<String>(
                              initialValue: _selectedMenuItem,
                              onSelected: (String item) {
                                _selectedMenuItem = item;
                              },
                              itemBuilder:
                                  (BuildContext context) =>
                                      _menuItems.map((String item) {
                                        return PopupMenuItem<String>(
                                          value: item,
                                          child: Container(
                                            color:
                                                isDark
                                                    ? Colors.grey[900]
                                                    : Colors.white,
                                            child: Row(
                                              children: [
                                                20.w.horizontalSpace,

                                                Icon(
                                                  item == 'Camera'
                                                      ? Icons.camera_alt
                                                      : item == 'Gallery'
                                                      ? Icons.image
                                                      : item == 'Video'
                                                      ? Icons.videocam
                                                      : Icons.camera_alt,

                                                  size: 24.r,
                                                ),
                                                20.w.horizontalSpace,
                                                Text(
                                                  item,
                                                  style: TextStyle(
                                                    color:
                                                        isDark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            if (item == 'Camera') {
                                              selectImage(true);
                                            } else if (item == 'Gallery') {
                                              selectImage(false);
                                            } else {
                                              item == 'Video';
                                              selectVideo();
                                            }
                                          },
                                        );
                                      }).toList(),
                              child: Icon(
                                Icons.attachment,
                                size: 30.r,
                                color: Colors.black,
                              ),
                            ),
                            suffixIcon: GestureDetector(
                              onTap:
                                  isShowSand
                                      ? sendMessage
                                      : (isRecording ? stopAudio : recordAudio),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: SizedBox(
                                  width: 40.r,
                                  height: 40.r,

                                  child: CircleAvatar(
                                    backgroundColor:
                                        isRecording
                                            ? Colors.green
                                            : Theme.of(context).primaryColor,
                                    radius: 12.r,
                                    child:
                                        isShowSand
                                            ? const Icon(
                                              Icons.arrow_upward,
                                              size: 20,
                                              color: Colors.white,
                                            )
                                            : isRecording
                                            ? Icon(
                                              Icons.stop,
                                              size: 20.r,
                                              color: Colors.white,
                                            )
                                            : Icon(
                                              Icons.mic,
                                              size: 20.r,
                                              color: Colors.white,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 40.w,
                              minHeight: 40.h,
                            ),

                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void selectVideo() async {
    File? videoFile = await pickVideo(
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    if (videoFile != null) {
      filePath = videoFile.path;
      sendFileMessage(messageType: MessageEnum.video);
    }
  }

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

  Future<void> cropImage(String? cropfilePath) async {
    if (cropfilePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: cropfilePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        filePath = croppedFile.path;
        sendFileMessage(messageType: MessageEnum.image);
      }
    }
  }

  popDialog() {
    Navigator.pop(context);
  }
}
