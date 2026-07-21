import 'package:flutter/material.dart';
import 'package:my_app/features/auth/screens/login_screen.dart';
import 'package:my_app/features/admin/manage_users_screen.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/core/services/admin_service.dart';
import 'package:my_app/features/admin/admin_category_screen.dart';
import 'package:my_app/features/admin/provider_applications_screen.dart';
import 'package:my_app/features/admin/admin_provider_profiles.dart';
import 'package:my_app/features/admin/manage_services_screen.dart';
import 'package:my_app/features/admin/admin_orders_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String adminName = "Loading...";
  String adminEmail = "";

  bool isLoadingProfile = true;
  bool isLoadingStats = true;

  int totalUsers = 0;
  int totalProviders = 0;
  int totalCustomers = 0;
  int inactiveCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadProfile() async {
    final result = await AuthService.getProfile();

    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        adminName = result.data!["name"] ?? "Admin";
        adminEmail = result.data!["email"] ?? "";
        isLoadingProfile = false;
      });
    } else {
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadStats() async {
    final result = await AdminService.getAllUsers();

    if (!mounted) return;

    if (result.success && result.users != null) {
      final users = result.users!;

      setState(() {
        totalUsers = users.length;
        totalProviders =
            users.where((e) => e.role == "service_provider").length;
        totalCustomers =
            users.where((e) => e.role == "user").length;
        inactiveCount =
            users.where((e) => !e.isActive).length;

        isLoadingStats = false;
      });
    } else {
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(role: "admin"),
      ),
      (route) => false,
    );
  }

  void _openManageUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManageUsersScreen(),
      ),
    ).then((_) => _loadStats());
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
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFFFFFDF5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                isLoadingProfile ? "Loading..." : adminName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(isLoadingProfile ? "" : adminEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.amber.shade700,
                  size: 40,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.dashboard_rounded, color: Colors.amber.shade700),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.people_rounded, color: Colors.amber.shade700),
              title: const Text("Manage Users"),
              onTap: () {
                Navigator.pop(context);
                _openManageUsers();
              },
            ),

            ListTile(
              leading: Icon(Icons.category_rounded, color: Colors.amber.shade700),
              title: const Text("Manage Categories"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminCategoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.miscellaneous_services_rounded,
                  color: Colors.amber.shade700),
              title: const Text("Manage Services"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageServicesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.assignment_rounded, color: Colors.amber.shade700),
              title: const Text("Provider Applications"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProviderApplicationsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.badge_rounded, color: Colors.amber.shade700),
              title: const Text("Provider Profiles"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminProviderProfilesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long_rounded, color: Colors.amber.shade700),
              title: const Text("All Orders"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminOrdersScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: Colors.amber.shade700,
        onRefresh: () async {
          await _loadProfile();
          await _loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Welcome Card =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade400,
                      Colors.amber.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.amber.shade50,
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.amber.shade700,
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoadingProfile
                                ? "Loading..."
                                : "Welcome, $adminName 👋",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            adminEmail,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Overview",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 15),

              isLoadingStats
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber.shade700,
                      ),
                    )
                  : GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                      children: [
                        AdminStatCard(
                          icon: Icons.people_rounded,
                          title: "Users",
                          value: "$totalUsers",
                          color: Colors.blue.shade600,
                        ),

                        AdminStatCard(
                          icon: Icons.person_rounded,
                          title: "Customers",
                          value: "$totalCustomers",
                          color: Colors.amber.shade700,
                        ),

                        AdminStatCard(
                          icon: Icons.home_repair_service_rounded,
                          title: "Providers",
                          value: "$totalProviders",
                          color: Colors.green.shade600,
                        ),

                        AdminStatCard(
                          icon: Icons.block_rounded,
                          title: "Inactive",
                          value: "$inactiveCount",
                          color: Colors.red.shade400,
                        ),
                      ],
                    ),

              const SizedBox(height: 28),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _QuickActionTile(
                      icon: Icons.people_rounded,
                      title: "Manage Users",
                      onTap: _openManageUsers,
                    ),

                    Divider(height: 1, color: Colors.grey.shade100),

                    _QuickActionTile(
                      icon: Icons.category_rounded,
                      title: "Manage Categories",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AdminCategoryScreen(),
                          ),
                        );
                      },
                    ),

                    Divider(height: 1, color: Colors.grey.shade100),

                    _QuickActionTile(
                      icon: Icons.miscellaneous_services_rounded,
                      title: "Manage Services",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageServicesScreen(),
                          ),
                        );
                      },
                    ),

                    Divider(height: 1, color: Colors.grey.shade100),

                    _QuickActionTile(
                      icon: Icons.assignment_rounded,
                      title: "Provider Applications",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ProviderApplicationsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.amber.shade700, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 15,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}