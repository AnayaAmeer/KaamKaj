import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:my_app/core/constants/api_constants.dart';
import 'package:my_app/core/models/order_model.dart';
import 'package:my_app/core/services/auth_service.dart';


class OrderResult {
  final bool success;
  final String message;
  final dynamic data;

  OrderResult({required this.success, this.message = "", this.data});
}


class OrderService {

  static Future<OrderResult> createOrder({
    required String providerProfileId,
    required String customerName,
    required String customerEmail,
    required String phone,
    required String address,
    required List<Map<String, dynamic>> services,
    required DateTime bookingDate,
    required String bookingTime,
  }) async {

    try {

      final token = await AuthService.getToken();

      final res = await http.post(
        Uri.parse(ApiConstants.createOrder),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "providerProfileId": providerProfileId,
          "customerName": customerName,
          "customerEmail": customerEmail,
          "phone": phone,
          "address": address,
          "services": services,
          "bookingDate": bookingDate.toIso8601String(),
          "bookingTime": bookingTime,
        }),
      );

      final body = jsonDecode(res.body);

      return OrderResult(
        success: res.statusCode == 201 && body["success"] == true,
        message: body["message"] ?? "",
        data: body["data"],
      );

    } catch (e) {
      return OrderResult(success: false, message: "Network Error");
    }

  }


  static Future<OrderResult> getMyOrders() async {

    try {

      final token = await AuthService.getToken();

      final res = await http.get(
        Uri.parse(ApiConstants.myOrders),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        final list = (body["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
        return OrderResult(success: true, data: list);
      }

      return OrderResult(success: false, message: body["message"] ?? "");

    } catch (e) {
      return OrderResult(success: false, message: "Network Error");
    }

  }


  static Future<OrderResult> getProviderOrders() async {

    try {

      final token = await AuthService.getToken();

      final res = await http.get(
        Uri.parse(ApiConstants.providerOrders),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        final list = (body["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
        return OrderResult(success: true, data: list);
      }

      return OrderResult(success: false, message: body["message"] ?? "");

    } catch (e) {
      return OrderResult(success: false, message: "Network Error");
    }

  }


  static Future<OrderResult> updateProviderOrderStatus(
    String id,
    String status,
  ) async {

    try {

      final token = await AuthService.getToken();

      final res = await http.put(
        Uri.parse(ApiConstants.updateProviderOrderStatus(id)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": status}),
      );

      final body = jsonDecode(res.body);

      return OrderResult(
        success: body["success"] == true,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return OrderResult(success: false, message: "Network Error");
    }

  }


  static Future<OrderResult> getAllOrdersAdmin() async {

    try {

      final token = await AuthService.getToken();

      final res = await http.get(
        Uri.parse(ApiConstants.adminOrders),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        final list = (body["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
        return OrderResult(success: true, data: list);
      }

      return OrderResult(success: false, message: body["message"] ?? "");

    } catch (e) {
      return OrderResult(success: false, message: "Network Error");
    }

  }


  static Future<OrderResult> createPaymentIntent(String orderId) async {

    try {

      final token = await AuthService.getToken();

      final res = await http.post(
        Uri.parse(ApiConstants.createPaymentIntent(orderId)),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(res.body);

      return OrderResult(
        success: body["success"] == true,
        message: body["message"] ?? "",
        data: body["clientSecret"],
      );

    } catch (e) {
      return OrderResult(success: false, message: "Network Error");
    }

  }


  static Future<OrderResult> confirmPayment(String orderId) async {

    try {

      final token = await AuthService.getToken();

      final res = await http.post(
        Uri.parse(ApiConstants.confirmPayment(orderId)),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(res.body);

      return OrderResult(
        success: body["success"] == true,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return OrderResult(success: false, message: "Network Error");
    }

  }

}