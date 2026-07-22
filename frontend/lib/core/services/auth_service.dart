import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final String? role;
  final Map<String, dynamic>? data;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.role,
    this.data,
  });
}

class AuthService {
  // Token ko device pe save kar dena taake dobara login na karna pade
  static Future<void> _saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("role", role);
    debugPrint("✅ Token saved: $token");
    debugPrint("✅ Role saved: $role");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("role");
    debugPrint("🚪 Logged out — token & role removed");
  }

  // ---------------- REGISTER ----------------
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String role = "user", // "user" | "service_provider"
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phoneNumber": phoneNumber,
          "role": role,
        }),
      );

      final body = jsonDecode(response.body);

      // ✅ Register pe ab token/role nahi milta — sirf email verification
      // required hai, isliye success pe SIRF message + email milta hai
      if (response.statusCode == 201 && body["success"] == true) {
        return AuthResult(
          success: true,
          message: body["message"] ?? "Registration successful. Please verify your email.",
          data: body["data"], // { email: "..." }
        );
      }

      String errorMsg = body["message"] ?? "Registration failed";
      if (body["errors"] != null && body["errors"] is List && body["errors"].isNotEmpty) {
        errorMsg = body["errors"][0]["message"];
      }

      return AuthResult(success: false, message: errorMsg);
    } catch (e) {
      return AuthResult(success: false, message: "Network error: ${e.toString()}");
    }
  }

  // ---------------- LOGIN ----------------
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        final token = body["data"]["token"];
        final userRole = body["data"]["role"];
        await _saveToken(token, userRole);

        return AuthResult(
          success: true,
          message: body["message"] ?? "Login successful",
          token: token,
          role: userRole,
          data: body["data"],
        );
      }

      String errorMsg = body["message"] ?? "Login failed";
      if (body["errors"] != null && body["errors"] is List && body["errors"].isNotEmpty) {
        errorMsg = body["errors"][0]["message"];
      }

      return AuthResult(success: false, message: errorMsg);
    } catch (e) {
      return AuthResult(success: false, message: "Network error: ${e.toString()}");
    }
  }

  // ---------------- GET PROFILE (/me) ----------------
  static Future<AuthResult> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResult(success: false, message: "Not logged in");
      }

      final response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        return AuthResult(success: true, message: "OK", data: body["data"]);
      }

      return AuthResult(success: false, message: body["message"] ?? "Failed to load profile");
    } catch (e) {
      return AuthResult(success: false, message: "Network error: ${e.toString()}");
    }
  }
}