import 'package:flutter/material.dart';

import 'package:my_app/core/constants/api_constants.dart';
import 'package:my_app/core/models/provider_profile_model.dart';
import 'package:my_app/core/services/provider_profile_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// ================= COLOR PALETTE (White + Yellow / Amber) =================
class _AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryYellow = Color(0xFFFFC107); // Amber 500
  static const Color darkYellow = Color(0xFFFFA000); // Amber 700
  static const Color lightYellow = Color(0xFFFFF8E1); // Amber 50
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color approvedBg = Color(0xFFE8F5E9);
  static const Color approvedText = Color(0xFF2E7D32);
  static const Color rejectedBg = Color(0xFFFDECEA);
  static const Color rejectedText = Color(0xFFC62828);
  static const Color pendingBg = Color(0xFFFFF3E0);
  static const Color pendingText = Color(0xFFEF6C00);
  static const Color publishedBg = Color(0xFFE3F2FD);
  static const Color publishedText = Color(0xFF1565C0);
  static const Color divider = Color(0xFFF0F0F0);
}

class AdminProviderProfilesScreen extends StatefulWidget {
  const AdminProviderProfilesScreen({super.key});

  @override
  State<AdminProviderProfilesScreen> createState() =>
      _AdminProviderProfilesScreenState();
}

class _AdminProviderProfilesScreenState
    extends State<AdminProviderProfilesScreen> {
  List<ProviderProfileModel> profiles = [];
  bool loading = true;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final experienceController = TextEditingController();
  final aboutController = TextEditingController();

  String availability = "available";

  double rating = 0;

  String editingId = "";

  File? pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  // ================= GET PROFILES =================

  Future<void> _loadProfiles() async {
    setState(() {
      loading = true;
    });

    final result = await ProviderProfileService.getAllProfiles();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        profiles = result.data;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      _showSnackBar(result.message, isError: true);
    }
  }

  // ================= UPDATE STATUS =================

  Future<void> _updateStatus(String id, String status) async {
    final result = await ProviderProfileService.updateStatus(id, status);

    if (!mounted) return;

    if (result.success) {
      _showSnackBar("Profile $status", isError: false);
      _loadProfiles();
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  // ================= PUBLISH =================

  Future<void> _publish(String id) async {
    final result = await ProviderProfileService.publishProfile(id);

    if (!mounted) return;

    if (result.success) {
      _showSnackBar("Profile published", isError: false);
      _loadProfiles();
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  // ================= HELPERS =================

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor:
            isError ? _AppColors.rejectedText : _AppColors.darkYellow,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Map<String, Color> _statusColors(String status) {
    switch (status) {
      case "approved":
        return {"bg": _AppColors.approvedBg, "text": _AppColors.approvedText};
      case "rejected":
        return {"bg": _AppColors.rejectedBg, "text": _AppColors.rejectedText};
      default:
        return {"bg": _AppColors.pendingBg, "text": _AppColors.pendingText};
    }
  }

  // ================= DELETE =================

  Future<void> _deleteProvider(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: _AppColors.surface,
          title: const Text(
            "Delete Provider",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _AppColors.textPrimary,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this provider?",
            style: TextStyle(color: _AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: _AppColors.textSecondary,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.rejectedText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final result = await ProviderProfileService.adminDeleteProfile(id);

    if (!mounted) return;

    if (result.success) {
      _showSnackBar("Provider deleted successfully", isError: false);
      _loadProfiles();
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  // ================= EDIT DIALOG =================

  void _showEditDialog(ProviderProfileModel profile) {
    nameController.text = profile.name;
    emailController.text = profile.email;
    phoneController.text = profile.phone;
    addressController.text = profile.address;
    experienceController.text = profile.experience;
    aboutController.text = profile.about;

    rating = profile.rating;

    InputDecoration _fieldDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _AppColors.textSecondary),
        filled: true,
        fillColor: _AppColors.lightYellow.withOpacity(0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.primaryYellow, width: 1.5),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: _AppColors.surface,
              title: const Text(
                "Edit Provider",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _AppColors.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: _fieldDecoration("Name"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: emailController,
                      decoration: _fieldDecoration("Email"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      decoration: _fieldDecoration("Phone"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: addressController,
                      decoration: _fieldDecoration("Address"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: experienceController,
                      decoration: _fieldDecoration("Experience"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: aboutController,
                      maxLines: 3,
                      decoration: _fieldDecoration("About"),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Give Rating",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 35,
                              minHeight: 35,
                            ),
                            onPressed: () {
                              setState(() {
                                rating = index + 1.0;
                              });
                            },
                            icon: Icon(
                              index < rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: _AppColors.primaryYellow,
                              size: 28,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _AppColors.textSecondary,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AppColors.primaryYellow,
                    foregroundColor: _AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final result =
                        await ProviderProfileService.adminUpdateProfile(
                      id: profile.id,
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                      experience: experienceController.text,
                      about: aboutController.text,
                      category: profile.categoryId,
                      availabilityStatus: availability,
                      status: profile.status,
                      published: profile.published,
                      rating: rating,
                      image: pickedImage,
                    );

                    if (result.success) {
                      Navigator.pop(context);
                      _loadProfiles();
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Provider Profiles",
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: _AppColors.lightYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: _AppColors.darkYellow),
              onPressed: _loadProfiles,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _AppColors.divider, height: 1),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: _AppColors.primaryYellow,
              ),
            )
          : profiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No Provider Profiles Found",
                        style: TextStyle(
                          color: _AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: _AppColors.darkYellow,
                  onRefresh: _loadProfiles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      final statusColor = _statusColors(profile.status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: _AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _AppColors.divider),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---------- Avatar + Name ----------
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: _AppColors.lightYellow,
                                    backgroundImage: profile.image.isNotEmpty
                                        ? NetworkImage(profile.image)
                                        : null,
                                    child: profile.image.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            color: _AppColors.darkYellow,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: _AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          profile.categoryName,
                                          style: const TextStyle(
                                            color: _AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ---------- Contact Info ----------
                              _InfoRow(icon: Icons.email_outlined, text: profile.email),
                              const SizedBox(height: 4),
                              _InfoRow(icon: Icons.phone_outlined, text: profile.phone),
                              const SizedBox(height: 4),
                              _InfoRow(icon: Icons.location_on_outlined, text: profile.address),
                              const SizedBox(height: 4),
                              _InfoRow(icon: Icons.work_outline, text: profile.experience),

                              const SizedBox(height: 12),

                              const Text(
                                "About",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.about,
                                style: const TextStyle(
                                  color: _AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),

                              if (profile.services.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                const Text(
                                  "Services",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: _AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...profile.services.map(
                                  (service) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _AppColors.lightYellow.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.miscellaneous_services,
                                          size: 18,
                                          color: _AppColors.darkYellow,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.serviceName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: _AppColors.textPrimary,
                                                ),
                                              ),
                                              if (service.description.isNotEmpty)
                                                Text(
                                                  service.description,
                                                  style: const TextStyle(
                                                    color: _AppColors.textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Rs. ${service.price}",
                                                style: const TextStyle(
                                                  color: _AppColors.approvedText,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),

                              Text(
                                "Availability: ${profile.availabilityStatus == "available" ? "Available" : "Unavailable"}",
                                style: const TextStyle(
                                  color: _AppColors.textPrimary,
                                  fontSize: 13.5,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < profile.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: _AppColors.primaryYellow,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${profile.rating}/5",
                                    style: const TextStyle(
                                      color: _AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ---------- Status Badges ----------
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor["bg"],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      profile.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor["text"],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  if (profile.published)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _AppColors.publishedBg,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "PUBLISHED",
                                        style: TextStyle(
                                          color: _AppColors.publishedText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ---------- Edit / Delete ----------
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.edit_outlined,
                                      label: "Edit",
                                      backgroundColor: _AppColors.primaryYellow,
                                      textColor: _AppColors.textPrimary,
                                      onPressed: () => _showEditDialog(profile),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.delete_outline,
                                      label: "Delete",
                                      backgroundColor: Colors.white,
                                      textColor: _AppColors.rejectedText,
                                      borderColor: _AppColors.rejectedText,
                                      onPressed: () =>
                                          _deleteProvider(profile.id),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // ---------- Approve / Reject ----------
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.check_circle_outline,
                                      label: "Approve",
                                      backgroundColor:
                                          profile.status == "approved"
                                              ? const Color(0xFFF0F0F0)
                                              : _AppColors.approvedText,
                                      textColor: profile.status == "approved"
                                          ? Colors.grey.shade500
                                          : Colors.white,
                                      onPressed: profile.status == "approved"
                                          ? null
                                          : () => _updateStatus(
                                              profile.id, "approved"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.cancel_outlined,
                                      label: "Reject",
                                      backgroundColor:
                                          profile.status == "rejected"
                                              ? const Color(0xFFF0F0F0)
                                              : _AppColors.rejectedText,
                                      textColor: profile.status == "rejected"
                                          ? Colors.grey.shade500
                                          : Colors.white,
                                      onPressed: profile.status == "rejected"
                                          ? null
                                          : () => _updateStatus(
                                              profile.id, "rejected"),
                                    ),
                                  ),
                                ],
                              ),

                              // ---------- Publish (only when approved) ----------
                              if (profile.status == "approved" &&
                                  !profile.published) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: _ActionButton(
                                    icon: Icons.publish_outlined,
                                    label: "Publish",
                                    backgroundColor: _AppColors.publishedText,
                                    textColor: Colors.white,
                                    onPressed: () => _publish(profile.id),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

/// ================= Small reusable info row =================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// ================= Modern reusable action button =================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
        ),
      ),
      onPressed: onPressed,
    );
  }
}