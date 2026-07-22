import 'package:flutter/material.dart';
import 'package:my_app/features/customer/customer_home_screen.dart';
import 'package:my_app/features/provider/provider_home_screen.dart';
import 'package:my_app/features/admin/admin_home_screen.dart';
import 'package:my_app/features/role_selection/screens/role_selection_screen.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'customer_register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  String get screenTitle {
    switch (widget.role) {
      case "provider":
        return "Service Provider Login";
      case "admin":
        return "Admin Login";
      default:
        return "Customer Login";
    }
  }

  String get screenSubtitle {
    switch (widget.role) {
      case "provider":
        return "Login to manage your services";
      case "admin":
        return "Login to access admin panel";
      default:
        return "Login to book trusted services";
    }
  }

  IconData get screenIcon {
    switch (widget.role) {
      case "provider":
        return Icons.home_repair_service_rounded;
      case "admin":
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all fields"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

   final result = await AuthService.login(email: email, password: password);

if (!mounted) return;
setState(() => isLoading = false);

if (!result.success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result.message),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
  return;
}

// ✅ Success message dikhao
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(result.message), // "Login successful"
    backgroundColor: Colors.green.shade600,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);

// Thora sa delay taake message dikh sake, phir navigate karo
await Future.delayed(const Duration(milliseconds: 600));

if (!mounted) return;

final actualRole = result.role;

switch (actualRole) {
  case "service_provider":
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
      (route) => false,
    );
    break;
  case "admin":
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      (route) => false,
    );
    break;
  default:
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
}
 } 

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.amber.shade700),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.amber.shade50.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.amber, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // halka cream-white
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFFFDF5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(screenIcon, size: 54, color: Colors.amber.shade700),
              ),

              const SizedBox(height: 24),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                screenSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                screenTitle,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  label: "Email",
                  icon: Icons.email_rounded,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: _inputDecoration(
                  label: "Password",
                  icon: Icons.lock_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

             Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
      );
    },
    child: Text(
      "Forgot Password?",
      style: TextStyle(
        color: Colors.amber.shade700,
        fontWeight: FontWeight.w500,
        fontSize: 13.5,
      ),
    ),
  ),
),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              if (widget.role != "admin")
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CustomerRegisterScreen(role: widget.role),
                          ),
                        );
                      },
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}