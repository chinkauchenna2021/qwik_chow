import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/model/AddressModel.dart';

class User with ChangeNotifier {
  String email;
  String firstName;
  String lastName;
  UserSettings settings;
  String phoneNumber;
  bool active;
  Timestamp? lastOnlineTimestamp;
  Timestamp? createdAt;
  String userID;
  String profilePictureURL;
  String appIdentifier;
  String fcmToken;
  UserLocation location;
  List<AddressModel>? shippingAddress = [];
  String role;
  String carName;
  String carNumber;
  String carPictureURL;
  List<dynamic>? inProgressOrderID;
  String? vendorID;
  num? rotation;
  dynamic walletAmount;

  User(
      {this.email = '',
      this.userID = '',
      this.profilePictureURL = '',
      this.firstName = '',
      this.phoneNumber = '',
      this.lastName = '',
      this.active = true,
      this.walletAmount = 0.0,
      this.rotation,
      this.vendorID,
      lastOnlineTimestamp,
      settings,
      this.fcmToken = '',
      location,
      this.shippingAddress,
      this.role = USER_ROLE_DRIVER,
      this.carName = '',
      this.carNumber = '',
      this.carPictureURL = '',
      this.createdAt,
      this.inProgressOrderID})
      : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.appIdentifier = 'Flutter Uber Eats Consumer ${Platform.operatingSystem}',
        this.location = location ?? UserLocation();

  String fullName() {
    return ((email.isEmpty) && (phoneNumber.isEmpty)) ? 'Login to Manage' : '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    List<AddressModel>? shippingAddressList = [];
    if (parsedJson['shippingAddress'] != null) {
      shippingAddressList = <AddressModel>[];
      parsedJson['shippingAddress'].forEach((v) {
        shippingAddressList!.add(AddressModel.fromJson(v));
      });
    }

    return User(
        walletAmount: parsedJson['wallet_amount'] ?? 0.0,
        email: parsedJson['email'] ?? '',
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        active: parsedJson['active'] ?? true,
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
        settings: parsedJson.containsKey('settings') ? UserSettings.fromJson(parsedJson['settings']) : UserSettings(),
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        location: parsedJson.containsKey('location') ? UserLocation.fromJson(parsedJson['location']) : UserLocation(),
        shippingAddress: shippingAddressList,
        role: parsedJson['role'] ?? '',
        carName: parsedJson['carName'] ?? '',
        carNumber: parsedJson['carNumber'] ?? '',
        carPictureURL: parsedJson['carPictureURL'] ?? '',
        inProgressOrderID: parsedJson['inProgressOrderID'] ?? [],
        rotation: parsedJson['rotation'] ?? 0.0,
        createdAt: parsedJson['createdAt'],
        vendorID: parsedJson['vendorID'] ?? '');
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'wallet_amount': this.walletAmount,
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'role': this.role,
      'createdAt': this.createdAt,
      'shippingAddress': shippingAddress != null ? shippingAddress!.map((v) => v.toJson()).toList() : null,
    };
    if (this.role == USER_ROLE_DRIVER) {
      json.addAll({
        'role': this.role,
        'carName': this.carName,
        'carNumber': this.carNumber,
        'carPictureURL': this.carPictureURL,
        'rotation': rotation,
        'inProgressOrderID': inProgressOrderID,
      });
    }
    if (this.role == USER_ROLE_VENDOR) {
      json.addAll({
        'vendorID': this.vendorID,
      });
    }
    return json;
  }
}

class UserSettings {
  bool pushNewMessages;

  bool orderUpdates;

  bool newArrivals;

  bool promotions;

  UserSettings({this.pushNewMessages = true, this.orderUpdates = true, this.newArrivals = true, this.promotions = true});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserSettings(
      pushNewMessages: parsedJson['pushNewMessages'] ?? true,
      orderUpdates: parsedJson['orderUpdates'] ?? true,
      newArrivals: parsedJson['newArrivals'] ?? true,
      promotions: parsedJson['promotions'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNewMessages': this.pushNewMessages,
      'orderUpdates': this.orderUpdates,
      'newArrivals': this.newArrivals,
      'promotions': this.promotions,
    };
  }
}

class UserLocation {
  double latitude;
  double longitude;

  UserLocation({this.latitude = 0.01, this.longitude = 0.01});

  factory UserLocation.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserLocation(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
