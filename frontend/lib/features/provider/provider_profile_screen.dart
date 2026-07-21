import 'package:flutter/material.dart';

import 'package:my_app/core/models/provider_profile_model.dart';
import 'package:my_app/core/services/provider_profile_service.dart';
import 'package:my_app/features/provider/provider_profile_form_screen.dart';


class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}


class _ProviderProfileScreenState extends State<ProviderProfileScreen> {

  List<ProviderProfileModel> profiles = [];
  bool loading = true;


  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }


  Future<void> _loadProfiles() async {

    setState(() {
      loading = true;
    });

    final result = await ProviderProfileService.getMyProfiles();

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

      _showSnack(result.message, isError: true);
    }

  }


  Future<void> _openForm({ProviderProfileModel? existingProfile}) async {

    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderProfileFormScreen(
          existingProfile: existingProfile,
        ),
      ),
    );

    if (refreshed == true) {
      _loadProfiles();
    }

  }


  Future<void> _confirmDelete(ProviderProfileModel profile) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Delete Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete the \"${profile.categoryName}\" profile request? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteProfile(profile.id);
    }

  }


  Future<void> _deleteProfile(String id) async {

    final result = await ProviderProfileService.deleteProfile(id);

    if (!mounted) return;

    if (result.success) {

      _showSnack("Profile deleted");
      _loadProfiles();

    } else {

      _showSnack(result.message, isError: true);

    }

  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade400 : Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }


  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green.shade600;
      case "rejected":
        return Colors.red.shade400;
      default:
        return Colors.amber.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "approved":
        return Icons.check_circle_rounded;
      case "rejected":
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFFFFDF5),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF5),
        foregroundColor: Colors.black87,
        title: const Text(
          "My Provider Profiles",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.amber.shade700),
            onPressed: _loadProfiles,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: loading

          ? Center(
              child: CircularProgressIndicator(color: Colors.amber.shade700),
            )

          : profiles.isEmpty

              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.badge_outlined,
                            size: 50,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "No Profiles Yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tap \"Add Profile\" to create your\nfirst request",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )

              : RefreshIndicator(
                  color: Colors.amber.shade700,
                  onRefresh: _loadProfiles,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {

                      final profile = profiles[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(.10),
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

                              // ===== Header =====
                              Row(
                                children: [

                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.amber.shade50,
                                    backgroundImage: profile.image.isNotEmpty
                                        ? NetworkImage(profile.image)
                                        : null,
                                    child: profile.image.isEmpty
                                        ? Icon(
                                            Icons.person_rounded,
                                            color: Colors.amber.shade700,
                                          )
                                        : null,
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          profile.categoryName,
                                          style: TextStyle(
                                            color: Colors.amber.shade700,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),

                              const SizedBox(height: 14),
                              Divider(color: Colors.grey.shade200, height: 1),
                              const SizedBox(height: 14),

                              // ===== Contact Info =====
                              _InfoRow(
                                icon: Icons.phone_rounded,
                                text: profile.phone,
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.location_on_rounded,
                                text: profile.address,
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.work_history_rounded,
                                text: profile.experience,
                              ),

                              const SizedBox(height: 14),

                              // ===== Services =====
                              if (profile.services.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.amber.shade50.withOpacity(.5),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Services",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      ...profile.services.map(
                                        (service) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [

                                              Icon(
                                                Icons
                                                    .miscellaneous_services_rounded,
                                                size: 17,
                                                color: Colors.amber.shade700,
                                              ),

                                              const SizedBox(width: 8),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [

                                                    Text(
                                                      service.serviceName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13.5,
                                                        color:
                                                            Colors.black87,
                                                      ),
                                                    ),

                                                    if (service.description
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 2),
                                                        child: Text(
                                                          service
                                                              .description,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(top: 2),
                                                      child: Text(
                                                        "Rs. ${service.price}",
                                                        style: TextStyle(
                                                          color: Colors
                                                              .green
                                                              .shade700,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                          fontSize: 12.5,
                                                        ),
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
                                  ),
                                ),

                                const SizedBox(height: 14),
                              ],

                              // ===== Availability =====
                              Row(
                                children: [
                                  Icon(
                                    profile.availabilityStatus == "available"
                                        ? Icons.check_circle_rounded
                                        : Icons.remove_circle_rounded,
                                    size: 16,
                                    color:
                                        profile.availabilityStatus ==
                                                "available"
                                            ? Colors.green.shade600
                                            : Colors.red.shade400,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    profile.availabilityStatus == "available"
                                        ? "Available"
                                        : "Unavailable",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ===== Rating =====
                              if (profile.status == "approved") ...[

                                Row(
                                  children: [

                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        i < profile.rating
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: Colors.amber.shade700,
                                        size: 20,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      "${profile.rating}/5",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),

                                  ],
                                ),

                                const SizedBox(height: 12),

                              ],

                              // ===== Status Badges =====
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [

                                  _StatusChip(
                                    label: profile.status.toUpperCase(),
                                    color: _statusColor(profile.status),
                                    icon: _statusIcon(profile.status),
                                  ),

                                  if (profile.published)
                                    _StatusChip(
                                      label: "PUBLISHED",
                                      color: Colors.blue.shade600,
                                      icon: Icons.public_rounded,
                                    ),

                                ],
                              ),

                              const SizedBox(height: 16),

                              // ===== Actions =====
                              Row(
                                children: [

                                  Expanded(
                                    child: SizedBox(
                                      height: 46,
                                      child: OutlinedButton.icon(
                                        icon: Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: Colors.amber.shade700,
                                        ),
                                        label: Text(
                                          "Edit",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.amber.shade700,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.amber.shade300,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () => _openForm(
                                          existingProfile: profile,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: SizedBox(
                                      height: 46,
                                      child: OutlinedButton.icon(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: Colors.red.shade400,
                                        ),
                                        label: Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red.shade400,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.red.shade200,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _confirmDelete(profile),
                                      ),
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


// ===== Helper: Info Row =====
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}


// ===== Helper: Status Chip =====
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}