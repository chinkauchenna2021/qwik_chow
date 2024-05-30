import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_driver/model/FlutterWaveSettingDataModel.dart';
import 'package:foodie_driver/model/MercadoPagoSettingsModel.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/PayFastSettingData.dart';
import 'package:foodie_driver/model/PayStackSettingsModel.dart';
import 'package:foodie_driver/model/StripePayFailedModel.dart';
import 'package:foodie_driver/model/createRazorPayOrderModel.dart';
import 'package:foodie_driver/model/getPaytmTxtToken.dart';
import 'package:foodie_driver/model/payStackURLModel.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_paypal_native/str_helper.dart';
import 'package:foodie_driver/model/paypalSettingData.dart';
import 'package:foodie_driver/model/paytmSettingData.dart';
import 'package:foodie_driver/model/razorpayKeyModel.dart';
import 'package:foodie_driver/model/stripeSettingData.dart';
import 'package:foodie_driver/model/withdrawHistoryModel.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/services/paystack_url_genrater.dart';
import 'package:foodie_driver/services/rozorpayConroller.dart';
import 'package:foodie_driver/ui/topup/TopUpScreen.dart';
import 'package:foodie_driver/ui/wallet/MercadoPagoScreen.dart';
import 'package:foodie_driver/ui/wallet/PayFastScreen.dart';
import 'package:foodie_driver/ui/wallet/payStackScreen.dart';
import 'package:foodie_driver/userPrefrence.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../main.dart';
import '../../model/User.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:flutterwave_standard/flutterwave.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? withdrawalHistoryQuery;
  Stream<QuerySnapshot>? dailyEarningQuery;
  Stream<QuerySnapshot>? monthlyEarningQuery;
  Stream<QuerySnapshot>? yearlyEarningQuery;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;
  Stream<QuerySnapshot>? topupHistoryQuery;
  String? selectedRadioTile;

  GlobalKey<FormState> _globalKey = GlobalKey();
  GlobalKey<FormState> _globalKeywithdraw = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String walletAmount = "0.0";

  TextEditingController _amountController = TextEditingController(text: 50.toString());
  TextEditingController _noteController = TextEditingController(text: '');

  Razorpay _razorPay = Razorpay();
  RazorPayModel? razorPayData;
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  PayFastSettingData? payFastSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;

  getData() async {
    try {
      userQuery = fireStore.collection(USERS).doc(userId).snapshots();
      print(userQuery!.isEmpty);
    } catch (e) {
      print(e);
    }

    /// withdrawal History
    withdrawalHistoryQuery = fireStore.collection(driverPayouts).where('driverID', isEqualTo: userId).orderBy('paidDate', descending: true).snapshots();

    DateTime nowDate = DateTime.now();

    ///earnings History
    dailyEarningQuery = fireStore
        .collection(ORDERS)
        .where('driverID', isEqualTo: driverId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(nowDate.year, nowDate.month, nowDate.day)))
        .orderBy('createdAt', descending: true)
        .snapshots();

    monthlyEarningQuery = fireStore
        .collection(ORDERS)
        .where('driverID', isEqualTo: driverId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
              nowDate.year,
              nowDate.month,
            )))
        .orderBy('createdAt', descending: true)
        .snapshots();

    yearlyEarningQuery = fireStore
        .collection(ORDERS)
        .where('driverID', isEqualTo: driverId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
              nowDate.year,
            )))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Map<String, dynamic>? paymentIntentData;

  showAlert(context, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
      duration: Duration(seconds: 8),
    ));
  }

  final userId = MyAppState.currentUser!.userID;

  final driverId = MyAppState.currentUser!.userID; //'8BBDG88lB4dqRaCcLIhdonuwQtU2';
  UserBankDetails? userBankDetail = MyAppState.currentUser!.userBankDetails;

  getPaymentSettingData() async {
    topupHistoryQuery = fireStore.collection(Wallet).where('user_id', isEqualTo: userId).orderBy('date', descending: true).snapshots();
    userQuery = fireStore.collection(USERS).doc(MyAppState.currentUser!.userID).snapshots();

    await UserPreference.getStripeData().then((value) async {
      stripeData = value;
      stripe1.Stripe.publishableKey = stripeData!.clientpublishableKey;
      stripe1.Stripe.merchantIdentifier = 'Foodie';
      await stripe1.Stripe.instance.applySettings();
    });

    razorPayData = await UserPreference.getRazorPayData();
    paytmSettingData = await UserPreference.getPaytmData();
    paypalSettingData = await UserPreference.getPayPalData();
    payStackSettingData = await UserPreference.getPayStackData();
    flutterWaveSettingData = await UserPreference.getFlutterWaveData();
    payFastSettingData = await UserPreference.getPayFastData();
    mercadoPagoSettingData = await UserPreference.getMercadoPago();
    initPayPal();
  }

  paymentCompleted({required String paymentMethod}) async {
    await FireStoreUtils.createPaymentId().then((value) async {
      final paymentID = value;
      await FireStoreUtils.topUpWalletAmount(paymentMethod: paymentMethod, amount: double.parse(_amountController.text), id: paymentID).then((value) {
        FireStoreUtils.updateWalletAmount(userId: userId,amount: double.parse(_amountController.text)).then((value) {
          FireStoreUtils.sendTopUpMail(paymentMethod: paymentMethod, amount: _amountController.text, tractionId: paymentID);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successful!!".tr() + "\n"),
            backgroundColor: Colors.green,
          ));
        });
      });
    });
  }


  @override
  void initState() {
    getData();
    getPaymentSettingData();
    selectedRadioTile = "Stripe";

    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    print(MyAppState.currentUser!.userID);
    // TODO: implement initState
    super.initState();
  }


  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  void initPayPal() async {
    //set debugMode for error logging
    FlutterPaypalNative.isDebugMode = paypalSettingData!.isLive == false ? true : false;
    //initiate payPal plugin
    await _flutterPaypalNativePlugin.init(
      //your app id !!! No Underscore!!! see readme.md for help
      returnUrl: "com.emart.customer://paypalpay",
      //client id from developer dashboard
      clientID: paypalSettingData!.paypalClient,
      //sandbox, staging, live etc
      payPalEnvironment: paypalSettingData!.isLive == true ? FPayPalEnvironment.live : FPayPalEnvironment.sandbox,
      //what currency do you plan to use? default is US dollars
      currencyCode: FPayPalCurrencyCode.usd,
      //action paynow?
      action: FPayPalUserAction.payNow,
    );

    //call backs for payment
    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          Navigator.pop(context);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment canceled".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        },
        onSuccess: (data) {
          Navigator.pop(context);
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          String visitor = data.cart?.shippingAddress?.firstName ?? 'Visitor';
          String address = data.cart?.shippingAddress?.line1 ?? 'Unknown Address';

          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successfully".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
          paymentCompleted(paymentMethod: "Paypal");
        },
        onError: (data) {
          Navigator.pop(context);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("error".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        },
        onShippingChange: (data) {
          //the user updated the shipping address
          Navigator.pop(context);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}"),
            backgroundColor: Colors.red,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), image: DecorationImage(fit: BoxFit.fitWidth, image: AssetImage("assets/images/earning_bg_@3x.png"))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            "Total Balance".tr(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 25.0),
                            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              stream: userQuery,
                              builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> asyncSnapshot) {
                                if (asyncSnapshot.hasError) {
                                  return Text(
                                    "error".tr(),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
                                  );
                                }
                                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                      child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 0.8,
                                            color: Colors.white,
                                            backgroundColor: Colors.transparent,
                                          )));
                                }
                                User userData = User.fromJson(asyncSnapshot.data!.data()!);
                                walletAmount = userData.walletAmount.toString();
                                return Text(
                                  "${amountShow(amount: userData.walletAmount.toString())}",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 35),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28.0, right: 15, left: 15),
                      child: buildTopUpButton(),
                    ),
                  ],
                ),
              ),
            ),
            tabController(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildButton(context, width: 0.44, title: 'WITHDRAW'.tr(), onPress: () {
              if (MyAppState.currentUser!.userBankDetails.accountNumber.isNotEmpty) {
                withdrawAmountBottomSheet(context);
              } else {
                final snackBar = SnackBar(
                  backgroundColor: Colors.red[400],
                  content: Text(
                    'Please add your Bank Details first'.tr(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }),
            buildTransButton(context, width: 0.44, title: 'WITHDRAWAL'.tr(), onPress: () {
              if (MyAppState.currentUser!.userBankDetails.accountNumber.isNotEmpty) {
                withdrawalHistoryBottomSheet(context);
              } else {
                final snackBar = SnackBar(
                  backgroundColor: Colors.red[400],
                  content: Text(
                    'Please add your Bank Details first'.tr(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget buildTopUpButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            topUpBalance();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
              child: Text(
                "TOPUP WALLET".tr(),
                style: TextStyle(color: Color(DARK_CARD_BG_COLOR), fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TopUpScreen()));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
              child: Text(
                "TOPUP HISTORY".tr(),
                style: TextStyle(color: Color(DARK_CARD_BG_COLOR), fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool stripe = true;

  bool razorPay = false;
  bool payTm = false;
  bool paypal = false;
  bool payStack = false;
  bool flutterWave = false;
  bool payFast = false;
  bool mercadoPago = false;

  topUpBalance() {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        enableDrag: true,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => Container(
              //height: size.height * 0.85,
              width: size.width,
              height: size.height * 0.95,
              child: Form(
                key: _globalKey,
                autovalidateMode: AutovalidateMode.always,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: "Topup Wallet".tr(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: RichText(
                              text: TextSpan(
                                text: "Add Topup Amount".tr(),
                                style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white54 : Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                        child: Card(
                          elevation: 2.0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
                            child: TextFormField(
                              controller: _amountController,
                              style: TextStyle(
                                color: Color(COLOR_PRIMARY),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              //initialValue:"50",
                              maxLines: 1,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "*required Field".tr();
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefix: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
                                  child: Text(
                                    currencyModel!.symbol.toString(),
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade900,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: RichText(
                              text: TextSpan(
                                text: "Select Payment Option".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: stripeData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: stripe ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: stripe ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Stripe",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = false;
                                  stripe = true;
                                  mercadoPago = false;
                                  payFast = false;
                                  payStack = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: stripe,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/stripe.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Stripe"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: payStackSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payStack ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payStack ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayStack",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = false;
                                  payStack = true;
                                  mercadoPago = false;
                                  stripe = false;
                                  payFast = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payStack,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/paystack.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayStack"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: flutterWaveSettingData != null && flutterWaveSettingData!.isEnable,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: flutterWave ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: flutterWave ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "FlutterWave",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = true;
                                  payStack = false;
                                  mercadoPago = false;
                                  payFast = false;
                                  stripe = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: flutterWave,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/flutterwave.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("FlutterWave"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: razorPayData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: razorPay ? 0 : 2,
                            child: RadioListTile(
                              //toggleable: true,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: razorPay ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "RazorPay",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  mercadoPago = false;
                                  flutterWave = false;
                                  stripe = false;
                                  razorPay = true;
                                  payTm = false;
                                  payFast = false;
                                  paypal = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: razorPay,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                        child: SizedBox(width: 80, height: 35, child: Image.asset("assets/images/razorpay_@3x.png")),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("RazorPay"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: payFastSettingData != null && payFastSettingData!.isEnable,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payFast ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payFast ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "payFast",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  payFast = true;
                                  stripe = false;
                                  mercadoPago = false;
                                  razorPay = false;
                                  payStack = false;
                                  flutterWave = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payFast,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/payfast.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Pay Fast"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: paytmSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payTm ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payTm ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayTm",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  stripe = false;
                                  flutterWave = false;
                                  payTm = true;
                                  mercadoPago = false;
                                  razorPay = false;
                                  paypal = false;
                                  payFast = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payTm,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                                              child: Image.asset(
                                                "assets/images/paytm_@3x.png",
                                              ),
                                            )),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Paytm"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: mercadoPagoSettingData != null && mercadoPagoSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: mercadoPago ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: mercadoPago ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "MercadoPago",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  mercadoPago = true;
                                  payFast = false;
                                  stripe = false;
                                  razorPay = false;
                                  payStack = false;
                                  flutterWave = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: mercadoPago,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/mercadopago.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Mercado Pago"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: paypalSettingData != null && paypalSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: paypal ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: paypal ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayPal",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  stripe = false;
                                  payTm = false;
                                  mercadoPago = false;
                                  flutterWave = false;
                                  razorPay = false;
                                  paypal = true;
                                  payFast = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: paypal,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                                              child: Image.asset("assets/images/paypal_@3x.png"),
                                            )),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayPal"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 22),
                        child: GestureDetector(
                          onTap: () async {
                            await FireStoreUtils.createPaymentId();

                            if (selectedRadioTile == "Stripe" && stripeData?.isEnabled == true) {
                              Navigator.pop(context);
                              showLoadingAlert();
                              stripeMakePayment(amount: _amountController.text);
                              //push(context, CardDetailsScreen(paymentMode: selectedRadioTile,),);
                            } else if (selectedRadioTile == "MercadoPago") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              mercadoPagoMakePayment();
                            } else if (selectedRadioTile == "payFast") {
                              showLoadingAlert();
                              PayStackURLGen.getPayHTML(payFastSettingData: payFastSettingData!, amount: _amountController.text).then((value) async {
                                bool isDone = await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PayFastScreen(
                                          htmlData: value,
                                          payFastSettingData: payFastSettingData!,
                                        )));
                                if (isDone) {
                                  Navigator.pop(context);
                                  paymentCompleted(paymentMethod: "payFast");
                                } else {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "Payment Unsuccessful!!".tr() + "\n",
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    duration: Duration(seconds: 6),
                                  ));
                                }
                              });
                            } else if (selectedRadioTile == "RazorPay") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              RazorPayController().createOrderRazorPay(isTopup: true, amount: int.parse(_amountController.text)).then((value) {
                                if (value != null) {
                                  CreateRazorPayOrderModel result = value;
                                  print("RAZORPAY");
                                  print(value);

                                  openCheckout(
                                    amount: _amountController.text,
                                    orderId: result.id,
                                  );
                                } else {
                                  Navigator.pop(context);
                                  showAlert(_globalKey.currentContext!, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
                                }
                              });
                            } else if (selectedRadioTile == "PayTm") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              getPaytmCheckSum(context, amount: double.parse(_amountController.text));
                            } else if (selectedRadioTile == "PayPal") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              paypalPaymentSheet();
                            } else if (selectedRadioTile == "PayStack") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              payStackPayment();
                            } else if (selectedRadioTile == "FlutterWave") {
                              _flutterWaveInitiatePayment(context);
                            }
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Color(COLOR_PRIMARY),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                                child: Text(
                              "CONTINUE".tr(),
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  ///FlutterWave Payment Method
  String? _ref;

  setRef() {
    Random numRef = Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      setState(() {
        _ref = "AndroidRef$year$refNumber";
      });
    } else if (Platform.isIOS) {
      setState(() {
        _ref = "IOSRef$year$refNumber";
      });
    }
  }

  _flutterWaveInitiatePayment(
    BuildContext context,
  ) async {
    final style = FlutterwaveStyle(
      appBarText: "Foodie Driver",
      buttonColor: Color(COLOR_PRIMARY),
      buttonTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      appBarColor: Color(COLOR_PRIMARY),
      dialogCancelTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      dialogContinueTextStyle: TextStyle(
        color: Color(COLOR_PRIMARY),
        fontSize: 18,
      ),
      mainTextStyle: TextStyle(color: Colors.black, fontSize: 19, letterSpacing: 2),
      dialogBackgroundColor: Colors.white,
      appBarTitleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    );
    final flutterwave = Flutterwave(
      amount: _amountController.text.toString().trim(),
      currency: currencyModel!.code,
      style: style,
      customer: Customer(name: MyAppState.currentUser!.firstName, phoneNumber: MyAppState.currentUser!.phoneNumber.trim(), email: MyAppState.currentUser!.email.trim()),
      context: context,
      publicKey: flutterWaveSettingData!.publicKey.trim(),
      paymentOptions: "card, payattitude",
      customization: Customization(title: "Foodies"),
      txRef: _ref!,
      redirectUrl: '${GlobalURL}success',
      isTestMode: flutterWaveSettingData!.isSandbox,
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response.toString().isNotEmpty) {
      if (response.success!) {
        paymentCompleted(paymentMethod: "FlutterWave");
      } else {
        this.showLoading(message: response.status!);
      }
      print("${response.toJson()}");
    } else {
      this.showLoading(message: "No Response!".tr(), txtColor: Colors.red);
    }
  }

  Future<void> showLoading({required String message, Color txtColor = Colors.black}) {
    return showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 30,
            child: Text(
              message,
              style: TextStyle(color: txtColor),
            ),
          ),
        );
      },
    );
  }

  ///PayStack Payment Method
  payStackPayment() async {
    await PayStackURLGen.payStackURLGen(
      amount: (double.parse(_amountController.text) * 100).toString(),
      currency: currencyModel!.code,
      secretKey: payStackSettingData!.secretKey,
    ).then((value) async {
      if (value != null) {
        PayStackUrlModel _payStackModel = value;

        bool isDone = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PayStackScreen(
                  secretKey: payStackSettingData!.secretKey,
                  callBackUrl: payStackSettingData!.callbackURL,
                  initialURl: _payStackModel.data.authorizationUrl,
                  amount: _amountController.text,
                  reference: _payStackModel.data.reference,
                )));
        Navigator.pop(_scaffoldKey.currentContext!);

        if (isDone) {
          paymentCompleted(paymentMethod: "PayStack");
        } else {
          hideProgress();
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  /// PayPal Payment Gateway
  paypalPaymentSheet() {
    //add 1 item to cart. Max is 4!
    if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
      _flutterPaypalNativePlugin.addPurchaseUnit(
        FPayPalPurchaseUnit(
          // random prices
          amount: double.parse(_amountController.text),

          ///please use your own algorithm for referenceId. Maybe ProductID?
          referenceId: FPayPalStrHelper.getRandomString(16),
        ),
      );
    }
    // initPayPal();
    _flutterPaypalNativePlugin.makeOrder(
      action: FPayPalUserAction.payNow,
    );
  }

  /// Stripe Payment Gateway
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      paymentIntentData = await createStripeIntent(
        amount,
      );
      if (paymentIntentData!.containsKey("error")) {
        Navigator.pop(context);
        showAlert(_scaffoldKey.currentContext, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
      } else {
        await stripe1.Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: const stripe1.PaymentSheetApplePay(
                merchantCountryCode: 'US',
              ),
              allowsDelayedPaymentMethods: false,
              googlePay: stripe1.PaymentSheetGooglePay(
                merchantCountryCode: 'US',
                testEnv: true,
                currencyCode: currencyModel!.code,
              ),
              style: ThemeMode.system,
              appearance: stripe1.PaymentSheetAppearance(
                colors: stripe1.PaymentSheetAppearanceColors(
                  primary: Color(COLOR_PRIMARY),
                ),
              ),
              merchantDisplayName: 'Emart',
            ))
            .then((value) {});
        setState(() {});
        displayStripePaymentSheet();
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayStripePaymentSheet() async {
    try {
      await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
        paymentCompleted(paymentMethod: "Stripe");
        Navigator.pop(context);
        paymentIntentData = null;
      });
    } on stripe1.StripeException catch (e) {
      Navigator.pop(context);
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("${lom.error.message}"),
              ));
    } catch (e) {
      print('$e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$e"),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.red,
      ));
    }
  }

  createStripeIntent(
    String amount,
  ) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currencyModel!.code,
        'payment_method_types[0]': 'card',
        // 'payment_method_types[1]': 'ideal',
        "description": "${MyAppState.currentUser?.userID} Wallet Topup",
        "shipping[name]": "${MyAppState.currentUser?.firstName} ${MyAppState.currentUser?.lastName}",
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'), body: body, headers: {
        'Authorization': 'Bearer ${stripeData?.stripeSecret}',
        //$_paymentIntentClientSecret',
        'Content-Type': 'application/x-www-form-urlencoded'
      });
      return jsonDecode(response.body);
    } catch (err) {
      print('error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  /// RazorPay Payment Gateway
  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': razorPayData!.razorpayKey,
      'amount': amount * 100,
      'name': 'Foodies',
      'order_id': orderId,
      "currency": currencyModel?.code,
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': MyAppState.currentUser!.phoneNumber,
        'email': MyAppState.currentUser!.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint('error'.tr() + ': $e');
    }
  }

  ///MercadoPago Payment Method

  mercadoPagoMakePayment() {
    makePreference().then((result) async {
      if (result.isNotEmpty) {
        var preferenceId = result['response']['id'];

        final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: result['response']['init_point'])));
        print(isDone);
        print(result.toString());
        print(preferenceId);

        if (isDone) {
          paymentCompleted(paymentMethod: "MercadoPago");
        } else {
          Navigator.pop(_scaffoldKey.currentContext!);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  Future<Map<String, dynamic>> makePreference() async {
    final mp = MP.fromAccessToken(mercadoPagoSettingData!.accessToken);
    var pref = {
      "items": [
        {"title": "Wallet TopUp", "quantity": 1, "unit_price": double.parse(_amountController.text)}
      ],
      "auto_return": "all",
      "back_urls": {"failure": "${GlobalURL}payment/failure", "pending": "${GlobalURL}payment/pending", "success": "${GlobalURL}payment/success"},
    };

    var result = await mp.createPreference(pref);
    return result;
  }

  /// Paytm Payment Gateway
  bool isStaging = true;
  String callbackUrl = "http://162.241.125.167/~foodie/payments/paytmpaymentcallback?ORDER_ID=";
  bool restrictAppInvoke = false;
  bool enableAssist = true;
  String result = "";

  getPaytmCheckSum(
    context, {
    required double amount,
  }) async {
    final String orderId = UserPreference.getPaymentId();
    String getChecksum = "${GlobalURL}payments/getpaytmchecksum";

    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey,
        });

    final data = jsonDecode(response.body);

    await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId).then((value) {
      initiatePayment(context, amount: amount, orderId: orderId).then((value) {
        GetPaymentTxtTokenModel result = value;
        String callback = "";
        if (paytmSettingData!.isSandboxEnabled) {
          callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        _startTransaction(
          context,
          txnTokenBy: result.body.txnToken,
          orderId: orderId,
          amount: amount,
        );
      });
    });
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(BuildContext context, {required double amount, required orderId}) async {
    String initiateURL = "${GlobalURL}payments/initiatepaytmpayment";
    String callback = "";
    if (paytmSettingData!.isSandboxEnabled) {
      callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(
        Uri.parse(
          initiateURL,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey.toString(),
          "amount": amount.toString(),
          "currency": currencyModel!.code,
          "callback_url": callback,
          "custId": MyAppState.currentUser!.userID,
          "issandbox": paytmSettingData!.isSandboxEnabled ? "1" : "2",
        });
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null || data["body"]["txnToken"].toString().isEmpty) {
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: "something went wrong, please contact admin.".tr(), colors: Colors.red);
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  Future<void> _startTransaction(
    context, {
    required String txnTokenBy,
    required orderId,
    required double amount,
  }) async {
    try {
      var response = AllInOneSdk.startTransaction(
        paytmSettingData!.paytmMID,
        orderId,
        amount.toString(),
        txnTokenBy,
        "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId",
        isStaging,
        true,
        enableAssist,
      );

      response.then((value) {
        if (value!["RESPMSG"] == "Txn Success") {
          paymentCompleted(paymentMethod: "Paytm");
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          Navigator.pop(_scaffoldKey.currentContext!);

          result = onError.message.toString() + " \n  " + onError.code.toString();
          showAlert(_scaffoldKey.currentContext!, response: onError.message.toString(), colors: Colors.red);
        } else {
          result = onError.toString();
          Navigator.pop(_scaffoldKey.currentContext!);
          showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
        }
      });
    } catch (err) {
      result = err.toString();
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
    }
  }

  Future verifyCheckSum({required String checkSum, required double amount, required orderId}) async {
    String getChecksum = "${GlobalURL}payments/validatechecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey,
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    return data['status'];
  }

  tabController() {
    return Expanded(
      child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: 40,
                  child: TabBar(
                    //indicator: BoxDecoration(color: const Color(COLOR_PRIMARY), borderRadius: BorderRadius.circular(2.0)),
                    indicatorColor: Color(COLOR_PRIMARY),
                    labelColor: Color(COLOR_PRIMARY),
                    automaticIndicatorColorAdjustment: true,
                    dragStartBehavior: DragStartBehavior.start,
                    unselectedLabelColor: isDarkMode(context) ? Colors.white70 : Colors.black54,
                    indicatorWeight: 1.5,
                    //indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                    enableFeedback: true,
                    //unselectedLabelColor: const Colors,
                    tabs: [
                      Tab(text: 'Daily'.tr()),
                      Tab(
                        text: 'Monthly'.tr(),
                      ),
                      Tab(
                        text: 'Yearly'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      showEarningsHistory(context, query: dailyEarningQuery),
                      showEarningsHistory(context, query: monthlyEarningQuery),
                      showEarningsHistory(context, query: yearlyEarningQuery),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget showEarningsHistory(BuildContext context, {required Stream<QuerySnapshot>? query}) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'.tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SizedBox(height: 35, width: 35, child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final earningData = OrderModel.fromJson(document.data() as Map<String, dynamic>);
              return buildEarningCard(
                orderModel: earningData,
              );
            }).toList(),
          );
        } else {
          return Center(
              child: Text(
            "No Transaction History".tr(),
            style: TextStyle(fontSize: 18),
          ));
        }
      },
    );
  }

  Widget buildEarningCard({required OrderModel orderModel}) {
    print("delv charge ${orderModel.deliveryCharge}");
    final size = MediaQuery.of(context).size;
    double amount = 0;
    if (orderModel.deliveryCharge != null && orderModel.deliveryCharge!.isNotEmpty) {
      amount += double.parse(orderModel.deliveryCharge!);
    }

    if (orderModel.tipValue != null && orderModel.tipValue!.isNotEmpty) {
      amount += double.parse(orderModel.tipValue!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
      child: Card(
        color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width * 0.52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${DateFormat('dd MMMM, yyyy, KK:mma').format(orderModel.createdAt.toDate()).toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Opacity(
                      opacity: 0.75,
                      child: Text(
                        orderModel.status,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: orderModel.status == "Order Completed" ? Colors.green : Colors.deepOrangeAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      " ${amountShow(amount: amount.toString())}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: orderModel.status == "Order Completed" ? Colors.green : Colors.deepOrangeAccent,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Icon(
                    //   Icons.arrow_forward_ios,
                    //   size: 15,
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentCompleted(paymentMethod: "RazorPay");
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Processing Via".tr() + "\n" + response.walletName!,
      ),
      backgroundColor: Colors.blue.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Failed!!".tr() + "\n" + jsonDecode(response.message!)['error']['description'],
      ),
      backgroundColor: Colors.red.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  Widget showWithdrawalHistory(BuildContext context, {required Stream<QuerySnapshot>? query}) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'.tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SizedBox(height: 35, width: 35, child: CircularProgressIndicator()));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
            "No Transaction History".tr(),
            style: TextStyle(fontSize: 18),
          ));
        } else {
          return ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final topUpData = WithdrawHistoryModel.fromJson(document.data() as Map<String, dynamic>);
              //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return buildTransactionCard(
                withdrawHistory: topUpData,
                date: topUpData.paidDate.toDate(),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget buildTransactionCard({
    required WithdrawHistoryModel withdrawHistory,
    required DateTime date,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
      child: GestureDetector(
        onTap: () => showWithdrawalModelSheet(context, withdrawHistory),
        child: Card(
          color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.green.withOpacity(0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(0xFF00B761)),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: SizedBox(
                          width: size.width * 0.52,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${DateFormat('MMM dd, yyyy, KK:mma').format(withdrawHistory.paidDate.toDate()).toUpperCase()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Opacity(
                                opacity: 0.75,
                                child: Text(
                                  withdrawHistory.paymentStatus,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: withdrawHistory.paymentStatus == "Success" ? Colors.green : Colors.deepOrangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              " ${amountShow(amount: withdrawHistory.amount.toString())}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: withdrawHistory.paymentStatus == "Success" ? Colors.green : Colors.deepOrangeAccent,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  withdrawAmountBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                      child: Text(
                        "Withdraw".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode(context) ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25),
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Color(COLOR_ACCENT), width: 4)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userBankDetail!.bankName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(COLOR_PRIMARY_DARK),
                                    ),
                                  ),
                                  Icon(
                                    Icons.account_balance,
                                    size: 40,
                                    color: Color(COLOR_ACCENT),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                userBankDetail!.accountNumber,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode(context) ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                userBankDetail!.holderName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context) ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userBankDetail!.otherDetails,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: isDarkMode(context) ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    userBankDetail!.branchName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isDarkMode(context) ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                          child: RichText(
                            text: TextSpan(
                              text: "Amount to Withdraw".tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode(context) ? Colors.white70 : Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Form(
                      key: _globalKeywithdraw,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
                          child: TextFormField(
                            controller: _amountController,
                            style: TextStyle(
                              color: Color(COLOR_PRIMARY_DARK),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            //initialValue:"50",
                            maxLines: 1,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "*required Field".tr();
                              } else {
                                if (double.parse(value) <= 0) {
                                  return "*Invalid Amount".tr();
                                } else if (double.parse(value) > double.parse(walletAmount)) {
                                  return "*withdraw is more then wallet balance".tr();
                                } else {
                                  return null;
                                }
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefix: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
                                child: Text(
                                  "${currencyModel!.symbol}",
                                  style: TextStyle(
                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              fillColor: Colors.grey[200],
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 1.50)),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: TextFormField(
                        controller: _noteController,
                        style: TextStyle(
                          color: Color(COLOR_PRIMARY_DARK),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        //initialValue:"50",
                        maxLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "*required Field".tr();
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Add note'.tr(),
                          fillColor: Colors.grey[200],
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 1.50)),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: buildButton(context, title: "WITHDRAW".tr(), onPress: () {
                        if (_globalKeywithdraw.currentState!.validate()) {
                          print("------->");
                          print(minimumAmountToWithdrawal);
                          print(_amountController.text);
                          if (double.parse(minimumAmountToWithdrawal) > double.parse(_amountController.text)) {
                            showAlertDialog(
                                context, "Failed!".tr(), 'Withdraw amount must be greater or equal to ${amountShow(amount: minimumAmountToWithdrawal)}'.tr(), true);
                          } else {
                            withdrawRequest();
                          }
                        }
                      }),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  withdrawRequest() {
    Navigator.pop(context);
    showLoadingAlert();
    FireStoreUtils.createPaymentId(collectionName: driverPayouts).then((value) {
      final paymentID = value;

      WithdrawHistoryModel withdrawHistory = WithdrawHistoryModel(
        amount: double.parse(_amountController.text),
        driverID: userId,
        paymentStatus: "Pending",
        paidDate: Timestamp.now(),
        id: paymentID.toString(),
        note: _noteController.text,
      );

      print(withdrawHistory.driverID);

      FireStoreUtils.withdrawWalletAmount(withdrawHistory: withdrawHistory).then((value) {
        FireStoreUtils.updateWalletAmount(userId: userId, amount: -double.parse(_amountController.text)).whenComplete(() {
          Navigator.pop(_scaffoldKey.currentContext!);
          FireStoreUtils.sendPayoutMail(amount:_amountController.text ,payoutrequestid: paymentID.toString() );
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successful!! \n".tr()),
            backgroundColor: Colors.green,
          ));
        });
      });
    });
  }

  withdrawalHistoryBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: size.height,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: showWithdrawalHistory(context, query: withdrawalHistoryQuery),
                  ),
                  Positioned(
                    top: 40,
                    left: 15,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  buildButton(context, {required String title, double width = 0.9, required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * width,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Color(0xFF00B761),
        height: 45,
        elevation: 0.0,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontSize: 19, color: Colors.white),
        ),
      ),
    );
  }

  buildTransButton(context, {required String title, double width = 0.9, required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * width,
      child: MaterialButton(
        shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xFF00B761), width: 1), borderRadius: BorderRadius.circular(6)),
        color: Colors.transparent,
        height: 45,
        elevation: 0.0,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontSize: 19, color: Color(0xFF00B761)),
        ),
      ),
    );
  }

  showLoadingAlert() {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              const Text('Please wait!!').tr(),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Please wait!! while completing Transaction'.tr(),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
