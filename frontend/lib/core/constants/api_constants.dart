class ApiConstants {
  static const String baseUrl = "http://192.168.1.10:5000/api";

  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String me = "$baseUrl/auth/me";
//   static const String providerDashboard = "$baseUrl/provider/dashboard";
  static const String adminUsers = "$baseUrl/admin/users";

  static String userById(String id) => "$baseUrl/admin/users/$id";
  static String userStatus(String id) => "$baseUrl/admin/users/$id/status";
  static String userRole(String id) => "$baseUrl/admin/users/$id/role";

  // Categories
  static const String categories = "$baseUrl/categories";
  static const String addCategory = "$baseUrl/categories";

  static String updateCategory(String id) =>
      "$baseUrl/categories/$id";

  static String deleteCategory(String id) =>
      "$baseUrl/categories/$id";
  // ================= Provider Application =================
 
// Customer apply
static const String applyProvider =
    "$baseUrl/provider-applications/apply";
 
 
// Admin get applications
static const String adminProviderApplications =
    "$baseUrl/provider-applications/admin";
 
 
// Admin update status
static String updateProviderApplicationStatus(String id) =>
    "$baseUrl/provider-applications/admin/$id/status";
 
 
// Admin delete application
static String deleteProviderApplication(String id) =>
    "$baseUrl/provider-applications/admin/$id";

// ================= Provider Profile =================

static const String providerProfileBase =
    "$baseUrl/provider-profile";

// Provider
static const String submitProviderProfile = providerProfileBase;

// Customer browsing — sirf approved + published providers,
// category ke hisaab se
static String providersByCategory(String categoryId) =>
    "$providerProfileBase/category/$categoryId";

// Ab provider ki sari profiles ki list aati hai (multi-profile)
static const String myProviderProfiles = "$providerProfileBase/me";

// Specific profile update/delete (id se)
static String updateProviderProfile(String id) =>
    "$providerProfileBase/$id";

static String deleteProviderProfile(String id) =>
    "$providerProfileBase/$id";

// Admin
static const String adminProviderProfiles =
    "$providerProfileBase/admin";

static String updateProviderProfileStatus(String id) =>
    "$providerProfileBase/admin/$id/status";

static String publishProviderProfile(String id) =>
    "$providerProfileBase/admin/$id/publish";

// NEW
static String adminUpdateProviderProfile(String id) =>
    "$providerProfileBase/admin/provider-profile/$id";

static String adminDeleteProviderProfile(String id) =>
    "$providerProfileBase/admin/provider-profile/$id";
// ================= Services =================

static const String services = "$baseUrl/services";

static const String addService = services;

static String updateService(String id) =>
    "$services/$id";

static String deleteService(String id) =>
    "$services/$id";

static String servicesByCategory(String categoryId) =>
    "$services/category/$categoryId";
// ================= Orders =================

static const String orders = "$baseUrl/orders";
static const String createOrder = orders;
static const String myOrders = "$orders/me";

static String createPaymentIntent(String id) => "$orders/$id/payment-intent";
static String confirmPayment(String id) => "$orders/$id/confirm-payment";

static const String providerOrders = "$orders/provider";
static String updateProviderOrderStatus(String id) =>
    "$orders/provider/$id/status";

static const String adminOrders = "$orders/admin";
// ================= Provider Dashboard =================

static const String providerDashboard =
      "$baseUrl/provider/providerdashboard";
// ================= Forgot Password =================
  static const String forgotPasswordBase = "$baseUrl/forgot-password";

  static const String sendForgotPasswordOtp =
      "$forgotPasswordBase/send-otp";

  static const String verifyForgotPasswordOtp =
      "$forgotPasswordBase/verify-otp";

  static const String resetForgotPassword =
      "$forgotPasswordBase/reset-password";
}