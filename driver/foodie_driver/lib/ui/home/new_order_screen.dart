import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/ui/home/HomeScreen.dart';
import 'package:geolocator/geolocator.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  @override
  void initState() {
    // TODO: implement initState
    getOrder();
    super.initState();
  }

  List<dynamic>? newOrder = [];
  List<dynamic>? activeOrder = [];
  User? _driverModel;
  bool isLoading = true;

  getOrder() {
    late Stream<User> driverStream = FireStoreUtils().getDriver(MyAppState.currentUser!.userID);
    driverStream.listen((event) {
      newOrder!.clear();
      activeOrder!.clear();
      _driverModel = event;
      _driverModel!.orderRequestData!.forEach((element) {
        newOrder!.add(element);
      });

      _driverModel!.inProgressOrderID!.forEach((element) {
        activeOrder!.add(element);
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                _driverModel!.walletAmount < double.parse(minimumDepositToRideAccept)
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("You have to minimum ${amountShow(amount: minimumDepositToRideAccept.toString())} wallet amount to receiving Order",
                                style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                          ),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            onTap: (value) {
                              setState(() {
                                selectedTabIndex = value;
                              });
                            },
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                            labelColor: Color(COLOR_PRIMARY),
                            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Color(COLOR_PRIMARY),
                            indicatorWeight: 1,
                            tabs: [
                              Tab(
                                text: "New Order",
                              ),
                              Tab(
                                text: "Active",
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              newOrder!.isEmpty
                                  ? Center(
                                      child: Text("New order not found"),
                                    )
                                  : ListView.builder(
                                      itemCount: newOrder!.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        String orderId = newOrder![index];
                                        return FutureBuilder<OrderModel?>(
                                          future: FireStoreUtils.getOrderBuOrderId(orderId),
                                          builder: (BuildContext context, AsyncSnapshot<OrderModel?> snapshot) {
                                            if (snapshot.hasError) {
                                              return Text("Something went wrong");
                                            }

                                            if (snapshot.connectionState == ConnectionState.done) {
                                              OrderModel orderModel = snapshot.data!;

                                              double distanceInMeters = Geolocator.distanceBetween(orderModel.vendor.latitude, orderModel.vendor.longitude,
                                                  orderModel.address.location!.latitude, orderModel.address.location!.longitude);
                                              double kilometer = distanceInMeters / 1000;

                                              return InkWell(
                                                onTap: () {
                                                  push(context, HomeScreen(orderModel: orderModel));
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff212121),
                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                        SizedBox(height: 5),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "Trip Distance".tr(),
                                                                style: TextStyle(color: Color(0xffADADAD), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                              ),
                                                            ),
                                                            Text(
                                                              // '0',
                                                              "${kilometer.toStringAsFixed(currencyModel!.decimal)} km",
                                                              style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "Delivery charge".tr(),
                                                                style: TextStyle(color: Color(0xffADADAD), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                              ),
                                                            ),
                                                            Text(
                                                              // '0',
                                                              "${amountShow(amount: orderModel.deliveryCharge.toString())}",
                                                              style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5),
                                                        Card(
                                                          color: Color(0xffFFFFFF),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/images/location3x.png',
                                                                  height: 55,
                                                                ),
                                                                SizedBox(width: 10),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 270,
                                                                      child: Text(
                                                                        "${orderModel.vendor.location} ",
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 22),
                                                                    SizedBox(
                                                                      width: 270,
                                                                      child: Text(
                                                                        "${orderModel.address.getFullAddress()}",
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: [
                                                            SizedBox(
                                                              height: MediaQuery.of(context).size.height / 20,
                                                              width: MediaQuery.of(context).size.width / 2.5,
                                                              child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                                  backgroundColor: Color(COLOR_PRIMARY),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(5),
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'Reject',
                                                                  style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                                                ),
                                                                onPressed: () async {
                                                                  showProgress(context, 'Rejecting order...'.tr(), false);
                                                                  try {
                                                                    await rejectOrder(orderModel);
                                                                    hideProgress();
                                                                    setState(() {});
                                                                  } catch (e) {
                                                                    hideProgress();
                                                                    print('HomeScreenState.showDriverBottomSheet $e');
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(context).size.height / 20,
                                                              width: MediaQuery.of(context).size.width / 2.5,
                                                              child: ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                                    backgroundColor: Color(COLOR_PRIMARY),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    'Accept'.tr(),
                                                                    style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                                                  ),
                                                                  onPressed: () async {
                                                                    showProgress(context, 'Accepting order...'.tr(), false);
                                                                    await acceptOrder(orderModel);
                                                                  }),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          },
                                        );
                                      },
                                    ),
                              activeOrder!.isEmpty
                                  ? Center(
                                      child: Text("Active order not found"),
                                    )
                                  : ListView.builder(
                                      itemCount: activeOrder!.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        String orderId = activeOrder![index];
                                        return FutureBuilder<OrderModel?>(
                                          future: FireStoreUtils.getOrderBuOrderId(orderId),
                                          builder: (BuildContext context, AsyncSnapshot<OrderModel?> snapshot) {
                                            if (snapshot.hasError) {
                                              return Text("Something went wrong");
                                            }

                                            if (snapshot.connectionState == ConnectionState.done) {
                                              OrderModel orderModel = snapshot.data!;
                                              print("ACTIVEORDER");
                                              print(orderModel.id);

                                              double distanceInMeters = Geolocator.distanceBetween(orderModel.vendor.latitude, orderModel.vendor.longitude,
                                                  orderModel.address.location!.latitude, orderModel.address.location!.longitude);
                                              double kilometer = distanceInMeters / 1000;

                                              return InkWell(
                                                onTap: () {
                                                  push(context, HomeScreen(orderModel: orderModel));
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff212121),
                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                        SizedBox(height: 5),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "Trip Distance".tr(),
                                                                style: TextStyle(color: Color(0xffADADAD), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                              ),
                                                            ),
                                                            Text(
                                                              // '0',
                                                              "${kilometer.toStringAsFixed(currencyModel!.decimal)} km",
                                                              style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "Delivery charge".tr(),
                                                                style: TextStyle(color: Color(0xffADADAD), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                              ),
                                                            ),
                                                            Text(
                                                              // '0',
                                                              "${amountShow(amount: orderModel.deliveryCharge.toString())}",
                                                              style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5),
                                                        Card(
                                                          color: Color(0xffFFFFFF),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/images/location3x.png',
                                                                  height: 55,
                                                                ),
                                                                SizedBox(width: 10),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 270,
                                                                      child: Text(
                                                                        "${orderModel.vendor.location} ",
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 22),
                                                                    SizedBox(
                                                                      width: 270,
                                                                      child: Text(
                                                                        "${orderModel.address.getFullAddress()}",
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          },
                                        );
                                      },
                                    ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  rejectOrder(OrderModel orderModel) async {
    if (orderModel.rejectedByDrivers == null) {
      orderModel.rejectedByDrivers = [];
    }
    orderModel.rejectedByDrivers!.add(MyAppState.currentUser!.userID);
    orderModel.status = ORDER_STATUS_DRIVER_REJECTED;
    await FireStoreUtils.updateOrder(orderModel);

    _driverModel!.orderRequestData!.remove(orderModel.id);
    await FireStoreUtils.updateCurrentUser(_driverModel!);
  }

  acceptOrder(OrderModel orderModel) async {
    _driverModel!.orderRequestData!.remove(orderModel.id);
    _driverModel!.inProgressOrderID!.add(orderModel.id);

    print(_driverModel!.orderRequestData);
    await FireStoreUtils.updateCurrentUser(_driverModel!);

    orderModel.status = ORDER_STATUS_DRIVER_ACCEPTED;
    orderModel.driverID = _driverModel!.userID;
    orderModel.driver = _driverModel!;

    await FireStoreUtils.updateOrder(orderModel);
    hideProgress();

    push(context, HomeScreen(orderModel: orderModel));

    await FireStoreUtils.sendFcmMessage(driverAccepted, orderModel.author.fcmToken);
    await FireStoreUtils.sendFcmMessage(driverAccepted, orderModel.vendor.fcmToken);
  }
}
