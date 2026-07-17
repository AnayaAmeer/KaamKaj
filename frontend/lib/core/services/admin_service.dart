import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      role: json["role"] ?? "user",
      isActive: json["isActive"] ?? true,
    );
  }
}

class AdminResult {
  final bool success;
  final String message;
  final List<AdminUser>? users;

  AdminResult({required this.success, required this.message, this.users});
}

class AdminService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ---------------- GET ALL USERS ----------------
  static Future<AdminResult> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.adminUsers),
        headers: await _authHeaders(),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        final List<dynamic> rawUsers = body["data"];
        final users = rawUsers.map((u) => AdminUser.fromJson(u)).toList();
        return AdminResult(success: true, message: "OK", users: users);
      }

      return AdminResult(success: false, message: body["message"] ?? "Failed to load users");
    } catch (e) {
      return AdminResult(success: false, message: "Network error: ${e.toString()}");
    }
  }

  // ---------------- CREATE USER ----------------
  static Future<AdminResult> createUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.adminUsers),
        headers: await _authHeaders(),
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phoneNumber": phoneNumber,
          "role": role,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body["success"] == true) {
        return AdminResult(success: true, message: body["message"]);
      }

      return AdminResult(success: false, message: body["message"] ?? "Failed to create user");
    } catch (e) {
      return AdminResult(success: false, message: "Network error: ${e.toString()}");
    }
  }

  // ---------------- UPDATE USER (name, email, phone, role) ----------------
  static Future<AdminResult> updateUser({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.userById(userId)),
        headers: await _authHeaders(),
        body: jsonEncode({
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
          "role": role,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        return AdminResult(success: true, message: body["message"]);
      }

      return AdminResult(success: false, message: body["message"] ?? "Failed to update user");
    } catch (e) {
      return AdminResult(success: false, message: "Network error: ${e.toString()}");
    }
  }

  // ---------------- TOGGLE STATUS ----------------
  static Future<AdminResult> toggleStatus(String userId) async {
    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.userStatus(userId)),
        headers: await _authHeaders(),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        return AdminResult(success: true, message: body["message"]);
      }

      return AdminResult(success: false, message: body["message"] ?? "Failed to update status");
    } catch (e) {
      return AdminResult(success: false, message: "Network error: ${e.toString()}");
    }
  }

  // ---------------- DELETE USER ----------------
  static Future<AdminResult> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.userById(userId)),
        headers: await _authHeaders(),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        return AdminResult(success: true, message: body["message"]);
      }

      return AdminResult(success: false, message: body["message"] ?? "Failed to delete user");
    } catch (e) {
      return AdminResult(success: false, message: "Network error: ${e.toString()}");
    }
  }
}