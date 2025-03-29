// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:chat_message/models/user_model.dart';
import 'package:chat_message/utilities/constants.dart';
import 'package:chat_message/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phone;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phone => _phone;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> authState() async {
    // _isLoading = true;
    // notifyListeners();
    bool isAuth = false;
    await Future.delayed(const Duration(seconds: 1));
    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      await getUserDataFromFireStore();
      await saveUserDataToSharedPreferences();
      isAuth = true;
    } else {
      isAuth = false;
    }
    _isLoading = false; // เสร็จสิ้นการโหลด
    notifyListeners();
    return isAuth;
  }

  Future<void> updateUerOnline({required bool isOnline}) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }

  // check if user exist
  Future<bool> checkUserExist() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(_uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  // get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(_uid).get();
      if (documentSnapshot.exists) {
        _userModel = UserModel.fromMap(
          documentSnapshot.data() as Map<String, dynamic>,
        );
      } else {
        _userModel = null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      _userModel = null;
      if (e.toString().contains('PERMISSION_DENIED')) {
        print('Permission denied: Please check Firestore security rules');
      }
    }
    notifyListeners();
  }

  // save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      Constants.userModel,
      jsonEncode(userModel!.toMap()),
    );
  }

  // get data from shared preferences
  Future<void> getUserDataFromShared() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  // sign in with phon number
  Future<void> signInWithPhoneNumber({
    required String phone,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) async {
            _uid = value.user!.uid;
            _phone = value.user!.phoneNumber;
            _isSuccessful = true;
            notifyListeners();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          showSnackBar(context, e.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          _isLoading = false;
          notifyListeners();
          Navigator.of(context).pushNamed(
            Constants.otpView,
            arguments: {
              Constants.verifyId: verificationId,
              Constants.phone: phone,
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print('Error in signInWithPhoneNumber: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // verify otp code
  Future<void> verifyOtpCode({
    required String otpCode,
    required BuildContext context,
    required String verifyId,
    required Function() onSuccess,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final credential = PhoneAuthProvider.credential(
        verificationId: verifyId,
        smsCode: otpCode,
      );
      await _auth.signInWithCredential(credential).then((value) async {
        _uid = value.user!.uid;
        _phone = value.user!.phoneNumber;
        _isSuccessful = true;
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    }
  }

  // save user data to firestore
  Future<void> saveUserDataToFireStore({
    required UserModel userModel,
    required File? image,
    required Function() onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (image != null) {
        String downloadUrl = await storeFileToStorage(
          file: image,
          reference: 'profileImages/${userModel.uid}.jpg',
        );
        userModel.image = downloadUrl;
      }
      userModel.lastSeen = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.craetedAt = DateTime.now().millisecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap());
      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
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

  // get user stream
  Stream<DocumentSnapshot> userStream({required String uid}) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // get user stream
  Stream<QuerySnapshot> allUserStream({required String userId}) {
    return _firestore
        .collection('users')
        .where(Constants.uid, isNotEqualTo: userId)
        .snapshots();
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    _userModel = null;
    _uid = null;
    _phone = null;
    _isSuccessful = false;
    notifyListeners();
  }

  // send friend request
  Future<void> sendFriendRequest({required String friendId}) async {
    try {
      await _firestore.collection('users').doc(friendId).update({
        Constants.friendRequestUID: FieldValue.arrayUnion([_uid]),
      });
      await _firestore.collection('users').doc(_uid).update({
        Constants.sentFriendRequestUID: FieldValue.arrayUnion([friendId]),
      });
    } on FirebaseException catch (e) {
      print('Error in sendFriendRequest: $e');
    }
  }

  Future<void> cancelFriend({required String friendId}) async {
    try {
      await _firestore.collection('users').doc(friendId).update({
        Constants.friendRequestUID: FieldValue.arrayRemove([_uid]),
      });
      await _firestore.collection('users').doc(_uid).update({
        Constants.sentFriendRequestUID: FieldValue.arrayRemove([friendId]),
      });
    } on FirebaseException catch (e) {
      print('Error in sendFriendRequest: $e');
    }
  }

  Future<void> acceptFriend({required String friendId}) async {
    try {
      await _firestore.collection('users').doc(friendId).update({
        Constants.friendUID: FieldValue.arrayUnion([_uid]),
      });
      await _firestore.collection('users').doc(_uid).update({
        Constants.friendUID: FieldValue.arrayUnion([friendId]),
      });
      await _firestore.collection('users').doc(friendId).update({
        Constants.sentFriendRequestUID: FieldValue.arrayRemove([_uid]),
      });
      await _firestore.collection('users').doc(_uid).update({
        Constants.friendRequestUID: FieldValue.arrayRemove([friendId]),
      });
    } on FirebaseException catch (e) {
      print('Error in acceptFriend: $e');
    }
  }

  Future<void> removeFriend({required String friendId}) async {
    try {
      await _firestore.collection('users').doc(friendId).update({
        Constants.friendUID: FieldValue.arrayRemove([_uid]),
      });
      await _firestore.collection('users').doc(_uid).update({
        Constants.friendUID: FieldValue.arrayRemove([friendId]),
      });
    } on FirebaseException catch (e) {
      print('Error in removeFriend: $e');
    }
  }

  // get a list friends
  Future<List<UserModel>> getFriendList(String uid) async {
    List<UserModel> friendList = [];
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(uid).get();
    List<dynamic> friendUID = documentSnapshot.get(Constants.friendUID) ?? [];

    for (String friendUid in friendUID) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(friendUid).get();
      if (documentSnapshot.exists) {
        UserModel friend = UserModel.fromMap(
          documentSnapshot.data() as Map<String, dynamic>,
        );
        friendList.add(friend);
      }
    }
    return friendList;
  }

  Future<List<UserModel>> getFriendRequestList(String uid) async {
    List<UserModel> friendRequestList = [];
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(uid).get();
    List<dynamic> friendRequestUID =
        documentSnapshot.get(Constants.friendRequestUID) ?? [];

    for (String friendRequestUid in friendRequestUID) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(friendRequestUid).get();
      if (documentSnapshot.exists) {
        UserModel friendRequest = UserModel.fromMap(
          documentSnapshot.data() as Map<String, dynamic>,
        );
        friendRequestList.add(friendRequest);
      }
    }
    return friendRequestList;
  }
}
