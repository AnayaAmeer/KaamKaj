import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/provider_profile_model.dart';
import 'auth_service.dart';


class ProviderProfileResult {
  final bool success;
  final String message;
  final dynamic data;

  ProviderProfileResult({
    required this.success,
    this.message = "",
    this.data,
  });
}


class ProviderProfileService {


  // ================= SUBMIT (create new) =================
  // Provider ab jitni chahe utni profiles bana sakta hai,
  // har call se ek nayi profile create hoti hai

  static Future<ProviderProfileResult> submitProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String experience,
    required String about,
    required String category,
    required List<ProviderServiceModel> services,
    required String availabilityStatus,
    File? image,
  }) async {

    try {

      final token = await AuthService.getToken();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiConstants.submitProviderProfile),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["name"] = name;
      request.fields["email"] = email;
      request.fields["phone"] = phone;
      request.fields["address"] = address;
      request.fields["experience"] = experience;
      request.fields["about"] = about;
      request.fields["category"] = category;
      request.fields["services"] = jsonEncode(
  services.map((e) => e.toJson()).toList(),
);
      request.fields["availabilityStatus"] = availabilityStatus;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);

      return ProviderProfileResult(
        success: response.statusCode == 201 && body["success"] == true,
        message: body["message"] ?? "",
        data: body["data"],
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }



  // ================= GET MY PROFILES (list) =================
  // Provider ki sari profiles (pending/approved/rejected sab)

  static Future<ProviderProfileResult> getMyProfiles() async {

    try {

      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse(ApiConstants.myProviderProfiles),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final list = (body["data"] as List)
            .map((e) => ProviderProfileModel.fromJson(e))
            .toList();

        return ProviderProfileResult(success: true, data: list);

      }

      return ProviderProfileResult(
        success: false,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }



  // ================= UPDATE (specific profile by id) =================

  static Future<ProviderProfileResult> updateProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String experience,
    required String about,
    required String category,
    required List<ProviderServiceModel> services,
    required String availabilityStatus,
    File? image,
  }) async {

    try {

      final token = await AuthService.getToken();

      final request = http.MultipartRequest(
        "PUT",
        Uri.parse(ApiConstants.updateProviderProfile(id)),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["name"] = name;
      request.fields["email"] = email;
      request.fields["phone"] = phone;
      request.fields["address"] = address;
      request.fields["experience"] = experience;
      request.fields["about"] = about;
      request.fields["category"] = category;
      request.fields["services"] = jsonEncode(
  services.map((e) => e.toJson()).toList(),
);
      request.fields["availabilityStatus"] = availabilityStatus;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);

      return ProviderProfileResult(
        success: response.statusCode == 200 && body["success"] == true,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }



  // ================= DELETE (specific profile by id) =================

  static Future<ProviderProfileResult> deleteProfile(String id) async {

    try {

      final token = await AuthService.getToken();

      final response = await http.delete(
        Uri.parse(ApiConstants.deleteProviderProfile(id)),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(response.body);

      return ProviderProfileResult(
        success: response.statusCode == 200,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }



  // ================= PUBLIC: GET PROVIDERS BY CATEGORY =================
  // Customer ke liye — sirf approved + published providers

  static Future<ProviderProfileResult> getProvidersByCategory(
    String categoryId,
  ) async {

    try {

      final response = await http.get(
        Uri.parse(ApiConstants.providersByCategory(categoryId)),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final list = (body["data"] as List)
            .map((e) => ProviderProfileModel.fromJson(e))
            .toList();

        return ProviderProfileResult(success: true, data: list);

      }

      return ProviderProfileResult(
        success: false,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }



  // ================= ADMIN: GET ALL =================

  static Future<ProviderProfileResult> getAllProfiles() async {

    try {

      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse(ApiConstants.adminProviderProfiles),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final list = (body["data"] as List)
            .map((e) => ProviderProfileModel.fromJson(e))
            .toList();

        return ProviderProfileResult(success: true, data: list);

      }

      return ProviderProfileResult(
        success: false,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }



  // ================= ADMIN: APPROVE / REJECT =================

  static Future<ProviderProfileResult> updateStatus(
    String id,
    String status,
  ) async {

    try {

      final token = await AuthService.getToken();

      final response = await http.put(
        Uri.parse(ApiConstants.updateProviderProfileStatus(id)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": status}),
      );

      final body = jsonDecode(response.body);

      return ProviderProfileResult(
        success: response.statusCode == 200,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }



  // ================= ADMIN: PUBLISH =================

  static Future<ProviderProfileResult> publishProfile(String id) async {

    try {

      final token = await AuthService.getToken();

      final response = await http.put(
        Uri.parse(ApiConstants.publishProviderProfile(id)),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(response.body);

      return ProviderProfileResult(
        success: response.statusCode == 200,
        message: body["message"] ?? "",
      );

    } catch (e) {
      return ProviderProfileResult(success: false, message: "Network error");
    }

  }
  static Future<ProviderProfileResult> adminUpdateProfile({
  required String id,
  required String name,
  required String email,
  required String phone,
  required String address,
  required String experience,
  required String about,
  required String category,
  required String availabilityStatus,
  required String status,
  required bool published,
  required double rating,
  File? image,
}) async {
  try {
    final token = await AuthService.getToken();

    final request = http.MultipartRequest(
      "PUT",
      Uri.parse(ApiConstants.adminUpdateProviderProfile(id)),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["name"] = name;
    request.fields["email"] = email;
    request.fields["phone"] = phone;
    request.fields["address"] = address;
    request.fields["experience"] = experience;
    request.fields["about"] = about;
    request.fields["category"] = category;
    request.fields["availabilityStatus"] = availabilityStatus;
    request.fields["status"] = status;
    request.fields["published"] = published.toString();
    request.fields["rating"] = rating.toString();

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", image.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body);

    return ProviderProfileResult(
      success: response.statusCode == 200,
      message: body["message"] ?? "",
      data: body["data"],
    );
  } catch (e) {
    return ProviderProfileResult(
      success: false,
      message: "Network error",
    );
  }
}
static Future<ProviderProfileResult> adminDeleteProfile(
  String id,
) async {
  try {
    final token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse(ApiConstants.adminDeleteProviderProfile(id)),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final body = jsonDecode(response.body);

    return ProviderProfileResult(
      success: response.statusCode == 200,
      message: body["message"] ?? "",
    );
  } catch (e) {
    return ProviderProfileResult(
      success: false,
      message: "Network error",
    );
  }
}


}