import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/core/constants/api_constants.dart';

class ForgotPasswordResult {
  final bool success;
  final String message;

  ForgotPasswordResult({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResult.fromResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return ForgotPasswordResult(
        success: body["success"] ?? false,
        message: body["message"] ?? "Something went wrong",
      );
    } catch (_) {
      return ForgotPasswordResult(
        success: false,
        message: "Server Error",
      );
    }
  }
}

class ForgotPasswordService {
  // Step 1: Send OTP to email
  static Future<ForgotPasswordResult> sendOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sendForgotPasswordOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      return ForgotPasswordResult.fromResponse(response);
    } catch (e) {
      return ForgotPasswordResult(
        success: false,
        message: "Network error. Please check your connection.",
      );
    }
  }

  // Step 2: Verify OTP
  static Future<ForgotPasswordResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyForgotPasswordOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      return ForgotPasswordResult.fromResponse(response);
    } catch (e) {
      return ForgotPasswordResult(
        success: false,
        message: "Network error. Please check your connection.",
      );
    }
  }

  // Step 3: Reset Password
  static Future<ForgotPasswordResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.resetForgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        }),
      );

      return ForgotPasswordResult.fromResponse(response);
    } catch (e) {
      return ForgotPasswordResult(
        success: false,
        message: "Network error. Please check your connection.",
      );
    }
  }
}