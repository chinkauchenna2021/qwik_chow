import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/model/AddressModel.dart';
import 'package:flutter_application_1/model/User.dart';
import 'package:flutter_application_1/services/helper.dart';
import 'package:flutter_application_1/ui/container/ContainerScreen.dart';
import 'package:flutter_application_1/widget/permission_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'deliveryAddressScreen/DeliveryAddressScreen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({Key? key}) : super(key: key);

  @override
  _LocationPermissionScreenState createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset("assets/images/location_screen.png"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 8),
            child: Text(
              "Find restaurant and food near you",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 22.0, fontWeight: FontWeight.bold),
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "By allowing location access, you can search for restaurants and foods near you and receive more accurate delivery.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(COLOR_PRIMARY),
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                child: Text(
                  "Use current location",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ).tr(),
                onPressed: () {
                  checkPermission(
                    () async {
                      await showProgress(context, "Please wait...".tr(), false);
                      AddressModel addressModel = AddressModel();
                      try {
                        await Geolocator.requestPermission();
                        Position newLocalData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                        await placemarkFromCoordinates(newLocalData.latitude, newLocalData.longitude).then((valuePlaceMaker) {
                          Placemark placeMark = valuePlaceMaker[0];

                          setState(() {
                            addressModel.location = UserLocation(latitude: newLocalData.latitude, longitude: newLocalData.longitude);
                            String currentLocation =
                                "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                            addressModel.locality = currentLocation;
                          });
                        });
                        setState(() {});

                        MyAppState.selectedPosotion = addressModel;
                        await hideProgress();
                        pushAndRemoveUntil(context, ContainerScreen(user: MyAppState.currentUser), false);
                      } catch (e) {
                        await placemarkFromCoordinates(19.228825, 72.854118).then((valuePlaceMaker) {
                          Placemark placeMark = valuePlaceMaker[0];
                          setState(() {
                            addressModel.location = UserLocation(latitude: 19.228825, longitude: 72.854118);
                            String currentLocation =
                                "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                            addressModel.locality = currentLocation;
                          });
                        });

                        MyAppState.selectedPosotion = addressModel;
                        await hideProgress();
                        pushAndRemoveUntil(context, ContainerScreen(user:  MyAppState.currentUser), false);
                      }
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(COLOR_PRIMARY),
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                child: Text(
                  "Set from map",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ).tr(),
                onPressed: () async {

                  checkPermission(
                        () async {
                      await showProgress(context, "Please wait...".tr(), false);
                      AddressModel addressModel = AddressModel();
                      try {
                        await Geolocator.requestPermission();
                        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                        await hideProgress();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlacePicker(
                              apiKey: GOOGLE_API_KEY,
                              onPlacePicked: (result) {
                                addressModel.locality = result.formattedAddress!.toString();
                                addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                log(result.toString());
                                MyAppState.selectedPosotion = addressModel;
                                setState(() {});
                                pushAndRemoveUntil(context, ContainerScreen(user:  MyAppState.currentUser), false);
                              },
                              initialPosition: LatLng(-33.8567844, 151.213108),
                              useCurrentLocation: true,
                              selectInitialPosition: true,
                              usePinPointingSearch: true,
                              usePlaceDetailSearch: true,
                              zoomGesturesEnabled: true,
                              zoomControlsEnabled: true,
                              resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                            ),
                          ),
                        );
                      } catch (e) {
                        await placemarkFromCoordinates(19.228825, 72.854118).then((valuePlaceMaker) {
                          Placemark placeMark = valuePlaceMaker[0];
                          setState(() {
                            addressModel.location = UserLocation(latitude: 19.228825, longitude: 72.854118);
                            String currentLocation =
                                "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                            addressModel.locality = currentLocation;
                          });
                        });

                        MyAppState.selectedPosotion = addressModel;
                        await hideProgress();
                        pushAndRemoveUntil(context, ContainerScreen(user:  MyAppState.currentUser), false);
                      }
                    },
                  );
                },
              ),
            ),
          ),
          MyAppState.currentUser != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: TextButton(
                      child: Text(
                        "Enter Manually location",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(COLOR_PRIMARY)),
                      ).tr(),
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeliveryAddressScreen())).then((value) {
                          if (value != null) {
                            AddressModel addressModel = value;
                            MyAppState.selectedPosotion = addressModel;
                            pushAndRemoveUntil(context, ContainerScreen(user: MyAppState.currentUser), false);
                          }
                        });
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.only(top: 12, bottom: 12),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                              color: Color(COLOR_PRIMARY),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  void checkPermission(Function() onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      SnackBar snack = SnackBar(
        content: const Text(
          'You have to allow location permission to use your location',
          style: TextStyle(color: Colors.white),
        ).tr(),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PermissionDialog();
        },
      );
    } else {
      onTap();
    }
  }
}
