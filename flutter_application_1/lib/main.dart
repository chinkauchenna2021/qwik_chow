import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/model/AddressModel.dart';
import 'package:flutter_application_1/model/CurrencyModel.dart';
import 'package:flutter_application_1/model/mail_setting.dart';
import 'package:flutter_application_1/services/FirebaseHelper.dart';
import 'package:flutter_application_1/services/helper.dart';
import 'package:flutter_application_1/services/localDatabase.dart';
import 'package:flutter_application_1/ui/auth/AuthScreen.dart';
import 'package:flutter_application_1/ui/container/ContainerScreen.dart';
import 'package:flutter_application_1/ui/location_permission_screen.dart';
import 'package:flutter_application_1/ui/onBoarding/OnBoardingScreen.dart';
import 'package:flutter_application_1/userPrefrence.dart';
import 'package:flutter_application_1/utils/DarkThemeProvider.dart';
import 'package:flutter_application_1/utils/Styles.dart';
import 'package:flutter_application_1/utils/notification_service.dart';
import 'package:flutter_application_1/widget/permission_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/User.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await EasyLocalization.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await UserPreference.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<CartDatabase>(
          create: (_) => CartDatabase(),
        )
      ],
      child: EasyLocalization(
          supportedLocales: [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: Locale('en'),
          saveLocale: true,
          useOnlyLangCode: true,
          useFallbackTranslations: true,
          child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static User? currentUser;
  static AddressModel selectedPosotion = AddressModel();

  // Define an async function to initialize FlutterFire
  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");
      if (currentUser != null) {
        await FireStoreUtils.getCurrentUser(currentUser!.userID).then((value) {
          if (value != null) {
            currentUser = value;
            currentUser!.fcmToken = token;
            FireStoreUtils.updateCurrentUser(currentUser!);
          }
        });
      }
    });
  }

  void initializeFlutterFire() async {
    try {
      await FirebaseFirestore.instance.collection(Setting).doc("globalSettings").get().then((dineinresult) {
        if (dineinresult.exists && dineinresult.data() != null && dineinresult.data()!.containsKey("website_color")) {
          COLOR_PRIMARY = int.parse(dineinresult.data()!["website_color"].replaceFirst("#", "0xff"));
        }
      });

      await FirebaseFirestore.instance.collection(Setting).doc("DineinForRestaurant").get().then((dineinresult) {
        if (dineinresult.exists) {
          isDineInEnable = dineinresult.data()!["isEnabledForCustomer"];
        }
      });

      await FirebaseFirestore.instance.collection(Setting).doc("emailSetting").get().then((value) {
        if (value.exists) {
          mailSettings = MailSettings.fromJson(value.data()!);
        }
      });

      await FirebaseFirestore.instance.collection(Setting).doc("home_page_theme").get().then((value) {
        if (value.exists) {
          homePageThem = value.data()!["theme"];
        }
      });

      await FirebaseFirestore.instance.collection(Setting).doc("Version").get().then((value) {
        debugPrint(value.data().toString());
        appVersion = value.data()!['app_version'].toString();
      });

      await FirebaseFirestore.instance.collection(Setting).doc("googleMapKey").get().then((value) {
        print(value.data());
        GOOGLE_API_KEY = value.data()!['key'].toString();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(themeChangeProvider.darkTheme, context),
              home: OnBoarding());
        },
      ),
    );
  }

  @override
  void initState() {
    notificationInit();
    initializeFlutterFire();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  late Future<List<CurrencyModel>> futureCurrency;

  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        if (user != null) {
          if (user.role == USER_ROLE_CUSTOMER) {
            if (user.active) {
              user.active = true;
              user.role = USER_ROLE_CUSTOMER;
              user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
              await FireStoreUtils.updateCurrentUser(user);
              MyAppState.currentUser = user;
              if(MyAppState.currentUser!.shippingAddress != null && MyAppState.currentUser!.shippingAddress!.isNotEmpty){
                if(MyAppState.currentUser!.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty){
                  MyAppState.selectedPosotion = MyAppState.currentUser!.shippingAddress!.where((element) => element.isDefault == true).single;
                }else{
                  MyAppState.selectedPosotion = MyAppState.currentUser!.shippingAddress!.first;
                }
                pushReplacement(context, ContainerScreen(user: user));
              }else{
                pushAndRemoveUntil(context, LocationPermissionScreen(), false);
              }
            } else {
              user.lastOnlineTimestamp = Timestamp.now();
              user.fcmToken = "";
              await FireStoreUtils.updateCurrentUser(user);
              await auth.FirebaseAuth.instance.signOut();
              MyAppState.currentUser = null;
              Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
              pushAndRemoveUntil(context, AuthScreen(), false);
            }
          } else {
            pushReplacement(context, AuthScreen());
          }
        } else {
          pushReplacement(context, AuthScreen());
        }
      } else {
        pushReplacement(context, AuthScreen());
      }
    } else {
      pushReplacement(context, OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
    // futureCurrency= FireStoreUtils().getCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        ),
      ),
    );
  }
}
