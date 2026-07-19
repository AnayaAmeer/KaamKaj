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
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration:
                  const BoxDecoration(color: Colors.deepPurple),
              accountName:
                  Text(isLoadingProfile ? "Loading..." : adminName),
              accountEmail:
                  Text(isLoadingProfile ? "" : adminEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.deepPurple,
                  size: 40,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Manage Users"),
              onTap: () {
                Navigator.pop(context);
                _openManageUsers();
              },
            ),

            ListTile(
              leading: const Icon(Icons.category),
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
  leading: const Icon(Icons.miscellaneous_services),
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
              leading: const Icon(Icons.assignment),
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
  leading: const Icon(Icons.badge),
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
  leading: const Icon(Icons.receipt_long),
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
              leading:
                  const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
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
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.purpleAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.deepPurple,
                        size: 32,
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
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              isLoadingStats
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
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
                          icon: Icons.people,
                          title: "Users",
                          value: "$totalUsers",
                          color: Colors.blue,
                        ),

                        AdminStatCard(
                          icon: Icons.person,
                          title: "Customers",
                          value: "$totalCustomers",
                          color: Colors.orange,
                        ),

                        AdminStatCard(
                          icon: Icons.home_repair_service,
                          title: "Providers",
                          value: "$totalProviders",
                          color: Colors.green,
                        ),

                        AdminStatCard(
                          icon: Icons.block,
                          title: "Inactive",
                          value: "$inactiveCount",
                          color: Colors.red,
                        ),
                      ],
                    ),

              const SizedBox(height: 25),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.people),
                      title:
                          const Text("Manage Users"),
                      trailing:
                          const Icon(Icons.arrow_forward_ios),
                      onTap: _openManageUsers,
                    ),

                    const Divider(height: 1),

                    ListTile(
                      leading:
                          const Icon(Icons.category),
                      title: const Text(
                          "Manage Categories"),
                      trailing:
                          const Icon(Icons.arrow_forward_ios),
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
                    const Divider(height: 1),

ListTile(
  leading: const Icon(Icons.miscellaneous_services),
  title: const Text("Manage Services"),
  trailing: const Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManageServicesScreen(),
      ),
    );
  },
),

                    const Divider(height: 1),

                    ListTile(
                      leading:
                          const Icon(Icons.assignment),
                      title: const Text(
                          "Provider Applications"),
                      trailing:
                          const Icon(Icons.arrow_forward_ios),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}