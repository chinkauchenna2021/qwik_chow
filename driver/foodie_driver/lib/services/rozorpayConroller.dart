import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/model/createRazorPayOrderModel.dart';
import 'package:foodie_driver/model/razorpayKeyModel.dart';
import 'package:foodie_driver/userPrefrence.dart';
import 'package:http/http.dart' as http;

class RazorPayController {
  Future<CreateRazorPayOrderModel?> createOrderRazorPay({required int amount, bool isTopup = false}) async {
    final String orderId = isTopup ? UserPreference.getPaymentId() : UserPreference.getOrderId();
    RazorPayModel razorPayData = UserPreference.getRazorPayData();
    debugPrint(razorPayData.razorpayKey);
    debugPrint("we Enter In");
    final url = "${GlobalURL}payments/razorpay/createorder";
    debugPrint(orderId);
    final response = await http.post(
      Uri.parse(url),
      body: {
        "amount": (amount * 100).toString(),
        "receipt_id": orderId,
        "currency": currencyModel?.code,
        "razorpaykey": razorPayData.razorpayKey,
        "razorPaySecret": razorPayData.razorpaySecret,
        "isSandBoxEnabled": razorPayData.isSandboxEnabled.toString(),
      },
    );
    debugPrint(response.toString());

    if (response.statusCode == 500) {
      return null;
    } else {
      final data = jsonDecode(response.body);
      debugPrint(data.toString());

      return CreateRazorPayOrderModel.fromJson(data);
    }
  }
}
