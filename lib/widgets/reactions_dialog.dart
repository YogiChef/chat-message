import 'package:chat_message/models/message_model.dart';
import 'package:chat_message/services/sevice.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReactionsDialog extends StatefulWidget {
  final String uid;
  final MessageModel message;
  final Function(String) onReactionTap;
  final Function(String) onContextMenuTap;

  const ReactionsDialog({
    super.key,
    required this.uid,
    required this.message,
    required this.onReactionTap,
    required this.onContextMenuTap,
  });

  @override
  State<ReactionsDialog> createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  @override
  Widget build(BuildContext context) {
    final isMyMessage = widget.message.senderUId == widget.uid;
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final reaction in reactions)
                            InkWell(
                              onTap: () {
                                widget.onReactionTap(reaction);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 8.h,
                                ),
                                child: Text(
                                  reaction,
                                  style: styles(fontSize: 16.sp),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
