import 'package:flutter/material.dart';

import 'package:my_app/core/models/provider_application_model.dart';
import 'package:my_app/core/services/provider_application_service.dart';

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
  static const Color chipBg = Color(0xFFFFF8E1);
  static const Color chipText = Color(0xFF8D6E00);
  static const Color divider = Color(0xFFF0F0F0);
}

class ProviderApplicationsScreen extends StatefulWidget {
  const ProviderApplicationsScreen({super.key});

  @override
  State<ProviderApplicationsScreen> createState() =>
      _ProviderApplicationsScreenState();
}

class _ProviderApplicationsScreenState
    extends State<ProviderApplicationsScreen> {
  List<ProviderApplicationModel> applications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  // ================= GET APPLICATIONS =================

  Future<void> _loadApplications() async {
    setState(() {
      loading = true;
    });

    final result = await ProviderApplicationService.getApplications();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        applications = result.data;
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
    final result = await ProviderApplicationService.updateStatus(id, status);

    if (!mounted) return;

    if (result.success) {
      _showSnackBar("Application $status", isError: false);
      _loadApplications();
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  // ================= DELETE =================

  Future<void> _confirmDelete(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: _AppColors.surface,
          title: const Text(
            "Delete Application",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _AppColors.textPrimary,
            ),
          ),
          content: Text(
            "Are you sure you want to delete $name's application? This action cannot be undone.",
            style: const TextStyle(color: _AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: _AppColors.textSecondary,
              ),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: _AppColors.rejectedText,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteApplication(id);
    }
  }

  Future<void> _deleteApplication(String id) async {
    final result = await ProviderApplicationService.deleteApplication(id);

    if (!mounted) return;

    if (result.success) {
      _showSnackBar("Application deleted", isError: false);
      _loadApplications();
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
          "Provider Applications",
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
              onPressed: _loadApplications,
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
          : applications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No Applications Found",
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
                  onRefresh: _loadApplications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final app = applications[index];
                      final statusColor = _statusColors(app.status);

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
                              // ---------- Name + Delete ----------
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      app.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () =>
                                        _confirmDelete(app.id, app.name),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: _AppColors.rejectedText,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // ---------- Contact Info ----------
                              _InfoRow(icon: Icons.email_outlined, text: app.email),
                              const SizedBox(height: 4),
                              _InfoRow(icon: Icons.phone_outlined, text: app.phone),

                              const SizedBox(height: 14),

                              // ---------- Categories ----------
                              const Text(
                                "Categories",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              app.categories.isEmpty
                                  ? const Text(
                                      "—",
                                      style: TextStyle(
                                        color: _AppColors.textSecondary,
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: app.categories.map((catName) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _AppColors.chipBg,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _AppColors.primaryYellow
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                          child: Text(
                                            catName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _AppColors.chipText,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                              const SizedBox(height: 14),

                              // ---------- Reason ----------
                              const Text(
                                "Reason",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app.interestReason,
                                style: const TextStyle(
                                  color: _AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ---------- Status Badge ----------
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
                                  app.status.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    color: statusColor["text"],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Status buttons always visible so admin
                              // can edit/change status later
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.check_circle_outline,
                                      label: "Approve",
                                      isActive: app.status != "approved",
                                      activeColor: _AppColors.primaryYellow,
                                      activeTextColor: _AppColors.textPrimary,
                                      onPressed: app.status == "approved"
                                          ? null
                                          : () => _updateStatus(
                                              app.id, "approved"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.cancel_outlined,
                                      label: "Reject",
                                      isActive: app.status != "rejected",
                                      activeColor: Colors.white,
                                      activeTextColor: _AppColors.rejectedText,
                                      borderColor: _AppColors.rejectedText,
                                      onPressed: app.status == "rejected"
                                          ? null
                                          : () => _updateStatus(
                                              app.id, "rejected"),
                                    ),
                                  ),
                                ],
                              ),
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

/// ================= Small reusable info row (email/phone) =================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: _AppColors.textSecondary,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

/// ================= Modern Approve/Reject Button =================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeTextColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeTextColor,
    required this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isActive ? activeColor : const Color(0xFFF0F0F0);
    final Color fg = isActive ? activeTextColor : Colors.grey.shade500;

    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null && isActive
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
        ),
      ),
      onPressed: onPressed,
    );
  }
}