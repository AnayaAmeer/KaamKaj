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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
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
          title: const Text("Delete Profile"),
          content: Text(
            "Are you sure you want to delete the \"${profile.categoryName}\" profile request? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile deleted"),
          backgroundColor: Colors.green,
        ),
      );

      _loadProfiles();

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );

    }

  }


  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Provider Profiles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
          ),
        ],
      ),

      // Add button — nayi profile request bhejne ke liye
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text("Add Profile"),
      ),

      body: loading

          ? const Center(child: CircularProgressIndicator())

          : profiles.isEmpty

              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "No profiles yet",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap \"Add Profile\" to create your first request",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )

              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {

                    final profile = profiles[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: profile.image.isNotEmpty
                                      ? NetworkImage(profile.image)
                                      : null,
                                  child: profile.image.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.grey,
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        profile.categoryName,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),

                            const SizedBox(height: 10),

                            Text("Phone: ${profile.phone}"),
                            Text("Address: ${profile.address}"),
                            Text("Experience: ${profile.experience}"),
                            const SizedBox(height: 8),

if (profile.services.isNotEmpty) ...[
  const Text(
    "Services",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  ),

  const SizedBox(height: 6),

  ...profile.services.map(
    (service) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Icon(
            Icons.miscellaneous_services,
            size: 18,
            color: Colors.blue,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (service.description.isNotEmpty)
  Text(
    service.description,
    style: TextStyle(
      color: Colors.grey.shade600,
      fontSize: 12,
    ),
  ),

                Text(
                  "Rs. ${service.price}",
                  style: const TextStyle(
                    color: Colors.green,
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

  const SizedBox(height: 10),
],

                            const SizedBox(height: 6),

                            Text(
                              "Availability: ${profile.availabilityStatus == "available" ? "Available" : "Unavailable"}",
                            ),

                            const SizedBox(height: 10),

                            // Admin ki taraf se di gayi rating —
                            // sirf approved profile par nazar aati hai
                            if (profile.status == "approved") ...[

                              Row(
                                children: [

                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      i < profile.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "${profile.rating}/5",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                ],
                              ),

                              const SizedBox(height: 10),

                            ],

                            Wrap(
                              spacing: 8,
                              children: [

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(profile.status)
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    profile.status.toUpperCase(),
                                    style: TextStyle(
                                      color: _statusColor(profile.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                if (profile.published)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "PUBLISHED",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                              ],
                            ),

                            const SizedBox(height: 15),

                            Row(
                              children: [

                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: const Text("Edit"),
                                    onPressed: () => _openForm(
                                      existingProfile: profile,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(profile),
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

    );

  }

}