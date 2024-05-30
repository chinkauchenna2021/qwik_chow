import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/CurrencyModel.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/ui/chat_screen/chat_screen.dart';
import 'package:foodie_driver/ui/home/pick_order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final OrderModel? orderModel;

  const HomeScreen({Key? key, required this.orderModel}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final fireStoreUtils = FireStoreUtils();

  GoogleMapController? _mapController;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;

  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<String, Marker> _markers = {};

  setIcons() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/location_black3x.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/location_orange3x.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/food_delivery.png")
        .then((value) {
      taxiIcon = value;
    });
  }

  updateDriverOrder() async {
    Timestamp startTimestamp = Timestamp.now();
    DateTime currentDate = startTimestamp.toDate();
    currentDate = currentDate.subtract(Duration(hours: 3));
    startTimestamp = Timestamp.fromDate(currentDate);

    List<OrderModel> orders = [];

    await FirebaseFirestore.instance
        .collection(ORDERS)
        .where('status', whereIn: [ORDER_STATUS_ACCEPTED, ORDER_STATUS_DRIVER_REJECTED])
        .where('createdAt', isGreaterThan: startTimestamp)
        .get()
        .then((value) async {
          await Future.forEach(value.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
            try {
              orders.add(OrderModel.fromJson(element.data()));
            } catch (e, s) {
              print('watchOrdersStatus parse error ${element.id}$e $s');
            }
          });
        });

    orders.forEach((element) {
      OrderModel orderModel = element;
      orderModel.triggerDelevery = Timestamp.now();
      FirebaseFirestore.instance.collection(ORDERS).doc(element.id).set(orderModel.toJson(), SetOptions(merge: true)).then((order) {
        print('Done.');
      });
    });
  }

  bool isLoading = true;

  @override
  void initState() {
    setIcons();
    getCurrencyData();
    getDriver();
    updateDriverOrder();
    super.initState();
  }

  getCurrencyData() async {
    await FireStoreUtils().getCurrency().then((value) {
      setState(() {
        if (value != null) {
          currencyModel = value;
        } else {
          currencyModel = CurrencyModel(id: "", code: "USD", decimal: 2, isactive: true, name: "US Dollar", symbol: "\$", symbolatright: false);
        }
      });
    });
    await FireStoreUtils.firestore.collection(Setting).doc("DriverNearBy").get().then((value) {
      setState(() {
        minimumDepositToRideAccept = value.data()!['minimumDepositToRideAccept'];
        driverLocationUpdate = value.data()!['driverLocationUpdate'];
        mapType = value.data()!['mapType'];
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  late Stream<OrderModel?> ordersFuture;
  OrderModel? currentOrder;

  late Stream<User> driverStream;
  User? _driverModel = User();

  getCurrentOrder() async {
    if (singleOrderReceive == true) {
      if (_driverModel!.inProgressOrderID != null && _driverModel!.inProgressOrderID!.isNotEmpty) {
        ordersFuture = FireStoreUtils().getOrderByID(_driverModel!.inProgressOrderID!.first.toString());
        ordersFuture.listen((event) {
          setState(() {
            currentOrder = event;
            if (mapType == "inappmap") {
              getDirections();
            } else {
              isShow = true;
            }
          });
        });
      } else if (_driverModel!.orderRequestData != null && _driverModel!.orderRequestData!.isNotEmpty) {
        ordersFuture = FireStoreUtils().getOrderByID(_driverModel!.orderRequestData!.first.toString());
        ordersFuture.listen((event) {
          setState(() {
            currentOrder = event;
            if (mapType == "inappmap") {
              getDirections();
            } else {
              isShow = true;
            }
          });
        });
      }
    } else {
      ordersFuture = FireStoreUtils().getOrderByID(widget.orderModel!.id);
      ordersFuture.listen((event) {
        setState(() {
          currentOrder = event;
          if (mapType == "inappmap") {
            getDirections();
          } else {
            isShow = true;
          }
        });
      });
    }
  }

  getDriver() {
    driverStream = FireStoreUtils().getDriver(MyAppState.currentUser!.userID);
    driverStream.listen((event) async {
      setState(() {
        _driverModel = event;
        MyAppState.currentUser = _driverModel;
      });
      log(_driverModel!.toJson().toString());
      if (mapType == "inappmap") {
        getDirections();
      } else {
        isShow = true;
      }
      getCurrentOrder();
    });
  }

  @override
  void dispose() {
    if (_mapController != null) {
      _mapController!.dispose();
    }
    FireStoreUtils().driverStreamSub.cancel();
    FireStoreUtils().ordersStreamController.close();
    FireStoreUtils().ordersStreamSub.cancel();

    super.dispose();
  }

  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    isDarkMode(context)
        ? _mapController?.setMapStyle('[{"featureType": "all","'
            'elementType": "'
            'geo'
            'met'
            'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]')
        : _mapController?.setMapStyle(null);

    return Scaffold(
      appBar: singleOrderReceive == true ? null : AppBar(),
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
                  child: mapType == "inappmap" || currentOrder == null
                      ? GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                            _mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(locationDataFinal!.latitude ?? 0.0, locationDataFinal!.longitude ?? 0.0),
                                  zoom: 16,
                                  bearing: double.parse(_driverModel!.rotation.toString()),
                                ),
                              ),
                            );
                            if (isDarkMode(context))
                              controller.setMapStyle('[{"featureType": "all","'
                                  'elementType": "'
                                  'geo'
                                  'met'
                                  'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');
                          },
                          myLocationEnabled: currentOrder != null && currentOrder!.status == ORDER_STATUS_DRIVER_PENDING ? false : true,
                          myLocationButtonEnabled: true,
                          mapType: MapType.normal,
                          zoomControlsEnabled: false,
                          polylines: Set<Polyline>.of(polyLines.values),
                          markers: _markers.values.toSet(),
                          initialCameraPosition: CameraPosition(
                            zoom: 15,
                            target: LatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Image.asset("assets/images/map_route.png"),
                            SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                  backgroundColor: Color(COLOR_PRIMARY),
                                ),
                                onPressed: () async {
                                  if (currentOrder != null) {
                                    if (currentOrder!.status != ORDER_STATUS_DRIVER_PENDING) {
                                      if (currentOrder!.status == ORDER_STATUS_SHIPPED) {
                                        FireStoreUtils.redirectMap(
                                            context: context,
                                            name: currentOrder!.vendor.title,
                                            latitude: currentOrder!.vendor.latitude,
                                            longLatitude: currentOrder!.vendor.longitude);
                                      } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
                                        FireStoreUtils.redirectMap(
                                            context: context,
                                            name: currentOrder!.author.firstName,
                                            latitude: currentOrder!.address.location!.latitude,
                                            longLatitude: currentOrder!.address.location!.longitude);
                                      }
                                    } else {
                                      FireStoreUtils.redirectMap(
                                          context: context,
                                          name: currentOrder!.author.firstName,
                                          latitude: currentOrder!.vendor.latitude,
                                          longLatitude: currentOrder!.vendor.longitude);
                                    }
                                  }
                                },
                                child: Text(
                                  "Direction",
                                  style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                ),
                              ),
                            )
                          ]),
                        ),
                ),
                currentOrder != null && currentOrder!.status != ORDER_STATUS_DRIVER_PENDING && isShow == true ? buildOrderActionsCard() : Container(),
                currentOrder != null && currentOrder!.status == ORDER_STATUS_DRIVER_PENDING ? showDriverBottomSheet() : Container()
              ],
            ),
      floatingActionButton: currentOrder == null
          ? Container()
          : mapType == "inappmap" &&
                  currentOrder!.status != ORDER_STATUS_DRIVER_PENDING &&
                  _driverModel!.inProgressOrderID != null &&
                  _driverModel!.inProgressOrderID!.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (isShow == true) {
                        isShow = false;
                      } else {
                        isShow = true;
                      }
                    });
                  },
                  child: Icon(
                    isShow ? Icons.close : Icons.remove_red_eye,
                    color: Colors.white,
                    size: 29,
                  ),
                  backgroundColor: Colors.black,
                  // backgroundColor: Color(COLOR_PRIMARY),
                  tooltip: 'Capture Picture',
                  elevation: 5,
                  splashColor: Colors.grey,
                )
              : null,
    );
  }

  openChatWithCustomer() async {
    await showProgress(context, "Please wait".tr(), false);

    User? customer = await FireStoreUtils.getCurrentUser(currentOrder!.authorID);
    User? driver = await FireStoreUtils.getCurrentUser(currentOrder!.driverID.toString());

    hideProgress();
    push(
        context,
        ChatScreens(
          customerName: customer!.firstName + " " + customer.lastName,
          restaurantName: driver!.firstName + " " + driver.lastName,
          orderId: currentOrder!.id,
          restaurantId: driver.userID,
          customerId: customer.userID,
          customerProfileImage: customer.profilePictureURL,
          restaurantProfileImage: driver.profilePictureURL,
          token: customer.fcmToken,
          chatType: 'Driver',
        ));
  }

  showDriverBottomSheet() {
    double distanceInMeters = Geolocator.distanceBetween(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude,
        currentOrder!.address.location!.latitude, currentOrder!.address.location!.longitude);
    double kilometer = distanceInMeters / 1000;
    return Padding(
      padding: EdgeInsets.all(10),
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
                  "${amountShow(amount: currentOrder!.deliveryCharge.toString())}",
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
                            "${currentOrder!.vendor.location} ",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                          ),
                        ),
                        SizedBox(height: 22),
                        SizedBox(
                          width: 270,
                          child: Text(
                            "${currentOrder!.address.getFullAddress()}",
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
            SizedBox(height: 10),
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
                      try {
                        showProgress(context, 'Rejecting order...'.tr(), false);
                        await rejectOrder();
                        hideProgress();
                      } catch (e) {
                        hideProgress();
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
                        await acceptOrder();
                        hideProgress();
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderActionsCard() {
    late String title;
    String? buttonText;
    if (currentOrder!.status == ORDER_STATUS_SHIPPED || currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED) {
      title = '${currentOrder!.vendor.title}';
      buttonText = 'REACHED RESTAURANT FOR PICKUP'.tr();
    } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
      title = 'Deliver to {}'.tr(args: ['${currentOrder!.author.firstName}']);
      // buttonText = 'Complete Pick Up'.tr();
      buttonText = 'REACHED CUSTOMER DOOR STEP'.tr();
    }

    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      padding: EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(18)),
        color: isDarkMode(context) ? Color(0xff000000) : Color(0xffFFFFFF),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentOrder!.status == ORDER_STATUS_SHIPPED || currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED)
              Column(
                children: [
                  ListTile(
                    title: Text(
                      title,
                      style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsm", letterSpacing: 0.5),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.vendor.location}',
                        maxLines: 2,
                        style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                      ),
                    ),
                    trailing: TextButton.icon(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(color: Color(0xff3DAE7D)),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(85, 30),
                          alignment: Alignment.center,
                          backgroundColor: Color(0xffFFFFFF),
                        ),
                        onPressed: () async {
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: currentOrder!.vendor.phonenumber,
                          );
                          await launchUrl(launchUri);
                        },
                        icon: Image.asset(
                          'assets/images/call3x.png',
                          height: 14,
                          width: 14,
                        ),
                        label: Text(
                          "CALL",
                          style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                        )),
                  ),
                  ListTile(
                    tileColor: Color(0xffF1F4F8),
                    contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    title: Row(
                      children: [
                        Text(
                          'ORDER ID '.tr(),
                          style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff555555), fontFamily: "Poppinsr", letterSpacing: 0.5),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            '${currentOrder!.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.author.fullName()}',
                        style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff333333), fontFamily: "Poppinsm", letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT)
              Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/images/user3x.png',
                      height: 42,
                      width: 42,
                      color: Color(COLOR_PRIMARY),
                    ),
                    title: Text(
                      '${currentOrder!.author.fullName()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsm", letterSpacing: 0.5),
                    ),
                    subtitle: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'ORDER ID '.tr(),
                            style: TextStyle(color: Color(0xff555555), fontFamily: "Poppinsr", letterSpacing: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Text(
                              '${currentOrder!.id} ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(85, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () async {
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: currentOrder!.author.phoneNumber,
                              );
                              await launchUrl(launchUri);
                            },
                            icon: Image.asset(
                              'assets/images/call3x.png',
                              height: 14,
                              width: 14,
                            ),
                            label: Text(
                              "CALL".tr(),
                              style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/delivery_location3x.png',
                      height: 42,
                      width: 42,
                      color: Color(COLOR_PRIMARY),
                    ),
                    title: Text(
                      'DELIVER'.tr(),
                      style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsr", letterSpacing: 0.5),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.address.getFullAddress()}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(100, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () => openChatWithCustomer(),
                            icon: Icon(
                              Icons.message,
                              size: 16,
                              color: Color(0xff3DAE7D),
                            ),
                            // Image.asset(
                            //   'assets/images/call3x.png',
                            //   height: 14,
                            //   width: 14,
                            // ),
                            label: Text(
                              "Message",
                              style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    backgroundColor: Color(COLOR_PRIMARY),
                  ),
                  onPressed: () async {
                    if (currentOrder!.status == ORDER_STATUS_SHIPPED || currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED) {
                      push(
                        context,
                        PickOrder(currentOrder: currentOrder),
                      );
                    } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
                      push(
                        context,
                        Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              icon: Icon(Icons.chevron_left),
                              onPressed: () => Navigator.pop(context),
                            ),
                            titleSpacing: -8,
                            title: Text(
                              "Deliver".tr() + ": ${currentOrder!.id}",
                              style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                            ),
                            centerTitle: false,
                          ),
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(color: Colors.grey.shade100, width: 0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 2.0,
                                          spreadRadius: 0.4,
                                          offset: Offset(0.2, 0.2),
                                        ),
                                      ],
                                      color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'DELIVER'.tr().toUpperCase(),
                                            style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                          ),
                                          TextButton.icon(
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6.0),
                                                  side: BorderSide(color: Color(0xff3DAE7D)),
                                                ),
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(85, 30),
                                                alignment: Alignment.center,
                                                backgroundColor: Color(0xffFFFFFF),
                                              ),
                                              onPressed: () async {
                                                final Uri launchUri = Uri(
                                                  scheme: 'tel',
                                                  path: currentOrder!.author.phoneNumber,
                                                );
                                                await launchUrl(launchUri);
                                              },
                                              icon: Image.asset(
                                                'assets/images/call3x.png',
                                                height: 14,
                                                width: 14,
                                              ),
                                              label: Text(
                                                "CALL".tr().toUpperCase(),
                                                style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                              )),
                                        ],
                                      ),
                                      Text(
                                        '${currentOrder!.author.fullName()}',
                                        style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          "${currentOrder!.address.getFullAddress()}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 28),
                                Text(
                                  "ITEMS".tr().toUpperCase(),
                                  style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                ),
                                SizedBox(height: 24),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: currentOrder!.products.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: CachedNetworkImage(
                                                    height: 55,
                                                    // width: 50,
                                                    imageUrl: '${currentOrder!.products[index].photo}',
                                                    imageBuilder: (context, imageProvider) => Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              image: DecorationImage(
                                                                image: imageProvider,
                                                                fit: BoxFit.cover,
                                                              )),
                                                        )),
                                              ),
                                              Expanded(
                                                flex: 10,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 14.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${currentOrder!.products[index].name}',
                                                        style: TextStyle(
                                                            fontFamily: 'Poppinsr',
                                                            letterSpacing: 0.5,
                                                            color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff333333)),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.close,
                                                            size: 15,
                                                            color: Color(COLOR_PRIMARY),
                                                          ),
                                                          Text('${currentOrder!.products[index].quantity}',
                                                              style: TextStyle(
                                                                fontFamily: 'Poppinsm',
                                                                letterSpacing: 0.5,
                                                                color: Color(COLOR_PRIMARY),
                                                              )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ));
                                      // Card(
                                      //   child: Text(widget.currentOrder!.products[index].name),
                                      // );
                                    }),
                                SizedBox(height: 28),
                                Container(
                                  decoration:
                                      BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Color(0xffC2C4CE)), color: Colors.white),
                                  child: ListTile(
                                    minLeadingWidth: 20,
                                    leading: Image.asset(
                                      'assets/images/mark_selected3x.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                    title: Text(
                                      "Given".tr() + " ${currentOrder!.products.length} " + "item to customer".tr(),
                                      style: TextStyle(color: Color(0xff3DAE7D), fontFamily: 'Poppinsm', letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 26),
                              ],
                            ),
                          ),
                          bottomNavigationBar: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 26),
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  backgroundColor: Color(0xff3DAE7D),
                                ),
                                child: Text(
                                  "MARK ORDER DELIVER".tr(),
                                  style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontFamily: 'Poppinsm',
                                  ),
                                ),
                                onPressed: () => completeOrder(),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    buttonText ?? "",
                    style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  acceptOrder() async {
    _driverModel!.orderRequestData!.remove(currentOrder!.id);
    _driverModel!.inProgressOrderID!.add(currentOrder!.id);

    await FireStoreUtils.updateCurrentUser(_driverModel!);

    currentOrder!.status = ORDER_STATUS_DRIVER_ACCEPTED;
    currentOrder!.driverID = _driverModel!.userID;
    currentOrder!.driver = _driverModel!;

    await FireStoreUtils.updateOrder(currentOrder!);

    await FireStoreUtils.sendFcmMessage(driverAccepted, currentOrder!.author.fcmToken);
    await FireStoreUtils.sendFcmMessage(driverAccepted, currentOrder!.vendor.fcmToken);
    setState(() {
      isShow = true;
    });
  }

  completeOrder() async {
    showProgress(context, 'Completing Delivery...'.tr(), false);
    currentOrder!.status = ORDER_STATUS_COMPLETED;
    updateWallateAmount(currentOrder!);
    await FireStoreUtils.updateOrder(currentOrder!);
    await FireStoreUtils.sendFcmMessage(driverCompleted, currentOrder!.author.fcmToken);
    await FireStoreUtils.getFirestOrderOrNOt(currentOrder!).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateReferralAmount(currentOrder!);
      }
    });

    Position? locationData = await getCurrentLocation();
    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(locationData.latitude, locationData.longitude), zoom: 20, bearing: double.parse(_driverModel!.rotation.toString())),
      ),
    );

    _driverModel!.inProgressOrderID!.remove(currentOrder!.id);
    await FireStoreUtils.updateCurrentUser(_driverModel!);
    hideProgress();
    _markers.clear();
    polyLines.clear();
    currentOrder = null;
    setState(() {});
    Navigator.pop(context);
    if (singleOrderReceive == false) {
      Navigator.pop(context);
    }
  }

  rejectOrder() async {
    if (currentOrder!.rejectedByDrivers == null) {
      currentOrder!.rejectedByDrivers = [];
    }

    currentOrder!.rejectedByDrivers!.add(_driverModel!.userID);
    currentOrder!.status = ORDER_STATUS_DRIVER_REJECTED;
    await FireStoreUtils.updateOrder(currentOrder!);

    _driverModel!.orderRequestData!.remove(currentOrder!.id);
    await FireStoreUtils.updateCurrentUser(_driverModel!);


    setState(() {
      currentOrder = null;
      _markers.clear();
      polyLines.clear();
    });
    if (singleOrderReceive == false) {
      Navigator.pop(context);
    }
  }

  getDirections() async {
    if (currentOrder != null) {
      if (currentOrder!.status != ORDER_STATUS_DRIVER_PENDING) {
        if (currentOrder!.status == ORDER_STATUS_SHIPPED) {
          List<LatLng> polylineCoordinates = [];

          PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            GOOGLE_API_KEY,
            PointLatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
            PointLatLng(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
            travelMode: TravelMode.driving,
          );
          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
          _markers.remove("Departure");
          _markers['Departure'] = Marker(
              markerId: const MarkerId('Departure'),
              infoWindow: const InfoWindow(title: "Departure"),
              position: LatLng(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
              icon: departureIcon!);

          _markers.remove("Destination");
          _markers['Destination'] = Marker(
              markerId: const MarkerId('Destination'),
              infoWindow: const InfoWindow(title: "Destination"),
              position: LatLng(currentOrder!.author.location.latitude, currentOrder!.author.location.longitude),
              icon: destinationIcon!);

          _markers.remove("Driver");
          _markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position: LatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
              icon: taxiIcon!,
              rotation: double.parse(_driverModel!.rotation.toString()));

          addPolyLine(polylineCoordinates);
        } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
          List<LatLng> polylineCoordinates = [];

          PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            GOOGLE_API_KEY,
            PointLatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
            PointLatLng(currentOrder!.address.location!.latitude, currentOrder!.address.location!.longitude),
            travelMode: TravelMode.driving,
          );

          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
          _markers.remove("Departure");
          _markers['Departure'] = Marker(
              markerId: const MarkerId('Departure'),
              infoWindow: const InfoWindow(title: "Departure"),
              position: LatLng(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
              icon: departureIcon!);

          _markers.remove("Destination");
          _markers['Destination'] = Marker(
              markerId: const MarkerId('Destination'),
              infoWindow: const InfoWindow(title: "Destination"),
              position: LatLng(currentOrder!.author.location.latitude, currentOrder!.author.location.longitude),
              icon: destinationIcon!);

          _markers.remove("Driver");
          _markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position: LatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
              icon: taxiIcon!,
              rotation: double.parse(_driverModel!.rotation.toString()));
          addPolyLine(polylineCoordinates);
        }
      } else {
        print("=====>${11}");

        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(currentOrder!.author.location.latitude, currentOrder!.author.location.longitude),
          PointLatLng(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
          travelMode: TravelMode.driving,
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }

        _markers.remove("Departure");
        _markers['Departure'] = Marker(
            markerId: const MarkerId('Departure'),
            infoWindow: const InfoWindow(title: "Departure"),
            position: LatLng(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
            icon: departureIcon!);

        _markers.remove("Destination");
        _markers['Destination'] = Marker(
            markerId: const MarkerId('Destination'),
            infoWindow: const InfoWindow(title: "Destination"),
            position: LatLng(currentOrder!.author.location.latitude, currentOrder!.author.location.longitude),
            icon: destinationIcon!);

        _markers.remove("Driver");
        _markers['Driver'] = Marker(
            markerId: const MarkerId('Driver'),
            infoWindow: const InfoWindow(title: "Driver"),
            position: LatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
            icon: taxiIcon!,
            rotation: double.parse(_driverModel!.rotation.toString()));
        addPolyLine(polylineCoordinates);
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color(COLOR_PRIMARY),
      points: polylineCoordinates,
      width: 8,
      geodesic: true,
    );
    setState(() {
      polyLines[id] = polyline;
    });
    updateCameraLocation(polylineCoordinates.first, _mapController);
  }

  Future<void> updateCameraLocation(
    LatLng source,
    GoogleMapController? mapController,
  ) async {
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: source,
          zoom: currentOrder == null || currentOrder!.status == ORDER_STATUS_DRIVER_PENDING ? 16 : 20,
          bearing: double.parse(_driverModel!.rotation.toString()),
        ),
      ),
    );
  }

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  playSound() async {
    final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 15,
        ctx: AudioContext(
            android: AudioContextAndroid(
                contentType: AndroidContentType.music,
                isSpeakerphoneOn: true,
                stayAwake: true,
                usageType: AndroidUsageType.alarm,
                audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: [])));
  }
}
