import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_app/core/constants/api_constants.dart';
import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/services/auth_service.dart'; // token nikalne ke liye

class CategoryResult {
  final bool success;
  final String message;
  final dynamic data;

  CategoryResult({required this.success, this.message = "", this.data});
}

class CategoryService {
  // Public - customer home screen
  static Future<CategoryResult> getCategories() async {
    try {
      final res = await http.get(Uri.parse(ApiConstants.categories));
      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        final list = (body["data"] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();
        return CategoryResult(success: true, data: list);
      }
      return CategoryResult(success: false, message: body["message"] ?? "Error aya");
    } catch (e) {
      return CategoryResult(success: false, message: "Network error");
    }
  }

  // Admin - add category
  static Future<CategoryResult> addCategory({
    required String name,
    required File imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();

      final request = http.MultipartRequest("POST", Uri.parse(ApiConstants.addCategory));
      request.headers["Authorization"] = "Bearer $token";
      request.fields["name"] = name;
      request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      final body = jsonDecode(res.body);

      if (res.statusCode == 201 && body["success"] == true) {
        return CategoryResult(success: true, data: CategoryModel.fromJson(body["data"]));
      }
      return CategoryResult(success: false, message: body["message"] ?? "not added");
    } catch (e) {
      return CategoryResult(success: false, message: "Network error");
    }
  }

  // Admin - update category
  static Future<CategoryResult> updateCategory({
    required String id,
    String? name,
    File? imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();

      final request = http.MultipartRequest("PUT", Uri.parse(ApiConstants.updateCategory(id)));
      request.headers["Authorization"] = "Bearer $token";
      if (name != null) request.fields["name"] = name;
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        return CategoryResult(success: true, data: CategoryModel.fromJson(body["data"]));
      }
      return CategoryResult(success: false, message: body["message"] ?? "not Updated");
    } catch (e) {
      return CategoryResult(success: false, message: "Network error");
    }
  }

  // Admin - delete category
  static Future<CategoryResult> deleteCategory(String id) async {
    try {
      final token = await AuthService.getToken();

      final res = await http.delete(
        Uri.parse(ApiConstants.deleteCategory(id)),
        headers: {"Authorization": "Bearer $token"},
      );
      final body = jsonDecode(res.body);

      return CategoryResult(
        success: res.statusCode == 200 && body["success"] == true,
        message: body["message"] ?? "",
      );
    } catch (e) {
      return CategoryResult(success: false, message: "Network error");
    }
  }
}