// ignore_for_file: avoid_print

import 'dart:io';

import 'package:chat_message/models/last_message_model.dart';
import 'package:chat_message/models/message_model.dart';
import 'package:chat_message/models/message_reply_model.dart';
import 'package:chat_message/models/user_model.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? model) {
    _messageReplyModel = model;
    notifyListeners();
  }

  // firebase initialiration
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // send text message to firestore
  Future<void> sendTextMessage({
    required UserModel? sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupId,
    required Function onSucces,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      var messageId = Uuid().v4();
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo =
          _messageReplyModel == null
              ? ''
              : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum replieMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final messageModel = MessageModel(
        senderUId: sender!.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: replieMessageType,
      );

      if (groupId.isNotEmpty) {
      } else {
        await handleContactMessage(
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          messageModel: messageModel,
          onSucces: onSucces,
          onError: onError,
        );
        setMessageReplyModel(null);
      }
    } catch (e) {
      onError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> sendFileMessage({
    required UserModel? sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType,
    required String groupId,
    required Function() onSucces,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      var messageId = Uuid().v4();
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo =
          _messageReplyModel == null
              ? ''
              : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final ref =
          'chatFiles/${messageType.name}/${sender!.uid}/$contactUID/$messageId';
      String fileUrl = await storeFileToStorage(file: file, reference: ref);

      final messageModel = MessageModel(
        senderUId: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileUrl,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );
      if (groupId.isNotEmpty) {
      } else {
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucces: onSucces,
          onError: onError,
        );
        setMessageReplyModel(null);
      }
    } catch (e) {
      onError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSucces,
    required Function(String p1) onError,
  }) async {
    try {
      final contactMessageModel = messageModel.copywith(
        uid: messageModel.senderUId,
      );

      final senderLastMessage = LastMessageModel(
        senderUId: messageModel.senderUId,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        message: messageModel.message,
        messageType: messageModel.messageType,
        timeSent: messageModel.timeSent,
        isSeen: false,
      );

      final contactLastMessage = senderLastMessage.copywith(
        contactUID: messageModel.senderUId,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      await _firestore
          .collection('users')
          .doc(messageModel.senderUId)
          .collection('chats')
          .doc(contactUID)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());
      await _firestore
          .collection('users')
          .doc(contactUID)
          .collection('chats')
          .doc(messageModel.senderUId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(contactMessageModel.toMap());
      await _firestore
          .collection('users')
          .doc(messageModel.senderUId)
          .collection('chats')
          .doc(contactUID)
          .set(senderLastMessage.toMap());
      await _firestore
          .collection('users')
          .doc(contactUID)
          .collection('chats')
          .doc(messageModel.senderUId)
          .set(contactLastMessage.toMap());

      /*  await _firestore.runTransaction((transaction) async {
        transaction.set(
          _firestore
              .collection('users')
              .doc(messageModel.senderUId)
              .collection('chats')
              .doc(contactUID)
              .collection('messages')
              .doc(messageModel.messageId),
          messageModel.toMap(),
        );
        transaction.set(
          _firestore
              .collection('users')
              .doc(contactUID)
              .collection('chats')
              .doc(messageModel.senderUId)
              .collection('messages')
              .doc(messageModel.messageId),
          contactMessageModel.toMap(),
        );
        transaction.set(
          _firestore
              .collection('users')
              .doc(messageModel.senderUId)
              .collection('chats')
              .doc(contactUID),
          senderLastMessage.toMap(),
        );
        transaction.set(
          _firestore
              .collection('users')
              .doc(contactUID)
              .collection('chats')
              .doc(messageModel.senderUId),
          contactLastMessage.toMap(),
        );
      });*/
      setLoading(false);
      onSucces();
    } on FirebaseException catch (e) {
      setLoading(false);
      onError(e.message ?? '');
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> setMessageAsSeen({
    required String userId,
    required String contactUID,
    required String messageId,
    required String groupId,
  }) async {
    try {
      if (groupId.isNotEmpty) {
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(contactUID)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true});

        await _firestore
            .collection('users')
            .doc(contactUID)
            .collection('chats')
            .doc(userId)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true});

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(contactUID)
            .update({'isSeen': true});

        await _firestore
            .collection('users')
            .doc(contactUID)
            .collection('chats')
            .doc(userId)
            .update({'isSeen': true});
      }
    } catch (e) {
      print('Error in setMessageAsSeen: $e');
    }
  }

  Stream<List<LastMessageModel>> getChatList(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        // .orderBy('timeSent', descending: true)
        .snapshots()
        .map((event) {
          return event.docs
              .map((doc) => LastMessageModel.fromMap(doc.data()))
              .toList();
        });
  }

  Stream<List<MessageModel>> getMessageList({
    required String senderId,
    required String contactUID,
    required String isGroup,
  }) {
    if (isGroup.isNotEmpty) {
      return _firestore
          .collection('groups')
          .doc(contactUID)
          .collection('messages')
          // .orderBy('timeSent', descending: false)
          .snapshots()
          .map((event) {
            return event.docs
                .map((doc) => MessageModel.fromMap(doc.data()))
                .toList();
          });
    } else {
      return _firestore
          .collection('users')
          .doc(senderId)
          .collection('chats')
          .doc(contactUID)
          .collection('messages')
          .orderBy('timeSent', descending: false)
          .snapshots()
          .map((event) {
            return event.docs
                .map((doc) => MessageModel.fromMap(doc.data()))
                .toList();
          });
    }
  }

  // store image to storage and return image url
  Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
