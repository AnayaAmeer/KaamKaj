import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/provider_dashboard_model.dart';
import 'auth_service.dart';

class DashboardResponse {
  final bool success;
  final String message;
  final ProviderDashboardModel? data;

  DashboardResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class ProviderDashboardService {
  static Future<DashboardResponse> getDashboard() async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return DashboardResponse(
          success: false,
          message: "User not logged in",
        );
      }

      final response = await http.get(
        Uri.parse(ApiConstants.providerDashboard),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        return DashboardResponse(
          success: true,
          message: body["message"] ?? "Success",
          data: ProviderDashboardModel.fromJson(body["data"]),
        );
      }

      return DashboardResponse(
        success: false,
        message: body["message"] ?? "Failed to load dashboard",
      );
    } catch (e) {
      return DashboardResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}