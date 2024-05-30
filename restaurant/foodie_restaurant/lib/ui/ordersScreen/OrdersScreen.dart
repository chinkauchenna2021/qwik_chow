import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/CurrencyModel.dart';
import 'package:foodie_restaurant/model/OrderModel.dart';
import 'package:foodie_restaurant/model/OrderProductModel.dart';
import 'package:foodie_restaurant/model/User.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/model/variant_info.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/services/pushnotification.dart';
import 'package:foodie_restaurant/ui/chat_screen/chat_screen.dart';
import 'package:foodie_restaurant/ui/ordersScreen/OrderDetailsScreen.dart';
import 'package:foodie_restaurant/ui/reviewScreen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  late Stream<List<OrderModel>> ordersStream;

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setCurrency();
    ordersStream = _fireStoreUtils.watchOrdersStatus(MyAppState.currentUser!.vendorID);
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
  }

  bool isLoading = true;

  setCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      if (value != null) {
        currencyModel = value;
      } else {
        currencyModel = CurrencyModel(id: "", code: "USD", decimal: 2, isactive: true, name: "US Dollar", symbol: "\$", symbolatright: false);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _fireStoreUtils.closeOrdersStream();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Color(0XFFFFFFFF),
        body: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : StreamBuilder<List<OrderModel>>(
                stream: ordersStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  print(snapshot.data!.length.toString() + "-----L");
                  if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                    return Center(
                      child: showEmptyState('No Orders'.tr(), 'New order requests will show up here'.tr()),
                    );
                  } else {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                        itemBuilder: (context, index) => InkWell(
                            onTap: () async {
                              await audioPlayer.stop();
                              push(
                                  context,
                                  OrderDetailsScreen(
                                    orderModel: snapshot.data![index],
                                  ));
                            },
                            child: buildOrderItem(snapshot.data![index], index, (index != 0) ? snapshot.data![index - 1] : null)));
                  }
                }));
  }

  Widget buildOrderItem(OrderModel orderModel, int index, OrderModel? prevModel) {
    double total = 0.0;
    double specialDiscount = 0.0;
    String taxAmount = "0.0";
    double discount = 0.0;

    if (orderModel.status == ORDER_STATUS_PLACED) {
      playSound();
    }
    orderModel.products.forEach((element) {
      try {
        if (element.extrasPrice!.isNotEmpty && double.parse(element.extrasPrice!) != 0.0) {
          total += element.quantity * double.parse(element.extrasPrice!);
        }
        total += element.quantity * double.parse(element.price);
        List addOnVal = [];
        if (element.extras == null) {
          addOnVal.clear();
        } else {
          if (element.extras is String) {
            if (element.extras == '[]') {
              addOnVal.clear();
            } else {
              String extraDecode = element.extras.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
              if (extraDecode.contains(",")) {
                addOnVal = extraDecode.split(",");
              } else {
                if (extraDecode.trim().isNotEmpty) {
                  addOnVal = [extraDecode];
                }
              }
            }
          }
          if (element.extras is List) {
            addOnVal = List.from(element.extras);
          }
        }
        for (int i = 0; i < addOnVal.length; i++) {}
      } catch (ex) {}
    });
    String date = DateFormat(' MMM d yyyy').format(DateTime.fromMillisecondsSinceEpoch(orderModel.createdAt.millisecondsSinceEpoch));
    String date2 = "";
    if (prevModel != null) {
      date2 = DateFormat(' MMM d yyyy').format(DateTime.fromMillisecondsSinceEpoch(prevModel.createdAt.millisecondsSinceEpoch));
    }

    discount = double.parse(orderModel.discount.toString());

    if (orderModel.specialDiscount != null || orderModel.specialDiscount!['special_discount'] != null) {
      specialDiscount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
    }

    if (orderModel.taxModel != null) {
      for (var element in orderModel.taxModel!) {
        taxAmount = (double.parse(taxAmount) + calculateTax(amount: (total - discount - specialDiscount).toString(), taxModel: element)).toString();
      }
    }

    var totalamount = total - orderModel.discount! - specialDiscount;

    double adminComm = (orderModel.adminCommissionType == 'Percent') ? (totalamount * double.parse(orderModel.adminCommission!)) / 100 : double.parse(orderModel.adminCommission!);

    print("cond1 ${(index == 0)} cond 2 ${(index != 0 && prevModel != null && date != date2)}");
    return Column(children: [
      Visibility(
        visible: index == 0 || (index != 0 && prevModel != null && date != date2),
        child: Wrap(children: [
          Container(
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.grey.shade300,
            ),
            alignment: Alignment.center,
            child: Text(
              '$date',
              style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, letterSpacing: 0.5, fontFamily: 'Poppinsm'),
            ),
          )
        ]),
      ),
      Card(
        elevation: 3,
        margin: EdgeInsets.only(bottom: 10, top: 10),
        color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // if you need this
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(bottom: 10.0, top: 5),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(children: [
                    Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(orderModel.products.first.photo),
                            fit: BoxFit.cover,
                            // colorFilter: ColorFilter.mode(
                            //     Colors.black.withOpacity(0.5), BlendMode.darken),
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Text(
                          orderModel.author.firstName + ' ' + orderModel.author.lastName,
                          style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Color(0XFF000000), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                        ),
                        orderModel.takeAway!
                            ? Text(
                                'Takeaway'.tr(),
                                style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF555353), letterSpacing: 0.5, fontFamily: 'Poppinsl'),
                              )
                            : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Icon(Icons.location_pin, size: 16, color: Colors.grey),
                                SizedBox(
                                  width: 2,
                                ),
                                Expanded(
                                  child: Text(
                                    'Deliver to: ${orderModel.address.getFullAddress()}'.tr(),
                                    maxLines: 3,
                                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF555353), fontFamily: 'Poppinsl'),
                                  ),
                                ),
                              ])
                      ]),
                    )
                  ])),
              // SizedBox(height: 10,),
              Divider(
                color: Color(0XFFD7DDE7),
              ),
              orderModel.status == ORDER_STATUS_ACCEPTED
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Estimated time to Prepare'.tr(),
                              style: TextStyle(fontSize: 14, color: Color(0XFF9091A4), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                            ),
                          ),
                          orderModel.estimatedTimeToPrepare == null
                              ? Text("00:00")
                              : Text(orderModel.estimatedTimeToPrepare.toString() + "${int.parse(orderModel.estimatedTimeToPrepare!.split(":").first) == int.parse("00") ? " mins." : " hr."}"),
                        ],
                      ),
                    )
                  : Container(),

              Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'ORDER LIST'.tr(),
                  style: TextStyle(fontSize: 14, color: Color(0XFF9091A4), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                ),
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderModel.products.length,
                  padding: EdgeInsets.only(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    OrderProductModel product = orderModel.products[index];
                    VariantInfo? variantIno = product.variantInfo;
                    List<dynamic>? addon = product.extras;
                    String extrasDisVal = '';
                    for (int i = 0; i < addon!.length; i++) {
                      extrasDisVal += '${addon[i].toString().replaceAll("\"", "")} ${(i == addon.length - 1) ? "" : ","}';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          minLeadingWidth: 10,
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          leading: CircleAvatar(
                            radius: 13,
                            backgroundColor: Color(COLOR_PRIMARY),
                            child: Text(
                              '${product.quantity}',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF333333), fontSize: 18, letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                          ),
                          trailing: Text(
                            amountShow(
                                amount: double.parse((product.extrasPrice!.isNotEmpty && double.parse(product.extrasPrice!) != 0.0)
                                        ? (double.parse(product.extrasPrice!) + double.parse(product.price)).toString()
                                        : product.price)
                                    .toString()),
                            style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF333333), fontSize: 17, letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                          ),
                        ),
                        variantIno == null || variantIno.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: List.generate(
                                    variantIno.variantOptions!.length,
                                    (i) {
                                      return _buildChip("${variantIno.variantOptions!.keys.elementAt(i)} : ${variantIno.variantOptions![variantIno.variantOptions!.keys.elementAt(i)]}", i);
                                    },
                                  ).toList(),
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 55, right: 10),
                          child: extrasDisVal.isEmpty
                              ? Container()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    extrasDisVal,
                                    style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppinsr'),
                                  ),
                                ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: Container()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.all(6),
                                  side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(2),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  push(
                                      context,
                                      ReviewScreen(
                                        product: product,
                                        orderId: orderModel.id,
                                      ));
                                },
                                child: Text(
                                  'View Rating'.tr(),
                                  style: TextStyle(letterSpacing: 0.5, color: isDarkMode(context) ? Colors.black : Color(COLOR_PRIMARY), fontFamily: 'Poppinsm'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: EdgeInsets.only(bottom: 8, top: 8, left: 10, right: 10),
                  color: isDarkMode(context) ? null : Color(0XFFF4F4F5),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      orderModel.scheduleTime != null
                          ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(
                                'Schedule Time'.tr(),
                                style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF333333), letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                              ),
                              Text(
                                '${DateFormat("EEE dd MMMM , HH:mm aa").format(orderModel.scheduleTime!.toDate())}',
                                style: TextStyle(color: Color(COLOR_PRIMARY), fontFamily: 'Poppinssm'),
                              ),
                            ])
                          : Container(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(
                          'Order Total'.tr(),
                          style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF333333), letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                        ),
                        Text(
                          amountShow(amount: total.toString()),
                          style: TextStyle(color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontFamily: 'Poppinssm'),
                        ),
                      ]),
                      SizedBox(
                        height: 5,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(
                          'Admin commission'.tr(),
                          style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF333333), letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                        ),
                        Text(
                          "(-${amountShow(amount: adminComm.toString())})",
                          style: TextStyle(color: Colors.red, letterSpacing: 0.5, fontFamily: 'Poppinssm'),
                        ),
                      ])
                    ],
                  )),
              orderModel.notes!.isEmpty
                  ? Container()
                  : SizedBox(
                      height: 10,
                    ),
              orderModel.notes!.isEmpty
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(bottom: 8, top: 8, left: 10, right: 10),
                      color: isDarkMode(context) ? null : Colors.white,
                      alignment: Alignment.centerLeft,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(
                          'Remark'.tr(),
                          style: TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0XFF333333), letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                        ),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                isDismissible: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                enableDrag: true,
                                builder: (BuildContext context) => viewNotesheet(orderModel.notes!));
                          },
                          child: Text(
                            "View".tr(),
                            style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                          ),
                        ),
                      ])),
              Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (orderModel.status == ORDER_STATUS_PLACED)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(8),
                              side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              await audioPlayer.stop();
                              if (orderModel.scheduleTime != null) {
                                if (orderModel.scheduleTime!.toDate().isBefore(Timestamp.now().toDate())) {
                                  print("ok");
                                  _displayTextInputDialog(context, orderModel);
                                } else {
                                  final snackBar = SnackBar(
                                    content: Text('You can accept order on ${DateFormat("EEE dd MMMM , HH:mm a").format(orderModel.scheduleTime!.toDate())}.').tr(),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              } else {
                                _displayTextInputDialog(context, orderModel);
                              }
                            },
                            child: Text(
                              'ACCEPT'.tr(),
                              style: TextStyle(letterSpacing: 0.5, color: isDarkMode(context) ? Colors.black : Color(COLOR_PRIMARY), fontFamily: 'Poppinsm'),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 20,
                      ),
                      if (orderModel.status == ORDER_STATUS_PLACED)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(8),
                              side: BorderSide(color: Color(0XFF63605F), width: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              audioPlayer.stop();
                              orderModel.status = ORDER_STATUS_REJECTED;
                              await FireStoreUtils.updateOrder(orderModel);

                              await FireStoreUtils.sendFcmMessage(restaurantRejected, orderModel.author.fcmToken);

                              if (orderModel.paymentMethod.toLowerCase() != 'cod') {
                                double finalAmount = (total + discount + specialDiscount + double.parse(taxAmount.toString()));
                                await FireStoreUtils.createPaymentId().then((value) {
                                  final paymentID = value;
                                  FireStoreUtils.topUpWalletAmount(paymentMethod: "Refund Amount".tr(), userId: orderModel.author.userID, amount: finalAmount, id: paymentID).then((value) {
                                    FireStoreUtils.updateWalletAmount(userId: orderModel.author.userID, amount: finalAmount).then((value) {});
                                  });
                                });
                              }
                              setState(() {});
                            },
                            child: Text(
                              'REJECT'.tr(),
                              style: TextStyle(letterSpacing: 0.5, color: Color(0XFF63605F), fontFamily: 'Poppinsm'),
                            ),
                          ),
                        ),
                      if (orderModel.status != ORDER_STATUS_PLACED && !orderModel.takeAway!)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              side: BorderSide(
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                            onPressed: () => null,
                            child: Text(
                              '${orderModel.status}'.tr(),
                              style: TextStyle(
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                          ),
                        ),
                      orderModel.status == ORDER_STATUS_ACCEPTED && orderModel.takeAway!
                          ? Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  orderModel.status = ORDER_STATUS_COMPLETED;
                                  FireStoreUtils.updateOrder(orderModel);
                                  // updateWallateAmount(orderModel);

                                  await FireStoreUtils.sendFcmMessage(takeawayCompleted, orderModel.author.fcmToken);
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    // height: 50,
                                    padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                                    // primary: Colors.white,

                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 0.8, color: Color(COLOR_PRIMARY))),
                                    child: Text(
                                      'Delivered'.tr().toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(COLOR_PRIMARY), fontFamily: "Poppinsm", fontSize: 15
                                          // fontWeight: FontWeight.bold,
                                          ),
                                    )),
                              ),
                            )
                          : orderModel.status == ORDER_STATUS_COMPLETED && orderModel.takeAway!
                              ? Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                    ),
                                    onPressed: () => null,
                                    child: Text(
                                      '${orderModel.status}'.tr(),
                                      style: TextStyle(
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                    ),
                                  ),
                                )
                              : orderModel.status == ORDER_STATUS_REJECTED && orderModel.takeAway!
                                  ? Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(6),
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                        onPressed: () => null,
                                        child: Text(
                                          '${orderModel.status}'.tr(),
                                          style: TextStyle(
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                      Visibility(
                          visible: orderModel.status == ORDER_STATUS_ACCEPTED ||
                              orderModel.status == ORDER_STATUS_SHIPPED ||
                              orderModel.status == ORDER_STATUS_DRIVER_PENDING ||
                              orderModel.status == ORDER_STATUS_DRIVER_REJECTED ||
                              orderModel.status == ORDER_STATUS_IN_TRANSIT ||
                              orderModel.status == ORDER_STATUS_SHIPPED,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: InkWell(
                              onTap: () async {
                                await showProgress(context, "Please wait".tr(), false);

                                User? customer = await FireStoreUtils.getCurrentUser(orderModel.authorID);
                                User? restaurantUser = await FireStoreUtils.getCurrentUser(orderModel.vendor.author);
                                VendorModel? vendorModel = await FireStoreUtils.getVendor(restaurantUser!.vendorID.toString());

                                hideProgress();
                                push(
                                    context,
                                    ChatScreens(
                                      customerName: '${customer!.firstName + " " + customer.lastName}',
                                      restaurantName: vendorModel!.title,
                                      orderId: orderModel.id,
                                      restaurantId: restaurantUser.userID,
                                      customerId: customer.userID,
                                      customerProfileImage: customer.profilePictureURL,
                                      restaurantProfileImage: vendorModel.photo,
                                      token: customer.fcmToken,
                                    ));
                              },
                              child: Image(
                                image: AssetImage("assets/images/user_chat.png"),
                                height: 30,
                                color: Color(COLOR_PRIMARY),
                                width: 30,
                              ),
                            ),
                          ))
                    ],
                  )),
            ],
          ),
        ),
      )
    ]);
  }

  viewNotesheet(String notes) {
    return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4.3, left: 25, right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(style: BorderStyle.none)),
        child: Column(children: [
          InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 45,
                decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.3), color: Colors.transparent, shape: BoxShape.circle),

                // radius: 20,
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              )),
          SizedBox(
            height: 25,
          ),
          Expanded(
              child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: isDarkMode(context) ? Color(COLOR_DARK) : Colors.white),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Remark'.tr(),
                        style: TextStyle(fontFamily: 'Poppinssb', color: isDarkMode(context) ? Colors.white60 : Colors.white, fontSize: 16),
                      )),
                  Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                      // height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: Container(
                              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                              color: isDarkMode(context) ? Color(0XFF2A2A2A) : Color(0XFFF1F4F7),
                              // height: 120,
                              alignment: Alignment.center,
                              child: Text(
                                notes,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDarkMode(context) ? Colors.white60 : Colors.black,
                                  fontFamily: 'Poppinsm',
                                ),
                              )))),
                ],
              ),
            ),
          )),
        ]));
  }

  buildDetails({required IconData iconsData, required String title, required String value}) {
    return ListTile(
      enabled: false,
      dense: true,
      contentPadding: EdgeInsets.only(left: 8),
      horizontalTitleGap: 0.0,
      visualDensity: VisualDensity.comfortable,
      leading: Icon(
        iconsData,
        color: isDarkMode(context) ? Colors.white : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black87),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black54),
      ),
    );
  }

  playSound() async {
    final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 15,
        ctx: AudioContext(
            android:
                AudioContextAndroid(contentType: AndroidContentType.music, isSpeakerphoneOn: true, stayAwake: true, usageType: AndroidUsageType.alarm, audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: [])));
  }

  final estimatedTime = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context, OrderModel orderModel) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Estimated time to Prepare'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: estimatedTime,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MaskedInputFormatter('##:##')],
                  decoration: InputDecoration(
                      hintText: "00:00",
                      contentPadding: EdgeInsets.symmetric(horizontal: 6),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.0),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.0),
                      ),
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: Color(COLOR_PRIMARY),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(8),
                          side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(2),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel'.tr(),
                          style: TextStyle(letterSpacing: 0.5, color: isDarkMode(context) ? Colors.black : Color(COLOR_PRIMARY), fontFamily: 'Poppinsm'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(8),
                          side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(2),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          print(estimatedTime.text);
                          if (estimatedTime.text.isNotEmpty) {
                            showProgress(context, 'Please wait...', false);

                            orderModel.estimatedTimeToPrepare = estimatedTime.text;
                            orderModel.status = ORDER_STATUS_ACCEPTED;
                            await FireStoreUtils.updateOrder(orderModel);
                            await FireStoreUtils().restaurantVendorWalletSet(orderModel);
                            await FireStoreUtils.sendFcmMessage(restaurantAccepted, orderModel.author.fcmToken);

                            hideProgress();
                            Navigator.pop(context);
                            setState(() {});
                          } else {
                            showAlertDialog(context, "Alert!".tr(), "", true);
                          }
                        },
                        child: Text(
                          'Shipped order'.tr(),
                          style: TextStyle(letterSpacing: 0.5, color: isDarkMode(context) ? Colors.black : Color(COLOR_PRIMARY), fontFamily: 'Poppinsm'),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}

Widget _buildChip(String label, int attributesOptionIndex) {
  return Container(
    decoration: BoxDecoration(color: const Color(0xffEEEDED), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}
