import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/core/constants/api_constants.dart';
import 'package:my_app/core/models/service_model.dart';
import 'package:my_app/core/services/auth_service.dart';

class ServiceResult {
  final bool success;
  final String message;
  final dynamic data;

  ServiceResult({
    required this.success,
    this.message = "",
    this.data,
  });
}

class ServiceService {
  // ==========================
  // Get All Services (Admin)
  // ==========================
  static Future<ServiceResult> getAllServices() async {
    try {
      final token = await AuthService.getToken();

      final res = await http.get(
        Uri.parse(ApiConstants.services),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        final list = (body["services"] as List)
            .map((e) => ServiceModel.fromJson(e))
            .toList();

        return ServiceResult(success: true, data: list);
      }

      return ServiceResult(
        success: false,
        message: body["message"] ?? "Error",
      );
    } catch (e) {
      return ServiceResult(
        success: false,
        message: "Network Error",
      );
    }
  }

  // ==========================
  // Add Service
  // ==========================
  static Future<ServiceResult> addService({
    required String categoryId,
    required String name,
    required String description,
  }) async {
    try {
      final token = await AuthService.getToken();

      final res = await http.post(
        Uri.parse(ApiConstants.addService),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "category": categoryId,
          "name": name,
          "description": description,
        }),
      );

      final body = jsonDecode(res.body);

      return ServiceResult(
        success: body["success"] == true,
        message: body["message"] ?? "",
        data: body["service"],
      );
    } catch (e) {
      return ServiceResult(
        success: false,
        message: "Network Error",
      );
    }
  }

  // ==========================
  // Update Service
  // ==========================
  static Future<ServiceResult> updateService({
    required String id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      final token = await AuthService.getToken();

      final res = await http.put(
        Uri.parse(ApiConstants.updateService(id)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "description": description,
          "isActive": isActive,
        }),
      );

      final body = jsonDecode(res.body);

      return ServiceResult(
        success: body["success"] == true,
        message: body["message"] ?? "",
      );
    } catch (e) {
      return ServiceResult(
        success: false,
        message: "Network Error",
      );
    }
  }

  // ==========================
  // Delete Service
  // ==========================
  static Future<ServiceResult> deleteService(
    String id,
  ) async {
    try {
      final token = await AuthService.getToken();

      final res = await http.delete(
        Uri.parse(ApiConstants.deleteService(id)),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(res.body);

      return ServiceResult(
        success: body["success"] == true,
        message: body["message"] ?? "",
      );
    } catch (e) {
      return ServiceResult(
        success: false,
        message: "Network Error",
      );
    }
  }

  // ==========================
  // Get Services By Category
  // ==========================
  static Future<ServiceResult> getServicesByCategory(
      String categoryId) async {
    try {
      final res = await http.get(
        Uri.parse(
          ApiConstants.servicesByCategory(categoryId),
        ),
      );

      final body = jsonDecode(res.body);

      if (body["success"] == true) {
        final list = (body["services"] as List)
            .map((e) => ServiceModel.fromJson(e))
            .toList();

        return ServiceResult(
          success: true,
          data: list,
        );
      }

      return ServiceResult(
        success: false,
        message: body["message"] ?? "",
      );
    } catch (e) {
      return ServiceResult(
        success: false,
        message: "Network Error",
      );
    }
  }
}