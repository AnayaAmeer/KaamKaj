class ApiConstants {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String me = "$baseUrl/auth/me";
  static const String providerDashboard = "$baseUrl/provider/dashboard";
  static const String adminUsers = "$baseUrl/admin/users";

  static String userById(String id) => "$baseUrl/admin/users/$id";
  static String userStatus(String id) => "$baseUrl/admin/users/$id/status";
  static String userRole(String id) => "$baseUrl/admin/users/$id/role";
   // ---------- Categories ----------
  static const String categories = "$baseUrl/categories";           // GET (public - customer)
  static const String addCategory = "$baseUrl/admin/categories";    // POST (admin)

  static String updateCategory(String id) => "$baseUrl/admin/categories/$id"; // PUT (admin)
  static String deleteCategory(String id) => "$baseUrl/admin/categories/$id"; // DELETE (admin)
}