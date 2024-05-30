// ignore_for_file: close_sinks, cancel_subscriptions

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/model/AddressModel.dart';
import 'package:flutter_application_1/model/AttributesModel.dart';
import 'package:flutter_application_1/model/BannerModel.dart';
import 'package:flutter_application_1/model/BlockUserModel.dart';
import 'package:flutter_application_1/model/BookTableModel.dart';
import 'package:flutter_application_1/model/ChatVideoContainer.dart';
import 'package:flutter_application_1/model/CodModel.dart';
import 'package:flutter_application_1/model/CurrencyModel.dart';
import 'package:flutter_application_1/model/DeliveryChargeModel.dart';
import 'package:flutter_application_1/model/FavouriteItemModel.dart';
import 'package:flutter_application_1/model/FavouriteModel.dart';
import 'package:flutter_application_1/model/FlutterWaveSettingDataModel.dart';
import 'package:flutter_application_1/model/MercadoPagoSettingsModel.dart';
import 'package:flutter_application_1/model/OrderModel.dart';
import 'package:flutter_application_1/model/PayFastSettingData.dart';
import 'package:flutter_application_1/model/PayStackSettingsModel.dart';
import 'package:flutter_application_1/model/ProductModel.dart';
import 'package:flutter_application_1/model/Ratingmodel.dart';
import 'package:flutter_application_1/model/ReviewAttributeModel.dart';
import 'package:flutter_application_1/model/User.dart';
import 'package:flutter_application_1/model/VendorCategoryModel.dart';
import 'package:flutter_application_1/model/VendorModel.dart';
import 'package:flutter_application_1/model/conversation_model.dart';
import 'package:flutter_application_1/model/email_template_model.dart';
import 'package:flutter_application_1/model/gift_cards_model.dart';
import 'package:flutter_application_1/model/gift_cards_order_model.dart';
import 'package:flutter_application_1/model/inbox_model.dart';
import 'package:flutter_application_1/model/notification_model.dart';
import 'package:flutter_application_1/model/offer_model.dart';
import 'package:flutter_application_1/model/paypalSettingData.dart';
import 'package:flutter_application_1/model/paytmSettingData.dart';
import 'package:flutter_application_1/model/razorpayKeyModel.dart';
import 'package:flutter_application_1/model/referral_model.dart';
import 'package:flutter_application_1/model/story_model.dart';
import 'package:flutter_application_1/model/stripeKey.dart';
import 'package:flutter_application_1/model/stripeSettingData.dart';
import 'package:flutter_application_1/model/topupTranHistory.dart';
import 'package:flutter_application_1/services/helper.dart';
import 'package:flutter_application_1/ui/reauthScreen/reauth_user_screen.dart';
import 'package:flutter_application_1/userPrefrence.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../constants.dart';
import '../model/TaxModel.dart';

class FireStoreUtils {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Reference storage = FirebaseStorage.instance.ref();
  final geo = GeoFlutterFire();

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

  late StreamController<OrderModel> ordersByIdStreamController;
  late StreamSubscription ordersByIdStreamSub;

  Stream<OrderModel?> getOrderByID(String inProgressOrderID) async* {
    ordersByIdStreamController = StreamController();
    ordersByIdStreamSub = firestore.collection(ORDERS).doc(inProgressOrderID).snapshots().listen((onData) async {
      if (onData.data() != null) {
        OrderModel? orderModel = OrderModel.fromJson(onData.data()!);
        ordersByIdStreamController.sink.add(orderModel);
      }
    });
    yield* ordersByIdStreamController.stream;
  }

  Future<RatingModel?> getOrderReviewsbyID(String ordertId, String productId) async {
    RatingModel? ratingproduct;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(Order_Rating).where('orderid', isEqualTo: ordertId).where('productId', isEqualTo: productId).get();
    if (vendorsQuery.docs.isNotEmpty) {
      try {
        if (vendorsQuery.docs.isNotEmpty) {
          ratingproduct = RatingModel.fromJson(vendorsQuery.docs.first.data());
        }
      } catch (e) {
        debugPrint('FireStoreUtils.getVendorByVendorID Parse error $e');
      }
    }
    return ratingproduct;
  }

  static Future<ProductModel?> updateProduct(ProductModel prodduct) async {
    return await firestore.collection(PRODUCTS).doc(prodduct.id).set(prodduct.toJson()).then((document) {
      return prodduct;
    });
  }

  Future<List<VendorCategoryModel>> getHomePageShowCategory() async {
    List<VendorCategoryModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery = await firestore.collection(VENDORS_CATEGORIES).where("show_in_homepage", isEqualTo: true).where('publish', isEqualTo: true).get();
    await Future.forEach(cuisinesQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        cuisines.add(VendorCategoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return cuisines;
  }

  Future<List<BannerModel>> getHomeTopBanner() async {
    List<BannerModel> bannerHome = [];
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery =
        await firestore.collection(MENU_ITEM).where("is_publish", isEqualTo: true).where("position", isEqualTo: "top").orderBy("set_order", descending: false).get();
    await Future.forEach(bannerHomeQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        bannerHome.add(BannerModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return bannerHome;
  }

  Future<List<BannerModel>> getHomeMiddleBanner() async {
    List<BannerModel> bannerHome = [];
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery =
        await firestore.collection(MENU_ITEM).where("is_publish", isEqualTo: true).where("position", isEqualTo: "middle").orderBy("set_order", descending: false).get();
    await Future.forEach(bannerHomeQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        bannerHome.add(BannerModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return bannerHome;
  }

  Future<ProductModel> getProductByID(String productId) async {
    late ProductModel productModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(PRODUCTS).where('id', isEqualTo: productId).get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        productModel = ProductModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      debugPrint('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return productModel;
  }

  static Future<VendorModel?> getVendor(String vid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(VENDORS).doc(vid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return VendorModel.fromJson(userDocument.data()!);
    } else {
      debugPrint("nulllll");
      return null;
    }
  }

  Future<List<FavouriteItemModel>> getFavouritesProductList(String userId) async {
    List<FavouriteItemModel> lstFavourites = [];

    QuerySnapshot<Map<String, dynamic>> favourites = await firestore.collection(FavouriteItem).where('user_id', isEqualTo: userId).get();
    await Future.forEach(favourites.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        lstFavourites.add(FavouriteItemModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FavouriteModel.getCurrencys Parse error $e');
      }
    });
    return lstFavourites;
  }

  static Future<List<AttributesModel>> getAttributes() async {
    List<AttributesModel> attributesList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(VENDOR_ATTRIBUTES).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        attributesList.add(AttributesModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return attributesList;
  }

  static Future<List<ReviewAttributeModel>> getAllReviewAttributes() async {
    List<ReviewAttributeModel> reviewAttributesList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(REVIEW_ATTRIBUTES).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        reviewAttributesList.add(ReviewAttributeModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return reviewAttributesList;
  }

  Future<List<RatingModel>> getReviewList(String productId) async {
    List<RatingModel> reviewList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(Order_Rating).where('productId', isEqualTo: productId).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        reviewList.add(RatingModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return reviewList;
  }

  static Future<List<ProductModel>> getStoreProduct(String storeId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: storeId).where('publish', isEqualTo: true).limit(6).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return productList;
  }

  static Future<List<ProductModel>> getTakeawayStoreProduct(String storeId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: storeId).where('publish', isEqualTo: true).limit(6).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return productList;
  }

  static Future<List<ProductModel>> getProductListByCategoryId(String categoryId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(PRODUCTS).where('categoryID', isEqualTo: categoryId).where('publish', isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return productList;
  }

  Future<void> setFavouriteStoreItem(FavouriteItemModel favouriteModel) async {
    await firestore.collection(FavouriteItem).add(favouriteModel.toJson()).then((value) {});
  }

  void removeFavouriteItem(FavouriteItemModel favouriteModel) {
    FirebaseFirestore.instance.collection(FavouriteItem).where("product_id", isEqualTo: favouriteModel.productId).get().then((value) {
      for (var element in value.docs) {
        FirebaseFirestore.instance.collection(FavouriteItem).doc(element.id).delete().then((value) {
          debugPrint("Success!");
        });
      }
    });
  }

  static Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return User.fromJson(userDocument.data()!);
    } else {
      return null;
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

  static Future<bool> sendFcmMessage(String type, String token) async {
    try {
      NotificationModel? notificationModel = await getNotificationContent(type);
      print(notificationModel?.toJson());
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
          // "color": COLOR_PRIMARY,
        },
        "priority": "high",
        'data': <String, dynamic>{'id': '1', 'status': 'done'},
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

  Future<String> uploadProductImage(File image, String progress) async {
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('flutter/uberEats/productImages/$uniqueID'
        '.png');
    UploadTask uploadTask = upload.putFile(image);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('{} \n{} / {}KB'.tr(args: [progress, '${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)}', '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} ']));
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      debugPrint((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<User?> updateCurrentUser(User user) async {
    return await firestore.collection(USERS).doc(user.userID).set(user.toJson()).then((document) {
      MyAppState.currentUser = user;
      return user;
    });
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await firestore.collection(VENDORS).doc(vendor.id).set(vendor.toJson()).then((document) {
      return vendor;
    });
  }

  static Future<String> uploadUserImageToFireStorage(File image, String userID) async {
    Reference upload = storage.child('images/$userID.png');

    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<Url> uploadChatImageToFireStorage(File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
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
      debugPrint((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer> uploadChatVideoToFireStorage(File video, BuildContext context) async {
    showProgress(context, 'Uploading video...', false);
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
        debugPrint('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* userStreamController.stream;
  }

  Stream<StripeKeyModel> getStripe() async* {
    StreamController<StripeKeyModel> stripeStreamController = StreamController();
    firestore.collection(Setting).doc(StripeSetting).snapshots().listen((user) {
      try {
        StripeKeyModel userModel = StripeKeyModel.fromJson(user.data() ?? {});
        stripeStreamController.sink.add(userModel);
      } catch (e) {
        debugPrint('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* stripeStreamController.stream;
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

        // isRazorPayEnabled = userModel.isEnabled;
        // isRazorPaySandboxEnabled = userModel.isSandboxEnabled;
        // razorpayKey = userModel.razorpayKey;
        // razorpaySecret = userModel.razorpaySecret;
      } catch (e) {
        debugPrint('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });

    //yield* razorPayStreamController.stream;
  }

  Future<CodModel?> getCod() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('CODSettings').get();
    if (codQuery.data() != null) {
      debugPrint("dataaaaaa");
      return CodModel.fromJson(codQuery.data()!);
    } else {
      debugPrint("nulllll");
      return null;
    }
  }

  Future<DeliveryChargeModel?> getDeliveryCharges() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('DeliveryCharge').get();
    if (codQuery.data() != null) {
      return DeliveryChargeModel.fromJson(codQuery.data()!);
    } else {
      return null;
    }
  }

  Future<String?> getRestaurantNearBy() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('RestaurantNearBy').get();
    if (codQuery.data() != null) {
      radiusValue = double.parse(codQuery["radios"].toString());
      debugPrint("--------->$radiusValue");
      return codQuery["radios"].toString();
    } else {
      return "";
    }
  }

  Future<Map<String, dynamic>?> getAdminCommission() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('AdminCommission').get();
    if (codQuery.data() != null) {
      Map<String, dynamic> getValue = {"adminCommission": codQuery["fix_commission"].toString(), "isAdminCommission": codQuery["isEnabled"], 'adminCommissionType': codQuery["commissionType"]};
      debugPrint(getValue.toString() + "===____");
      return getValue;
    } else {
      return null;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('productspppp**-FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return products;
  }

  Future<List<ProductModel>> getAllTakeAWayProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('productspppp**-123--FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return products;
  }

  Future<List<ProductModel>> getAllDelevryProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where("takeawayOption", isEqualTo: false).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('productspppp**-FireStoreUtils.getAllProducts Parse error $e  ${document.data()['id']}');
      }
    });
    return products;
  }

  Future<bool> blockUser(User blockedUser, String type) async {
    bool isSuccessful = false;
    BlockUserModel blockUserModel = BlockUserModel(type: type, source: MyAppState.currentUser!.userID, dest: blockedUser.userID, createdAt: Timestamp.now());
    await firestore.collection(REPORTS).add(blockUserModel.toJson()).then((onValue) {
      isSuccessful = true;
    });
    return isSuccessful;
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
      debugPrint((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'audio', url: downloadUrl.toString());
  }

  Future<List<VendorCategoryModel>> getCuisines() async {
    List<VendorCategoryModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery = await firestore.collection(VENDORS_CATEGORIES).where('publish', isEqualTo: true).get();
    await Future.forEach(cuisinesQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        cuisines.add(VendorCategoryModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return cuisines;
  }

  // StreamController<List<VendorModel>>? vendorStreamController;
  //
  // Stream<List<VendorModel>> getVendors1({String? path}) async* {
  //   vendorStreamController = StreamController<List<VendorModel>>.broadcast();
  //   List<VendorModel> vendors = [];
  //   try {
  //     var collectionReference = (path == null || path.isEmpty) ? firestore.collection(VENDORS) : firestore.collection(VENDORS).where("enabledDiveInFuture", isEqualTo: true);
  //     GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.location!.location!.latitude, longitude: MyAppState.selectedPosotion.location!.location!.longitude);
  //     String field = 'g';
  //     Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
  //
  //     stream.listen((List<DocumentSnapshot> documentList) {
  //       // doSomething()
  //       documentList.forEach((DocumentSnapshot document) {
  //         final data = document.data() as Map<String, dynamic>;
  //         vendors.add(VendorModel.fromJson(data));
  //       });
  //       if (!vendorStreamController!.isClosed) {
  //         vendorStreamController!.add(vendors);
  //       }
  //     });
  //   } catch (e) {
  //     print('FavouriteModel $e');
  //   }
  //   yield* vendorStreamController!.stream;
  // }

  closeVendorStream() {
    if (allResaturantStreamController != null) {
      allResaturantStreamController!.close();
    }
  }

  Future<List<VendorModel>> getVendors() async {
    List<VendorModel> vendors = [];
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(VENDORS).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        vendors.add(VendorModel.fromJson(document.data()));
        print("*-*-/*-*-" + document["title"].toString());
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    return vendors;
  }

  StreamSubscription? ordersStreamSub;
  StreamController<List<OrderModel>>? ordersStreamController;

  Stream<List<OrderModel>> getOrders(String userID) async* {
    List<OrderModel> orders = [];
    ordersStreamController = StreamController();
    ordersStreamSub = firestore.collection(ORDERS).where('authorID', isEqualTo: userID).orderBy('createdAt', descending: true).snapshots().listen((onData) async {
      orders.clear();
      await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          if (!orders.contains(orderModel)) {
            orders.add(orderModel);
          }
        } catch (e, s) {
          print('watchOrdersStatus parse error ${element.id} $e $s');
        }
      });
      ordersStreamController!.sink.add(orders);
    });
    yield* ordersStreamController!.stream;
  }

  Stream<List<BookTableModel>> getBookingOrders(String userID, bool isUpComing) async* {
    List<BookTableModel> orders = [];

    if (isUpComing) {
      StreamController<List<BookTableModel>> upcomingordersStreamController = StreamController();
      firestore
          .collection(ORDERS_TABLE)
          .where('author.id', isEqualTo: userID)
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) async {
        await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
          try {
            orders.add(BookTableModel.fromJson(element.data()));
          } catch (e, s) {
            print('booktable parse error ${element.id} $e $s');
          }
        });
        upcomingordersStreamController.sink.add(orders);
      });
      yield* upcomingordersStreamController.stream;
    } else {
      StreamController<List<BookTableModel>> bookedordersStreamController = StreamController();
      firestore
          .collection(ORDERS_TABLE)
          .where('author.id', isEqualTo: userID)
          .where('date', isLessThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) async {
        await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
          try {
            orders.add(BookTableModel.fromJson(element.data()));
          } catch (e, s) {
            print('booktable parse error ${element.id} $e $s');
          }
        });
        bookedordersStreamController.sink.add(orders);
      });
      yield* bookedordersStreamController.stream;
    }
  }

  closeOrdersStream() {
    if (ordersStreamSub != null) {
      ordersStreamSub!.cancel();
    }
    if (ordersStreamController != null) {
      ordersStreamController!.close();
    }
  }

  Future<void> setFavouriteRestaurant(FavouriteModel favouriteModel) async {
    await firestore.collection(FavouriteRestaurant).add(favouriteModel.toJson()).then((value) {
      print("===FAVOURITE ADDED===");
    });
  }

  void removeFavouriteRestaurant(FavouriteModel favouriteModel) {
    FirebaseFirestore.instance.collection(FavouriteRestaurant).where("restaurant_id", isEqualTo: favouriteModel.restaurantId).get().then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance.collection(FavouriteRestaurant).doc(element.id).delete().then((value) {
          print("Success!");
        });
      });
    });
  }

  StreamController<List<VendorModel>>? allResaturantStreamController;

  Stream<List<VendorModel>> getAllRestaurants({String? path}) async* {
    allResaturantStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];

    try {
      var collectionReference = (path == null || path.isEmpty) ? firestore.collection(VENDORS) : firestore.collection(VENDORS).where("enabledDiveInFuture", isEqualTo: true);
      GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.location!.latitude, longitude: MyAppState.selectedPosotion.location!.longitude);

      String field = 'g';
      Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) {
        if (documentList.isEmpty) {
          allResaturantStreamController!.close();
        }

        for (var document in documentList) {
          final data = document.data() as Map<String, dynamic>;
          vendors.add(VendorModel.fromJson(data));
          allResaturantStreamController!.add(vendors);
        }
      });
    } catch (e) {
      print('FavouriteModel $e');
    }

    yield* allResaturantStreamController!.stream;
  }

  StreamController<List<VendorModel>>? allCategoryResaturantStreamController;

  Stream<List<VendorModel>> getCategoryRestaurants(String categoryId) async* {
    allCategoryResaturantStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];

    try {
      var collectionReference = firestore.collection(VENDORS).where('categoryID', isEqualTo: categoryId);

      GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.location!.latitude, longitude: MyAppState.selectedPosotion.location!.longitude);

      String field = 'g';
      Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) {
        if (documentList.isEmpty) {
          allCategoryResaturantStreamController!.close();
        }

        for (var document in documentList) {
          final data = document.data() as Map<String, dynamic>;
          vendors.add(VendorModel.fromJson(data));
          allCategoryResaturantStreamController!.add(vendors);
        }
      });
    } catch (e) {
      print('FavouriteModel $e');
    }

    yield* allCategoryResaturantStreamController!.stream;
  }

  StreamController<List<VendorModel>>? newArrivalStreamController;

  Stream<List<VendorModel>> getVendorsForNewArrival({String? path}) async* {
    List<VendorModel> vendors = [];

    newArrivalStreamController = StreamController<List<VendorModel>>.broadcast();
    var collectionReference = (path == null || path.isEmpty) ? firestore.collection(VENDORS) : firestore.collection(VENDORS).where("enabledDiveInFuture", isEqualTo: true);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.location!.latitude, longitude: MyAppState.selectedPosotion.location!.longitude);
    String field = 'g';
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((DocumentSnapshot document) {
        final data = document.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        if (!newArrivalStreamController!.isClosed) {
          newArrivalStreamController!.add(vendors);
        }
      });
    });

    yield* newArrivalStreamController!.stream;
  }

  closeNewArrivalStream() {
    if (newArrivalStreamController != null) {
      newArrivalStreamController!.close();
    }
  }

  late StreamController<List<VendorModel>> cusionStreamController;

  Stream<List<VendorModel>> getVendorsByCuisineID(String cuisineID, {bool? isDinein}) async* {
    await getRestaurantNearBy();
    cusionStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = isDinein!
        ? firestore.collection(VENDORS).where('categoryID', isEqualTo: cuisineID).where("enabledDiveInFuture", isEqualTo: true)
        : firestore.collection(VENDORS).where('categoryID', isEqualTo: cuisineID);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.location!.latitude, longitude: MyAppState.selectedPosotion.location!.longitude);
    String field = 'g';
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      Future.forEach(documentList, (DocumentSnapshot element) {
        final data = element.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        cusionStreamController.add(vendors);
      });
      cusionStreamController.close();
    });

    yield* cusionStreamController.stream;
  }

  Future<String?> getplaceholderimage() async {
    var collection = FirebaseFirestore.instance.collection(Setting);
    var docSnapshot = await collection.doc('placeHolderImage').get();
    Map<String, dynamic>? data = docSnapshot.data();
    var value = data?['image'];
    placeholderImage = value;
    return placeholderImage;
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


  Future<List<OfferModel>> getPublicCoupons() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery =
        await firestore.collection(COUPON).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).where("isEnabled", isEqualTo: true).where("isPublic", isEqualTo: true).get();
    await Future.forEach(couponsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return coupon;
  }

  Future<List<OfferModel>> getAllCoupons() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery = await firestore.collection(COUPON).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).where("isEnabled", isEqualTo: true).get();
    await Future.forEach(couponsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return coupon;
  }

  Future<List<StoryModel>> getStory() async {
    List<StoryModel> story = [];
    QuerySnapshot<Map<String, dynamic>> storyQuery = await firestore.collection(STORY).get();
    await Future.forEach(storyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        story.add(StoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return story;
  }

  Future<List<ProductModel>> getVendorProductsTakeAWay(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
        //print('=====TP+++++ ${document.data().toString()}');
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print("=====IDDDDDD" + products.length.toString());
    return products;
  }

  Future<List<ProductModel>> getVendorProductsDelivery(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).where("takeawayOption", isEqualTo: false).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print("=====IDDDDDD----" + products.length.toString());
    return products;
  }

  Future<List<OfferModel>> getOfferByVendorID(String vendorID) async {
    List<OfferModel> offers = [];
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery = await firestore
        .collection(COUPON)
        .where("resturant_id", isEqualTo: vendorID)
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get();

    print("-------->${bannerHomeQuery.docs}");
    await Future.forEach(bannerHomeQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("-------->");
        print(document.data());
        offers.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return offers;
  }

  Future<VendorCategoryModel?> getVendorCategoryById(String vendorCategoryID) async {
    print('we are enter-->');
    VendorCategoryModel? vendorCategoryModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(VENDORS_CATEGORIES).where('id', isEqualTo: vendorCategoryID).where('publish', isEqualTo: true).get();
    try {
      print('we are enter-->');
      if (vendorsQuery.docs.length > 0) {
        vendorCategoryModel = VendorCategoryModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendorCategoryModel;
  }

  Future<VendorModel> getVendorByVendorID(String vendorID) async {
    late VendorModel vendor;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(VENDORS).where('id', isEqualTo: vendorID).get();
    try {
      if (vendorsQuery.docs.length > 0) {
        vendor = VendorModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendor;
  }

  Future<List<RatingModel>> getReviewsbyVendorID(String vendorId) async {
    List<RatingModel> vendorreview = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(Order_Rating)
        .where('VendorId', isEqualTo: vendorId)
        // .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      print(document);
      try {
        vendorreview.add(RatingModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getOrders Parse error ${document.id} $e');
      }
    });
    return vendorreview;
  }

  Future<ProductModel> getProductByProductID(String productId) async {
    late ProductModel productModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(PRODUCTS).where('id', isEqualTo: productId).where('publish', isEqualTo: true).get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        productModel = ProductModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return productModel;
  }

  Future<VendorCategoryModel?> getVendorCategoryByCategoryId(String vendorCategoryID) async {
    DocumentSnapshot<Map<String, dynamic>> documentReference = await firestore.collection(VENDORS_CATEGORIES).doc(vendorCategoryID).get();
    if (documentReference.data() != null && documentReference.exists) {
      print("dataaaaaa aaa ");
      return VendorCategoryModel.fromJson(documentReference.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  Future<ReviewAttributeModel?> getVendorReviewAttribute(String attrubuteId) async {
    DocumentSnapshot<Map<String, dynamic>> documentReference = await firestore.collection(REVIEW_ATTRIBUTES).doc(attrubuteId).get();
    if (documentReference.data() != null && documentReference.exists) {
      print("dataaaaaa aaa ");
      return ReviewAttributeModel.fromJson(documentReference.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  static Future<RatingModel?> updateReviewbyId(RatingModel ratingproduct) async {
    return await firestore.collection(Order_Rating).doc(ratingproduct.id).set(ratingproduct.toJson()).then((document) {
      return ratingproduct;
    });
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await firestore.collection("chat_restaurant").doc(inboxModel.orderId).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await firestore.collection("chat_restaurant").doc(conversationModel.orderId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson()).then((document) {
      return conversationModel;
    });
  }

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

  Future<List<FavouriteModel>> getFavouriteRestaurant(String userId) async {
    List<FavouriteModel> favouriteItem = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(FavouriteRestaurant).where('user_id', isEqualTo: userId).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        favouriteItem.add(FavouriteModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    return favouriteItem;
  }

  Future<OrderModel> placeOrder(OrderModel orderModel) async {
    DocumentReference documentReference = firestore.collection(ORDERS).doc(UserPreference.getOrderId());
    orderModel.id = documentReference.id;
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  Future<GiftCardsOrderModel> placeGiftCardOrder(GiftCardsOrderModel giftCardsOrderModel) async {
    await firestore.collection(GIFT_PURCHASES).doc(giftCardsOrderModel.id).set(giftCardsOrderModel.toJson());
    return giftCardsOrderModel;
  }

  Future<List<GiftCardsOrderModel>> getGiftHistory() async {
    List<GiftCardsOrderModel> giftCardsOrderList = [];
    await firestore.collection(GIFT_PURCHASES).where("userid", isEqualTo: MyAppState.currentUser!.userID).get().then((value) {
      for (var element in value.docs) {
        GiftCardsOrderModel giftCardsOrderModel = GiftCardsOrderModel.fromJson(element.data());
        giftCardsOrderList.add(giftCardsOrderModel);
      }
    });
    return giftCardsOrderList;
  }

  Future<GiftCardsOrderModel?> checkRedeemCode(String giftCode) async {
    GiftCardsOrderModel? giftCardsOrderModel;
    await firestore.collection(GIFT_PURCHASES).where("giftCode", isEqualTo: giftCode).get().then((value) {
      if (value.docs.isNotEmpty) {
        giftCardsOrderModel = GiftCardsOrderModel.fromJson(value.docs.first.data());
      }
    });
    return giftCardsOrderModel;
  }

  Future<OrderModel> placeOrderWithTakeAWay(OrderModel orderModel) async {
    DocumentReference documentReference;
    if (orderModel.id.isEmpty) {
      documentReference = firestore.collection(ORDERS).doc();
      orderModel.id = documentReference.id;
    } else {
      documentReference = firestore.collection(ORDERS).doc(orderModel.id);
    }
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  Future<BookTableModel> bookTable(BookTableModel orderModel) async {
    DocumentReference documentReference = firestore.collection(ORDERS_TABLE).doc();
    orderModel.id = documentReference.id;
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  static createOrder() async {
    DocumentReference documentReference = firestore.collection(ORDERS).doc();
    final orderId = documentReference.id;
    UserPreference.setOrderId(orderId: orderId);
  }

  static Future createPaymentId() async {
    DocumentReference documentReference = firestore.collection(Wallet).doc();
    final paymentId = documentReference.id;
    UserPreference.setPaymentId(paymentId: paymentId);
    return paymentId;
  }

  static Future<List<TopupTranHistoryModel>> getTopUpTransaction() async {
    final userId = MyAppState.currentUser!.userID; //UserPreference.getUserId();
    List<TopupTranHistoryModel> topUpHistoryList = [];
    QuerySnapshot<Map<String, dynamic>> documentReference = await firestore.collection(Wallet).where('user_id', isEqualTo: userId).get();
    await Future.forEach(documentReference.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        topUpHistoryList.add(TopupTranHistoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return topUpHistoryList;
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
        transactionUser: "user");
    await firestore.collection(Wallet).doc(id).set(historyModel.toJson()).then((value) {
      firestore.collection(Wallet).doc(id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print("nato");
        print(documentData.data());
      });
    });

    return "updated Amount";
  }

  static Future updateWalletAmount({required amount}) async {
    dynamic walletAmount = 0;
    final userId = MyAppState.currentUser!.userID; //UserPreference.getUserId();
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;
      if (userDocument.data() != null && userDocument.exists) {
        try {
          print(userDocument.data());
          User user = User.fromJson(userDocument.data()!);
          MyAppState.currentUser = user;
          print(user.lastName.toString() + "=====.....(user.wallet_amount");
          print("add ${user.lastName} + $amount");
          await firestore.collection(USERS).doc(userId).update({"wallet_amount": user.walletAmount + amount}).then((value) => print("north"));
          /*print(user.wallet_amount);


          walletAmount = user.wallet_amount! + amount;*/
          DocumentSnapshot<Map<String, dynamic>> newUserDocument = await firestore.collection(USERS).doc(userId).get();
          MyAppState.currentUser = User.fromJson(newUserDocument.data()!);
          print(MyAppState.currentUser);
        } catch (error) {
          print(error);
          if (error.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
            //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
            //walletAmount = 0;
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

  static sendOrderEmail({required OrderModel orderModel}) async {
    String firstHTML = """
       <table style="width: 100%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">
    <thead>
        <tr>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Product Name<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Quantity<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Price<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Extra Item Price<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Total<br></th>
        </tr>
    </thead>
    <tbody>
    """;

    EmailTemplateModel? emailTemplateModel = await FireStoreUtils.getEmailTemplates(newOrderPlaced);

    String newString = emailTemplateModel!.message.toString();
    newString = newString.replaceAll("{username}", MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName);
    newString = newString.replaceAll("{orderid}", orderModel.id);
    newString = newString.replaceAll("{date}", DateFormat('yyyy-MM-dd').format(orderModel.createdAt.toDate()));
    newString = newString.replaceAll(
      "{address}",
      '${orderModel.address!.getFullAddress()}',
    );
    newString = newString.replaceAll(
      "{paymentmethod}",
      orderModel.paymentMethod,
    );

    double deliveryCharge = 0.0;
    double total = 0.0;
    double specialDiscount = 0.0;
    double discount = 0.0;
    double taxAmount = 0.0;
    double tipValue = 0.0;
    String specialLabel = '(${orderModel.specialDiscount!['special_discount_label']}${orderModel.specialDiscount!['specialType'] == "amount" ? currencyModel!.symbol : "%"})';
    List<String> htmlList = [];

    if (orderModel.deliveryCharge != null) {
      deliveryCharge = double.parse(orderModel.deliveryCharge.toString());
    }
    if (orderModel.tipValue != null) {
      tipValue = double.parse(orderModel.tipValue.toString());
    }
    orderModel.products.forEach((element) {
      if (element.extras_price != null && element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
        total += element.quantity * double.parse(element.extras_price!);
      }
      total += element.quantity * double.parse(element.price);

      List<dynamic>? addon = element.extras;
      String extrasDisVal = '';
      for (int i = 0; i < addon!.length; i++) {
        extrasDisVal += '${addon[i].toString().replaceAll("\"", "")} ${(i == addon.length - 1) ? "" : ","}';
      }
      String product = """
        <tr>
            <td style="width: 20%; border-top: 1px solid rgb(0, 0, 0);">${element.name}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${element.quantity}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${amountShow(amount: element.price.toString())}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${amountShow(amount: element.extras_price.toString())}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${amountShow(amount: ((element.quantity * double.parse(element.extras_price!) + (element.quantity * double.parse(element.price)))).toString())}</td>
        </tr>
        <tr>
            <td style="width: 20%;">${extrasDisVal.isEmpty ? "" : "Extra Item : $extrasDisVal"}</td>
        </tr>
    """;
      htmlList.add(product);
    });

    if (orderModel.specialDiscount!.isNotEmpty) {
      specialDiscount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
    }

    if (orderModel.couponId != null && orderModel.couponId!.isNotEmpty) {
      discount = double.parse(orderModel.discount.toString());
    }

    List<String> taxHtmlList = [];
    if (taxList != null) {
      for (var element in taxList!) {
        taxAmount = taxAmount + calculateTax(amount: (total - discount - specialDiscount).toString(), taxModel: element);
        String taxHtml =
            """<span style="font-size: 1rem;">${element.title}: ${amountShow(amount: calculateTax(amount: (total - discount - specialDiscount).toString(), taxModel: element).toString())}${taxList!.indexOf(element) == taxList!.length - 1 ? "</span>" : "<br></span>"}""";
        taxHtmlList.add(taxHtml);
      }
    }

    var totalamount = orderModel.deliveryCharge == null || orderModel.deliveryCharge!.isEmpty
        ? total + taxAmount - discount - specialDiscount
        : total + taxAmount + double.parse(orderModel.deliveryCharge!) + double.parse(orderModel.tipValue!) - discount - specialDiscount;

    newString = newString.replaceAll("{subtotal}", amountShow(amount: total.toString()));
    newString = newString.replaceAll("{coupon}", orderModel.couponId.toString());
    newString = newString.replaceAll("{discountamount}", amountShow(amount: orderModel.discount.toString()));
    newString = newString.replaceAll("{specialcoupon}", specialLabel);
    newString = newString.replaceAll("{specialdiscountamount}", amountShow(amount: specialDiscount.toString()));
    newString = newString.replaceAll("{shippingcharge}", amountShow(amount: deliveryCharge.toString()));
    newString = newString.replaceAll("{tipamount}", amountShow(amount: tipValue.toString()));
    newString = newString.replaceAll("{totalAmount}", amountShow(amount: totalamount.toString()));

    String tableHTML = htmlList.join();
    String lastHTML = "</tbody></table>";
    newString = newString.replaceAll("{productdetails}", firstHTML + tableHTML + lastHTML);
    newString = newString.replaceAll("{taxdetails}", taxHtmlList.join());
    newString = newString.replaceAll("{newwalletbalance}.", amountShow(amount: MyAppState.currentUser!.walletAmount.toString()));

    String subjectNewString = emailTemplateModel.subject.toString();
    subjectNewString = subjectNewString.replaceAll("{orderid}", orderModel.id);
    await sendMail(subject: subjectNewString, isAdmin: emailTemplateModel.isSendToAdmin, body: newString, recipients: [MyAppState.currentUser!.email]);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOrderStatus(String orderID) async* {
    yield* firestore.collection(ORDERS).doc(orderID).snapshots();
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
      LoginResult result = await facebookAuth.login(
        permissions: ['public_profile', 'email', 'pages_show_list', 'pages_messaging', 'pages_manage_metadata'],
      ); // by default we request the email and the public profile
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
    auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(auth.FacebookAuthProvider.credential(token.tokenString));
    User? user = await getCurrentUser(authResult.user?.uid ?? ' ');
    List<String> fullName = (userData['name'] as String).split(' ');
    String firstName = '';
    String lastName = '';
    if (fullName.isNotEmpty) {
      firstName = fullName.first;
      lastName = fullName.skip(1).join(' ');
    }
    if (user != null && user.role == USER_ROLE_CUSTOMER) {
      user.profilePictureURL = userData['picture']['data']['url'];
      user.firstName = firstName;
      user.lastName = lastName;
      user.email = userData['email'];
      //user.active = true;
      user.role = USER_ROLE_CUSTOMER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else if (user == null) {
      user = User(
          email: userData['email'] ?? '',
          firstName: firstName,
          profilePictureURL: userData['picture']['data']['url'] ?? '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: lastName,
          active: true,
          role: USER_ROLE_CUSTOMER,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          createdAt: Timestamp.now(),
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user, "");
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
      return "notLoginApple".tr();
    }

    if (appleCredential.status == apple.AuthorizationStatus.authorized) {
      final auth.AuthCredential credential = auth.OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(appleCredential.credential?.authorizationCode ?? []),
        idToken: String.fromCharCodes(appleCredential.credential?.identityToken ?? []),
      );
      return await handleAppleLogin(credential, appleCredential.credential!);
    } else {
      return "notLoginApple".tr();
    }
  }

  static handleAppleLogin(
    auth.AuthCredential credential,
    apple.AppleIdCredential appleIdCredential,
  ) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(credential);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    if (user != null) {
      //user.active = true;
      user.role = USER_ROLE_CUSTOMER;
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
          role: USER_ROLE_CUSTOMER,
          active: true,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          createdAt: Timestamp.now(),
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user, "");
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  /// save a new user document in the USERS table in firebase firestore
  /// returns an error message on failure or null on success
  static Future<String?> firebaseCreateNewUser(User user, String referralCode) async {
    try {
      if (referralCode.isNotEmpty) {
        FireStoreUtils.getReferralUserByCode(referralCode.toString()).then((value) async {
          if (value != null) {
            ReferralModel ownReferralModel = ReferralModel(id: user.userID, referralBy: value.id, referralCode: getReferralCode());
            await referralAdd(ownReferralModel);
          } else {
            ReferralModel referralModel = ReferralModel(id: user.userID, referralBy: "", referralCode: getReferralCode());
            await referralAdd(referralModel);
          }
        });
      } else {
        ReferralModel referralModel = ReferralModel(id: user.userID, referralBy: "", referralCode: getReferralCode());
        await referralAdd(referralModel);
      }

      await firestore.collection(USERS).doc(user.userID).set(user.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return "notSignUp".tr();
    }
    return null;
  }

  static getReferralAmount() async {
    try {
      await firestore.collection(Setting).doc("referral_amount").get().then((value) {
        referralAmount = value.data()!['referralAmount'];
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralAmount;
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await firestore.collection(REFERRAL).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    ReferralModel? referralModel;
    try {
      await firestore.collection(REFERRAL).where("referralCode", isEqualTo: referralCode).get().then((value) {
        referralModel = ReferralModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<ReferralModel?> getReferralUserBy() async {
    ReferralModel? referralModel;
    try {
      print(MyAppState.currentUser!.userID);
      await firestore.collection(REFERRAL).doc(MyAppState.currentUser!.userID).get().then((value) {
        referralModel = ReferralModel.fromJson(value.data()!);
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await firestore.collection(REFERRAL).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return 'Couldn\'t review'.tr();
    }
    return null;
  }

  static Future<String?> firebaseCreateNewReview(RatingModel ratingModel) async {
    try {
      await firestore.collection(Order_Rating).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return 'Couldn\'t review'.tr();
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
      // result.user.
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firestore.collection(USERS).doc(result.user?.uid ?? '').get();
      User? user;

      if (documentSnapshot.exists) {
        // if(user!.role != 'vendor'){
        user = User.fromJson(documentSnapshot.data() ?? {});
        // if(  USER_ROLE_CUSTOMER ==user.role)
        // {
        user.fcmToken = await firebaseMessaging.getToken() ?? '';

        //user.active = true;

        //      }
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
  static Future<dynamic> firebaseSubmitPhoneNumberCode(String verificationID, String code, String phoneNumber, BuildContext context,
      {String firstName = 'Anonymous', String lastName = 'User', File? image, String referralCode = ''}) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(verificationId: verificationID, smsCode: code);
    auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null && user.role == USER_ROLE_CUSTOMER) {
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      user.role = USER_ROLE_CUSTOMER;
      //user.active = true;
      await updateCurrentUser(user);
      return user;
    } else if (user == null) {
      /// create a new user from phone login
      String profileImageUrl = '';
      if (image != null) {
        File compressedImage = await FireStoreUtils.compressImage(image);
        final bytes = compressedImage.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        final mb = kb / 1024;

        if (mb > 2) {
          hideProgress();
          showAlertDialog(context, "error".tr(), "imageTooLarge".tr(), true);
          return;
        }
        profileImageUrl = await uploadUserImageToFireStorage(compressedImage, userCredential.user?.uid ?? '');
      }
      User user = User(
        firstName: firstName,
        lastName: lastName,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        phoneNumber: phoneNumber,
        profilePictureURL: profileImageUrl,
        userID: userCredential.user?.uid ?? '',
        role: USER_ROLE_CUSTOMER,
        active: true,
        lastOnlineTimestamp: Timestamp.now(),
        settings: UserSettings(),
        createdAt: Timestamp.now(),
        email: '',
      );
      String? errorMessage = await firebaseCreateNewUser(user, referralCode);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t create new user with phone number.';
      }
    }
  }

  static firebaseSignUpWithEmailAndPassword(String emailAddress, String password, File? image, String firstName, String lastName, String mobile, BuildContext context, String referralCode) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailAddress, password: password);
      String profilePicUrl = '';
      if (image != null) {
        File compressedImage = await FireStoreUtils.compressImage(image);
        final bytes = compressedImage.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        final mb = kb / 1024;

        if (mb > 2) {
          hideProgress();
          showAlertDialog(context, "error".tr(), "imageTooLarge".tr(), true);
          return;
        }
        updateProgress('Uploading image, Please wait...'.tr());
        profilePicUrl = await uploadUserImageToFireStorage(compressedImage, result.user?.uid ?? '');
      }
      User user = User(
          email: emailAddress,
          settings: UserSettings(),
          lastOnlineTimestamp: Timestamp.now(),
          active: true,
          phoneNumber: mobile,
          firstName: firstName,
          role: USER_ROLE_CUSTOMER,
          userID: result.user?.uid ?? '',
          lastName: lastName,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          createdAt: Timestamp.now(),
          profilePictureURL: profilePicUrl);
      String? errorMessage = await firebaseCreateNewUser(user, referralCode);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t sign up for firebase, Please try again.';
      }
    } on auth.FirebaseAuthException catch (error) {
      print(error.toString() + '${error.stackTrace}');
      String message = "notSignUp".tr();
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!';
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters';
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.';
          break;
      }
      return message;
    } catch (e) {
      return "notSignUp".tr();
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
        credential = auth.FacebookAuthProvider.credential(accessToken!.tokenString);
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

  Future<List> getVendorCusions(String id) async {
    List tagList = [];
    List prodtagList = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: id).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      if (document.data().containsKey("categoryID") && document.data()['categoryID'].toString().isNotEmpty) {
        prodtagList.add(document.data()['categoryID']);
      }
    });
    QuerySnapshot<Map<String, dynamic>> catQuery = await firestore.collection(VENDORS_CATEGORIES).where('publish', isEqualTo: true).get();
    await Future.forEach(catQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      Map<String, dynamic> catDoc = document.data();
      if (catDoc.containsKey("id") && catDoc['id'].toString().isNotEmpty && catDoc.containsKey("title") && catDoc['title'].toString().isNotEmpty && prodtagList.contains(catDoc['id'])) {
        tagList.add(catDoc['title']);
      }
    });

    return tagList;
  }

  getContactUs() async {
    Map<String, dynamic> contactData = {};
    await firestore.collection(Setting).doc(CONTACT_US).get().then((value) {
      contactData = value.data()!;
    });

    return contactData;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];

    await firestore.collection(tax).where('country', isEqualTo: country).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  static Future<List<GiftCardsModel>> getGiftCard() async {
    List<GiftCardsModel> giftCardModelList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(GIFT_CARDS).where("isEnable",isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        log(document.data().toString());
        giftCardModelList.add(GiftCardsModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.get Currency Parse error $e');
      }
    });
    return giftCardModelList;
  }
}
