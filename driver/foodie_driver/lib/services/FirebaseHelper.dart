// ignore_for_file: close_sinks, cancel_subscriptions

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:foodie_driver/model/FlutterWaveSettingDataModel.dart';
import 'package:foodie_driver/model/MercadoPagoSettingsModel.dart';
import 'package:foodie_driver/model/PayFastSettingData.dart';
import 'package:foodie_driver/model/PayStackSettingsModel.dart';
import 'package:foodie_driver/model/conversation_model.dart';
import 'package:foodie_driver/model/email_template_model.dart';
import 'package:foodie_driver/model/inbox_model.dart';
import 'package:foodie_driver/model/notification_model.dart';
import 'package:foodie_driver/model/paypalSettingData.dart';
import 'package:foodie_driver/model/paytmSettingData.dart';
import 'package:foodie_driver/model/razorpayKeyModel.dart';
import 'package:foodie_driver/model/referral_model.dart';
import 'package:foodie_driver/model/stripeSettingData.dart';
import 'package:foodie_driver/model/topupTranHistory.dart';
import 'package:foodie_driver/userPrefrence.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/BlockUserModel.dart';
import 'package:foodie_driver/model/ChatVideoContainer.dart';
import 'package:foodie_driver/model/CurrencyModel.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/model/VendorModel.dart';
import 'package:foodie_driver/model/withdrawHistoryModel.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/ui/reauthScreen/reauth_user_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FireStoreUtils {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Reference storage = FirebaseStorage.instance.ref();
  List<BlockUserModel> blockedList = [];

  static Future addDriverInbox(InboxModel inboxModel) async {
    return await firestore.collection("chat_driver").doc(inboxModel.orderId).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addDriverChat(ConversationModel conversationModel) async {
    return await firestore.collection("chat_driver").doc(conversationModel.orderId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson()).then((document) {
      return conversationModel;
    });
  }

  late StreamController<User> driverStreamController;
  late StreamSubscription driverStreamSub;

  Stream<User> getDriver(String userId) async* {
    driverStreamController = StreamController();
    driverStreamSub = firestore.collection(USERS).doc(userId).snapshots().listen((onData) async {
      if (onData.data() != null) {
        User? user = User.fromJson(onData.data()!);
        driverStreamController.sink.add(user);
      }
    });
    yield* driverStreamController.stream;
  }

  static Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      // print('milaa');

      return User.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currencyModel;
    await firestore.collection(Currency).where("isActive", isEqualTo: true).get().then((value) {
      if (value.docs.isNotEmpty) {
        currencyModel = CurrencyModel.fromJson(value.docs.first.data());
      }
    });
    return currencyModel;
  }

  static Future<User?> updateCurrentUser(User user) async {
    return await firestore.collection(USERS).doc(user.userID).set(user.toJson()).then((document) {
      return user;
    });
  }

  getContactUs() async {
    Map<String, dynamic> contactData = {};
    await firestore.collection(Setting).doc(CONTACT_US).get().then((value) {
      contactData = value.data()!;
    });
    return contactData;
  }

  static Future createPaymentId({collectionName = "wallet"}) async {
    DocumentReference documentReference = firestore.collection(collectionName).doc();
    final paymentId = documentReference.id;
    UserPreference.setPaymentId(paymentId: paymentId);
    return paymentId;
  }

  static Future withdrawWalletAmount({required WithdrawHistoryModel withdrawHistory}) async {
    print("this is te payment id");
    print(withdrawHistory.id);
    print(MyAppState.currentUser!.userID);
    await firestore.collection(driverPayouts).doc(withdrawHistory.id).set(withdrawHistory.toJson()).then((value) {
      firestore.collection(driverPayouts).doc(withdrawHistory.id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print(documentData.data());
      });
    });
    return "updated Amount";
  }

  static Future updateWalletAmount({required String userId, required amount}) async {
    dynamic walletAmount = 0;
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;
      if (userDocument.data() != null && userDocument.exists) {
        try {
          print(userDocument.data());
          await firestore.collection(USERS).doc(userId).update({"wallet_amount": userDocument.data()!['wallet_amount'] + amount}).then((value) => print("north"));

          DocumentSnapshot<Map<String, dynamic>> newUserDocument = await firestore.collection(USERS).doc(userId).get();
          MyAppState.currentUser = User.fromJson(newUserDocument.data()!);
          print(MyAppState.currentUser);
        } catch (error) {
          print(error);
          if (error.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
          } else {
            print("went wrong!!");
            walletAmount = "ERROR";
          }
        }
        print("data val");
        print(walletAmount);
        return walletAmount; //User.fromJson(userDocument.data()!);
      } else {
        return 0.111;
      }
    });
  }

  static sendTopUpMail({required String amount, required String paymentMethod, required String tractionId}) async {
    EmailTemplateModel? emailTemplateModel = await FireStoreUtils.getEmailTemplates(walletTopup);

    String newString = emailTemplateModel!.message.toString();
    newString = newString.replaceAll("{username}", MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName);
    newString = newString.replaceAll("{date}", DateFormat('yyyy-MM-dd').format(Timestamp.now().toDate()));
    newString = newString.replaceAll("{amount}", amountShow(amount: amount));
    newString = newString.replaceAll("{paymentmethod}", paymentMethod.toString());
    newString = newString.replaceAll("{transactionid}", tractionId.toString());
    newString = newString.replaceAll("{newwalletbalance}.", amountShow(amount: MyAppState.currentUser!.walletAmount.toString()));
    await sendMail(subject: emailTemplateModel.subject, isAdmin: emailTemplateModel.isSendToAdmin, body: newString, recipients: [MyAppState.currentUser!.email]);
  }

  static sendPayoutMail({required String amount, required String payoutrequestid}) async {
    EmailTemplateModel? emailTemplateModel = await FireStoreUtils.getEmailTemplates(payoutRequest);

    String body = emailTemplateModel!.subject.toString();
    body = body.replaceAll("{userid}", MyAppState.currentUser!.userID);

    String newString = emailTemplateModel.message.toString();
    newString = newString.replaceAll("{username}", MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName);
    newString = newString.replaceAll("{userid}", MyAppState.currentUser!.userID);
    newString = newString.replaceAll("{amount}", amountShow(amount: amount));
    newString = newString.replaceAll("{payoutrequestid}", payoutrequestid.toString());
    newString = newString.replaceAll("{usercontactinfo}", "${MyAppState.currentUser!.email}\n${MyAppState.currentUser!.phoneNumber}");
    await sendMail(subject: body, isAdmin: emailTemplateModel.isSendToAdmin, body: newString, recipients: [MyAppState.currentUser!.email]);
  }

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    EmailTemplateModel? emailTemplateModel;
    await firestore.collection(emailTemplates).where('type', isEqualTo: type).get().then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());
        emailTemplateModel = EmailTemplateModel.fromJson(value.docs.first.data());
      }
    });
    return emailTemplateModel;
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await firestore.collection(VENDORS).doc(vendor.id).set(vendor.toJson()).then((document) {
      return vendor;
    });
  }

  static Future<VendorModel?> getVendor(String vid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(VENDORS).doc(vid).get();
    if (userDocument.data() != null && userDocument.exists) {
      print("dataaaaaa");
      return VendorModel.fromJson(userDocument.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  static Future<String> uploadUserImageToFireStorage(File image, String userID) async {
    Reference upload = storage.child('images/$userID.png');
    File compressedImage = await FireStoreUtils.compressImage(image);

    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<String> uploadCarImageToFireStorage(File image, String userID) async {
    Reference upload = storage.child('uberEats/drivers/carImages/$userID.png');
    File compressedCarImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedCarImage);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<Url> uploadChatImageToFireStorage(File image, BuildContext context) async {
    showProgress(context, 'Uploading image...'.tr(), false);
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('images/$uniqueID.png');
    File compressedImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer> uploadChatVideoToFireStorage(File video, BuildContext context) async {
    showProgress(context, 'Uploading video...'.tr(), false);
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('videos/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(video: downloadUrl, thumbnailPath: (await getTemporaryDirectory()).path, imageFormat: ImageFormat.PNG);
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    hideProgress();
    return ChatVideoContainer(videoUrl: Url(url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'), thumbnailUrl: thumbnailDownloadUrl);
  }

  Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('thumbnails/$uniqueID.png');
    File compressedImage = await compressImage(file);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Stream<User> getUserByID(String id) async* {
    StreamController<User> userStreamController = StreamController();
    firestore.collection(USERS).doc(id).snapshots().listen((user) {
      try {
        User userModel = User.fromJson(user.data() ?? {});
        userStreamController.sink.add(userModel);
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* userStreamController.stream;
  }

  Future<bool> blockUser(User blockedUser, String type) async {
    bool isSuccessful = false;
    BlockUserModel blockUserModel = BlockUserModel(type: type, source: MyAppState.currentUser!.userID, dest: blockedUser.userID, createdAt: Timestamp.now());
    await firestore.collection(REPORTS).add(blockUserModel.toJson()).then((onValue) {
      isSuccessful = true;
    });
    return isSuccessful;
  }

  Stream<bool> getBlocks() async* {
    StreamController<bool> refreshStreamController = StreamController();
    firestore.collection(REPORTS).where('source', isEqualTo: MyAppState.currentUser!.userID).snapshots().listen((onData) {
      List<BlockUserModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> block in onData.docs) {
        list.add(BlockUserModel.fromJson(block.data() ?? {}));
      }
      blockedList = list;
      refreshStreamController.sink.add(true);
    });
    yield* refreshStreamController.stream;
  }

  bool validateIfUserBlocked(String userID) {
    for (BlockUserModel blockedUser in blockedList) {
      if (userID == blockedUser.dest) {
        return true;
      }
    }
    return false;
  }

  Future<Url> uploadAudioFile(File file, BuildContext context) async {
    showProgress(context, 'Uploading Audio...', false);
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('audio/$uniqueID.mp3');
    SettableMetadata metadata = SettableMetadata(contentType: 'audio');
    UploadTask uploadTask = upload.putFile(file, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading Audio ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'audio', url: downloadUrl.toString());
  }

  Future<List<OrderModel>> getDriverOrders(String userID) async {
    List<OrderModel> orders = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore.collection(ORDERS).where('driverID', isEqualTo: userID).orderBy('createdAt', descending: true).get();
    await Future.forEach(ordersQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(OrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserObject(String userID) async* {
    yield* firestore.collection(USERS).doc(userID).snapshots();
  }

  static Future updateOrder(OrderModel orderModel) async {
    await firestore.collection(ORDERS).doc(orderModel.id).set(orderModel.toJson(), SetOptions(merge: true));
  }

  static Future<bool> getFirestOrderOrNOt(OrderModel orderModel) async {
    bool isFirst = true;
    await firestore.collection(ORDERS).where('authorID', isEqualTo: orderModel.authorID).get().then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateReferralAmount(OrderModel orderModel) async {
    ReferralModel? referralModel;
    print(orderModel.authorID);
    await firestore.collection(REFERRAL).doc(orderModel.authorID).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null && referralModel!.referralBy!.isNotEmpty) {
        await firestore.collection(USERS).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              print(userDocument.data());
              User user = User.fromJson(userDocument.data()!);
              await firestore.collection(USERS).doc(user.userID).update({"wallet_amount": user.walletAmount + double.parse(referralAmount.toString())}).then((value) => print("north"));

              await FireStoreUtils.createPaymentId().then((value) async {
                final paymentID = value;
                await FireStoreUtils.topUpWalletAmountRefral(
                    paymentMethod: "Referral Amount",
                    amount: double.parse(referralAmount.toString()),
                    id: paymentID,
                    userId: referralModel!.referralBy,
                    note: "You referral user has complete his this order #${orderModel.id}");
              });
            } catch (error) {
              print(error);
              if (error.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform") {
                print("does not exist");
                //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
                //walletAmount = 0;
              } else {
                print("went wrong!!");
              }
            }
            print("data val");
          }
        });
      } else {
        return;
      }
    }
  }

  late StreamController<OrderModel> ordersStreamController;
  late StreamSubscription ordersStreamSub;

  Stream<OrderModel?> getOrderByID(String inProgressOrderID) async* {
    ordersStreamController = StreamController();
    ordersStreamSub = firestore.collection(ORDERS).doc(inProgressOrderID).snapshots().listen((onData) async {
      if (onData.data() != null) {
        OrderModel? orderModel = OrderModel.fromJson(onData.data()!);
        ordersStreamController.sink.add(orderModel);
      }
    });
    yield* ordersStreamController.stream;
  }

  /// compress image file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the image after
  /// being compressed(100 = max quality - 0 = low quality)
  /// @param file the image file that will be compressed
  /// @return File a new compressed file with smaller size
  static Future<File> compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(file.path, quality: 25, targetWidth: 600, targetHeight: 300);
    return compressedImage;
  }

  /// compress video file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the video after
  /// being compressed
  /// @param file the video file that will be compressed
  /// @return File a new compressed file with smaller size
  Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path, quality: VideoQuality.DefaultQuality, deleteOrigin: false, includeAudio: true, frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static loginWithFacebook() async {
    /// creates a user for this facebook login when this user first time login
    /// and save the new user object to firebase and firebase auth
    FacebookAuth facebookAuth = FacebookAuth.instance;
    bool isLogged = await facebookAuth.accessToken != null;
    if (!isLogged) {
      LoginResult result = await facebookAuth.login(); // by default we request the email and the public profile
      if (result.status == LoginStatus.success) {
        // you are logged
        AccessToken? token = await facebookAuth.accessToken;
        return await handleFacebookLogin(await facebookAuth.getUserData(), token!);
      }
    } else {
      AccessToken? token = await facebookAuth.accessToken;
      return await handleFacebookLogin(await facebookAuth.getUserData(), token!);
    }
  }

  static handleFacebookLogin(Map<String, dynamic> userData, AccessToken token) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(auth.FacebookAuthProvider.credential(token.token));
    print(authResult.user!.uid);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    List<String> fullName = (userData['name'] as String).split(' ');
    String firstName = '';
    String lastName = '';
    if (fullName.isNotEmpty) {
      firstName = fullName.first;
      lastName = fullName.skip(1).join(' ');
    }
    if (user != null && user.role == USER_ROLE_DRIVER) {
      print('if');
      user.profilePictureURL = userData['picture']['data']['url'];
      user.firstName = firstName;
      user.lastName = lastName;
      user.email = userData['email'];
      user.isActive = false;
      user.role = USER_ROLE_DRIVER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else if (user == null) {
      print('else');
      user = User(
          email: userData['email'] ?? '',
          firstName: firstName,
          profilePictureURL: userData['picture']['data']['url'] ?? '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: lastName,
          isActive: false,
          active: true,
          role: USER_ROLE_DRIVER,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          carName: 'Uber Car',
          carNumber: 'No Plates',
          carPictureURL: DEFAULT_CAR_IMAGE,
          createdAt: Timestamp.now(),
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  static loginWithApple() async {
    final appleCredential = await apple.TheAppleSignIn.performRequests([
      apple.AppleIdRequest(requestedScopes: [apple.Scope.email, apple.Scope.fullName])
    ]);
    if (appleCredential.error != null) {
      return 'Couldn\'t login with apple.';
    }

    if (appleCredential.status == apple.AuthorizationStatus.authorized) {
      final auth.AuthCredential credential = auth.OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(appleCredential.credential?.authorizationCode ?? []),
        idToken: String.fromCharCodes(appleCredential.credential?.identityToken ?? []),
      );
      return await handleAppleLogin(credential, appleCredential.credential!);
    } else {
      return 'Couldn\'t login with apple.';
    }
  }

  static handleAppleLogin(
    auth.AuthCredential credential,
    apple.AppleIdCredential appleIdCredential,
  ) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(credential);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    if (user != null) {
      user.isActive = false;
      user.role = USER_ROLE_DRIVER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else {
      user = User(
          email: appleIdCredential.email ?? '',
          firstName: appleIdCredential.fullName?.givenName ?? '',
          profilePictureURL: '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: appleIdCredential.fullName?.familyName ?? '',
          role: USER_ROLE_DRIVER,
          isActive: false,
          active: true,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          carName: 'Uber Car',
          carNumber: 'No Plates',
          carPictureURL: DEFAULT_CAR_IMAGE,
          createdAt: Timestamp.now(),
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  /// save a new user document in the USERS table in firebase firestore
  /// returns an error message on failure or null on success
  static Future<String?> firebaseCreateNewUser(User user) async {
    try {
      await firestore.collection(USERS).doc(user.userID).set(user.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return "notSignIn".tr();
    }
    return null;
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  static Future<dynamic> loginWithEmailAndPassword(String email, String password) async {
    try {
      print('FireStoreUtils.loginWithEmailAndPassword');
      auth.UserCredential result = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firestore.collection(USERS).doc(result.user?.uid ?? '').get();
      User? user;
      if (documentSnapshot.exists) {
        user = User.fromJson(documentSnapshot.data() ?? {});
        user.fcmToken = await firebaseMessaging.getToken() ?? '';
        user.role = USER_ROLE_DRIVER;
        user.isActive = false;
      }
      return user;
    } on auth.FirebaseAuthException catch (exception, s) {
      print(exception.toString() + '$s');
      switch ((exception).code) {
        case 'invalid-email':
          return 'Email address is malformed.';
        case 'wrong-password':
          return 'Wrong password.';
        case 'user-not-found':
          return 'No user corresponding to the given email address.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts to sign in as this user.';
      }
      return 'Unexpected firebase error, Please try again.';
    } catch (e, s) {
      print(e.toString() + '$s');
      return 'Login failed, Please try again.';
    }
  }

  ///submit a phone number to firebase to receive a code verification, will
  ///be used later to login
  static firebaseSubmitPhoneNumber(
    String phoneNumber,
    auth.PhoneCodeAutoRetrievalTimeout? phoneCodeAutoRetrievalTimeout,
    auth.PhoneCodeSent? phoneCodeSent,
    auth.PhoneVerificationFailed? phoneVerificationFailed,
    auth.PhoneVerificationCompleted? phoneVerificationCompleted,
  ) {
    auth.FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(minutes: 2),
      phoneNumber: phoneNumber,
      verificationCompleted: phoneVerificationCompleted!,
      verificationFailed: phoneVerificationFailed!,
      codeSent: phoneCodeSent!,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout!,
    );
  }

  /// submit the received code to firebase to complete the phone number
  /// verification process
  static Future<dynamic> firebaseSubmitPhoneNumberCode(String verificationID, String code, String phoneNumber,
      {String firstName = 'Anonymous', String lastName = 'User', File? image, File? carImage, String carName = '', String carPlates = ''}) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(verificationId: verificationID, smsCode: code);
    auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null && user.role == USER_ROLE_DRIVER) {
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      user.role = USER_ROLE_DRIVER;
      user.isActive = false;
      await updateCurrentUser(user);
      return user;
    } else if (user == null) {
      /// create a new user from phone login
      String profileImageUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      if (image != null) {
        profileImageUrl = await uploadUserImageToFireStorage(image, userCredential.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl = await uploadCarImageToFireStorage(carImage, userCredential.user?.uid ?? '');
      }
      User user = User(
        firstName: firstName,
        lastName: lastName,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        phoneNumber: phoneNumber,
        profilePictureURL: profileImageUrl,
        userID: userCredential.user?.uid ?? '',
        isActive: false,
        active: true,
        lastOnlineTimestamp: Timestamp.now(),
        settings: UserSettings(),
        email: '',
        role: USER_ROLE_DRIVER,
        carName: carName,
        carNumber: carPlates,
        carPictureURL: carPicUrl,
        createdAt: Timestamp.now(),
      );
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t create new user with phone number.';
      }
    }
  }

  static firebaseSignUpWithEmailAndPassword(
      String emailAddress, String password, File? image, File? carImage, String carName, String carPlate, String firstName, String lastName, String mobile) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailAddress, password: password);
      String profilePicUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      if (image != null) {
        updateProgress('Uploading image, Please wait...'.tr());
        profilePicUrl = await uploadUserImageToFireStorage(image, result.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl = await uploadCarImageToFireStorage(carImage, result.user?.uid ?? '');
      }

      User user = User(
        email: emailAddress,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        phoneNumber: mobile,
        firstName: firstName,
        userID: result.user?.uid ?? '',
        lastName: lastName,
        active: true,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        carNumber: carPlate,
        carName: carName,
        role: USER_ROLE_DRIVER,
        createdAt: Timestamp.now(),
      );
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t sign up for firebase, Please try again.';
      }
    } on auth.FirebaseAuthException catch (error) {
      print(error.toString() + '${error.stackTrace}');
      String message = "notSignIn".tr();
      switch (error.code) {
        case 'email-already-in-use':
          message = "EmailAlreadyUseAnother".tr();
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail'.tr();
          break;
        case 'operation-not-allowed':
          message = "EmailPasswordAccountsNotEnabled".tr();
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters'.tr();
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.'.tr();
          break;
      }
      return message;
    } catch (e) {
      return "notSignIn".tr();
    }
  }

  static Future<auth.UserCredential?> reAuthUser(AuthProviders provider,
      {String? email, String? password, String? smsCode, String? verificationId, AccessToken? accessToken, apple.AuthorizationResult? appleCredential}) async {
    late auth.AuthCredential credential;
    switch (provider) {
      case AuthProviders.PASSWORD:
        credential = auth.EmailAuthProvider.credential(email: email!, password: password!);
        break;
      case AuthProviders.PHONE:
        credential = auth.PhoneAuthProvider.credential(smsCode: smsCode!, verificationId: verificationId!);
        break;
      case AuthProviders.FACEBOOK:
        credential = auth.FacebookAuthProvider.credential(accessToken!.token);
        break;
      case AuthProviders.APPLE:
        credential = auth.OAuthProvider('apple.com').credential(
          accessToken: String.fromCharCodes(appleCredential!.credential?.authorizationCode ?? []),
          idToken: String.fromCharCodes(appleCredential.credential?.identityToken ?? []),
        );
        break;
    }
    return await auth.FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
  }

  static resetPassword(String emailAddress) async => await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);

  static deleteUser() async {
    try {
      // delete user records from CHANNEL_PARTICIPATION table
      await firestore.collection(ORDERS).where('authorID', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from REPORTS table
      await firestore.collection(REPORTS).where('source', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from REPORTS table
      await firestore.collection(REPORTS).where('dest', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from users table
      await firestore.collection(USERS).doc(auth.FirebaseAuth.instance.currentUser!.uid).delete();

      // delete user  from firebase auth
      await auth.FirebaseAuth.instance.currentUser!.delete();
    } catch (e, s) {
      print('FireStoreUtils.deleteUser $e $s');
    }
  }

  static Future<NotificationModel?> getNotificationContent(String type) async {
    NotificationModel? notificationModel;
    await firestore.collection(dynamicNotification).where('type', isEqualTo: type).get().then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());

        notificationModel = NotificationModel.fromJson(value.docs.first.data());
      } else {
        notificationModel = NotificationModel(id: "", message: "Notification setup is pending", subject: "setup notification", type: "");
      }
    });
    return notificationModel;
  }

  static Future<bool> sendFcmMessage(String type, String token) async {
    try {
      NotificationModel? notificationModel = await getNotificationContent(type);
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=AAAAirGxWR4:APA91bHr7ZhaiHtLQUVbhsGSvdeLUScqy9pAvsUcR__8Gel81nMDfNSrNWw3TYY80MfMqN-j7oPXBfZDhJ56WqWU5kvr_FwusLFm6uZgq3IisFesAKpumS8kASrvqSn83LTS_B5aMmyI",
      };
      var request = {
        "notification": {
          "title": notificationModel!.subject ?? '',
          "body": notificationModel.message ?? '',
          "sound": "default",
        },
        "priority": "high",
        'data': {},
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": token
      };

      var client = new http.Client();
      await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> sendChatFcmMessage(String title, String message, String token) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=AAAAirGxWR4:APA91bHr7ZhaiHtLQUVbhsGSvdeLUScqy9pAvsUcR__8Gel81nMDfNSrNWw3TYY80MfMqN-j7oPXBfZDhJ56WqWU5kvr_FwusLFm6uZgq3IisFesAKpumS8kASrvqSn83LTS_B5aMmyI",
      };
      var request = {
        "notification": {
          "title": title,
          "body": message,
          "sound": "default",
          // "color": COLOR_PRIMARY,
        },
        "priority": "high",
        'data': {},
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": token
      };

      var client = new http.Client();
      await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future topUpWalletAmountRefral({String paymentMethod = "test", bool isTopup = true, required amount, required id, orderId = "", userId, note}) async {
    print("this is te payment id");
    print(id);
    print(userId);

    await firestore.collection(Wallet).doc(id).set({
      "user_id": userId,
      "payment_method": paymentMethod,
      "amount": amount,
      "id": id,
      "order_id": orderId,
      "isTopUp": isTopup,
      "payment_status": "success",
      "date": DateTime.now(),
      "transactionUser": "driver",
      "note": note,
    }).then((value) {
      firestore.collection(Wallet).doc(id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print("nato");
        print(documentData.data());
      });
    });

    return "updated Amount";
  }

  static Future topUpWalletAmount({String paymentMethod = "test", bool isTopup = true, required amount, required id, orderId = ""}) async {
    print("this is te payment id");
    print(id);
    print(MyAppState.currentUser!.userID);

    TopupTranHistoryModel historyModel = TopupTranHistoryModel(
        amount: amount,
        id: id,
        orderId: orderId,
        userId: MyAppState.currentUser!.userID,
        date: Timestamp.now(),
        isTopup: isTopup,
        paymentMethod: paymentMethod,
        paymentStatus: "success",
        transactionUser: "driver");

    await firestore.collection(Wallet).doc(id).set(historyModel.toJson()).then((value) {
      firestore.collection(Wallet).doc(id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print("nato");
        print(documentData.data());
      });
    });

    return "updated Amount";
  }

  static getPayFastSettingData() async {
    firestore.collection(Setting).doc("payFastSettings").get().then((payFastData) {
      debugPrint(payFastData.data().toString());
      try {
        PayFastSettingData payFastSettingData = PayFastSettingData.fromJson(payFastData.data() ?? {});
        debugPrint(payFastData.toString());
        UserPreference.setPayFastData(payFastSettingData);
      } catch (error) {
        debugPrint("error>>>122");
        debugPrint(error.toString());
      }
    });
  }

  static getMercadoPagoSettingData() async {
    firestore.collection(Setting).doc("MercadoPago").get().then((mercadoPago) {
      try {
        MercadoPagoSettingData mercadoPagoDataModel = MercadoPagoSettingData.fromJson(mercadoPago.data() ?? {});
        UserPreference.setMercadoPago(mercadoPagoDataModel);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getReferralAmount() async {
    try {
      print(MyAppState.currentUser!.userID);
      await firestore.collection(Setting).doc("referral_amount").get().then((value) {
        referralAmount = value.data()!['referralAmount'];
      });
      await firestore.collection(Setting).doc("DriverNearBy").get().then((value) {
        minimumDepositToRideAccept = value.data()!['minimumDepositToRideAccept'];
        minimumAmountToWithdrawal = value.data()!['minimumAmountToWithdrawal'];
      });
      print(referralAmount);
      print(minimumDepositToRideAccept);
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralAmount;
  }

  static getPaypalSettingData() async {
    firestore.collection(Setting).doc("paypalSettings").get().then((paypalData) {
      try {
        PaypalSettingData paypalDataModel = PaypalSettingData.fromJson(paypalData.data() ?? {});
        UserPreference.setPayPalData(paypalDataModel);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getStripeSettingData() async {
    firestore.collection(Setting).doc("stripeSettings").get().then((stripeData) {
      try {
        StripeSettingData stripeSettingData = StripeSettingData.fromJson(stripeData.data() ?? {});
        UserPreference.setStripeData(stripeSettingData);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getFlutterWaveSettingData() async {
    firestore.collection(Setting).doc("flutterWave").get().then((flutterWaveData) {
      try {
        FlutterWaveSettingData flutterWaveSettingData = FlutterWaveSettingData.fromJson(flutterWaveData.data() ?? {});
        UserPreference.setFlutterWaveData(flutterWaveSettingData);
      } catch (error) {
        debugPrint("error>>>122");
        debugPrint(error.toString());
      }
    });
  }

  static getPayStackSettingData() async {
    firestore.collection(Setting).doc("payStack").get().then((payStackData) {
      try {
        PayStackSettingData payStackSettingData = PayStackSettingData.fromJson(payStackData.data() ?? {});
        UserPreference.setPayStackData(payStackSettingData);
      } catch (error) {
        debugPrint("error>>>122");
        debugPrint(error.toString());
      }
    });
  }

  static getPaytmSettingData() async {
    firestore.collection(Setting).doc("PaytmSettings").get().then((paytmData) {
      try {
        PaytmSettingData paytmSettingData = PaytmSettingData.fromJson(paytmData.data() ?? {});
        UserPreference.setPaytmData(paytmSettingData);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getWalletSettingData() {
    firestore.collection(Setting).doc('walletSettings').get().then((walletSetting) {
      try {
        bool walletEnable = walletSetting.data()!['isEnabled'];

        UserPreference.setWalletData(walletEnable);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  getRazorPayDemo() async {
    RazorPayModel userModel;
    firestore.collection(Setting).doc("razorpaySettings").get().then((user) {
      debugPrint(user.data().toString());
      try {
        userModel = RazorPayModel.fromJson(user.data() ?? {});
        UserPreference.setRazorPayData(userModel);
        RazorPayModel fhg = UserPreference.getRazorPayData();
        debugPrint(fhg.razorpayKey);
        //
        // RazorPayController().updateRazorPayData(razorPayData: userModel);

        isRazorPayEnabled = userModel.isEnabled;
        isRazorPaySandboxEnabled = userModel.isSandboxEnabled;
        razorpayKey = userModel.razorpayKey;
        razorpaySecret = userModel.razorpaySecret;
      } catch (e) {
        debugPrint('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });

    //yield* razorPayStreamController.stream;
  }

  static Future<OrderModel?> getOrderBuOrderId(String orderId) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(ORDERS).doc(orderId).get();
    if (userDocument.data() != null && userDocument.exists) {
      print("dataaaaaa");
      return OrderModel.fromJson(userDocument.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  static redirectMap({required BuildContext context, required String name, required double latitude, required double longLatitude}) async {
    if (mapType == "google") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.google);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.google,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Google map is not installed'.tr(),
          style: TextStyle(fontSize: 17),
        ).tr()));
      }
    } else if (mapType == "googleGo") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.googleGo);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.googleGo,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Google Go map is not installed'.tr(),
          style: TextStyle(fontSize: 17),
        ).tr()));
      }
    } else if (mapType == "waze") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.waze);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.waze,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Waze is not installed'.tr(),
          style: TextStyle(fontSize: 17),
        ).tr()));
      }
    } else if (mapType == "mapswithme") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.mapswithme);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.mapswithme,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Mapswithme is not installed'.tr(),
          style: TextStyle(fontSize: 17),
        ).tr()));
      }
    } else if (mapType == "yandexNavi") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexNavi);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexNavi,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'YandexNavi is not installed'.tr(),
          style: TextStyle(fontSize: 17),
        ).tr()));
      }
    } else if (mapType == "yandexMaps") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexMaps);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexMaps,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'yandexMaps map is not installed'.tr(),
          style: TextStyle(fontSize: 17),
        ).tr()));
      }
    }
  }
}
