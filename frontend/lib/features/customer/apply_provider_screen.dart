import 'package:flutter/material.dart';

import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/services/category_service.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/core/services/provider_application_service.dart';

class ApplyProviderScreen extends StatefulWidget {
  const ApplyProviderScreen({super.key});

  @override
  State<ApplyProviderScreen> createState() => _ApplyProviderScreenState();
}

class _ApplyProviderScreenState extends State<ApplyProviderScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final reasonController = TextEditingController();

  List<CategoryModel> categories = [];
  bool loadingCategories = true;

  // multi-select hai, isliye List of selected category ids
  List<String> selectedCategories = [];

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
  }

  // ================= USER =================

  Future<void> _loadUser() async {
    final result = await AuthService.getProfile();

    if (result.success && result.data != null) {
      setState(() {
        nameController.text = result.data!["name"] ?? "";
        emailController.text = result.data!["email"] ?? "";
      });
    }
  }

  // ================= CATEGORY =================

  Future<void> _loadCategories() async {
    final result = await CategoryService.getCategories();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        categories = result.data;
        loadingCategories = false;
      });
    } else {
      setState(() {
        loadingCategories = false;
      });
    }
  }

  // ================= TOGGLE CATEGORY =================

  void _toggleCategory(String categoryId) {
    setState(() {
      if (selectedCategories.contains(categoryId)) {
        selectedCategories.remove(categoryId);
      } else {
        selectedCategories.add(categoryId);
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ================= SUBMIT =================

  Future<void> _submit() async {
    if (selectedCategories.isEmpty ||
        phoneController.text.isEmpty ||
        reasonController.text.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    setState(() => submitting = true);

    final result = await ProviderApplicationService.applyProvider(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      categories: selectedCategories,
      interestReason: reasonController.text.trim(),
    );

    setState(() => submitting = false);

    if (!mounted) return;

    if (result.success) {
      // Success dialog dikhayenge taake message
      // pakka nazar aaye, uske baad hi screen close hogi
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 40,
              ),
            ),
            title: const Text(
              "Application Submitted",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            content: Text(
              "Your service provider application has been submitted successfully. Status: Pending",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } else {
      _showSnack(result.message);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.amber.shade700, size: 20),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // halka cream-white
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFFDF5),
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Apply For Service Provider",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER BANNER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.work_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Grow your business by joining\nour trusted service providers",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= PERSONAL INFO =================
            _sectionTitle("Personal Information"),

            TextField(
              controller: nameController,
              readOnly: true,
              decoration: _inputDecoration(
                label: "Name",
                icon: Icons.person_rounded,
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: emailController,
              readOnly: true,
              decoration: _inputDecoration(
                label: "Email",
                icon: Icons.email_rounded,
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                label: "Phone Number",
                icon: Icons.phone_rounded,
                hint: "03xxxxxxxxx",
              ),
            ),

            const SizedBox(height: 28),

            // ================= CATEGORY MULTI SELECT =================
            _sectionTitle("Business Interest"),

            loadingCategories
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.amber),
                    ),
                  )
                : categories.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Center(
                          child: Text(
                            "No categories found",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.03),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: categories.map((category) {
                            final isSelected =
                                selectedCategories.contains(category.id);

                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _toggleCategory(category.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.amber
                                        : Colors.amber.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(Icons.check_rounded,
                                          size: 15, color: Colors.white),
                                      const SizedBox(width: 5),
                                    ],
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

            const SizedBox(height: 8),

            Text(
              selectedCategories.isEmpty
                  ? "No category selected"
                  : "${selectedCategories.length} selected",
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 28),

            // ================= REASON =================
            _sectionTitle("Tell Us About Yourself"),

            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: _inputDecoration(
                label: "Why are you interested?",
                icon: Icons.edit_note_rounded,
                hint: "Tell us about your experience",
              ),
            ),

            const SizedBox(height: 30),

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
                onPressed: submitting ? null : _submit,
                child: submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Submit Application",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}