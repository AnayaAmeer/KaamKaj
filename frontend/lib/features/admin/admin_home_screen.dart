import 'package:flutter/material.dart';
import 'package:my_app/features/auth/screens/login_screen.dart';
import 'package:my_app/features/admin/manage_users_screen.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/core/services/admin_service.dart';
import 'package:my_app/features/admin/admin_category_screen.dart';
import 'package:my_app/features/admin/add_edit_category_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String adminName = "Loading...";
  String adminEmail = "";
  bool isLoadingProfile = true;

  int totalUsers = 0;
  int totalProviders = 0;
  int totalCustomers = 0;
  int inactiveCount = 0;
  bool isLoadingStats = true;

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
      setState(() => isLoadingProfile = false);
    }
  }

  Future<void> _loadStats() async {
    final result = await AdminService.getAllUsers();
    if (!mounted) return;

    if (result.success && result.users != null) {
      final users = result.users!;
      setState(() {
        totalUsers = users.length;
        totalProviders = users.where((u) => u.role == "service_provider").length;
        totalCustomers = users.where((u) => u.role == "user").length;
        inactiveCount = users.where((u) => !u.isActive).length;
        isLoadingStats = false;
      });
    } else {
      setState(() => isLoadingStats = false);
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(role: "admin")),
      (route) => false,
    );
  }

  void _openManageUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
    ).then((_) => _loadStats()); // wapas aane par stats refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: Text(isLoadingProfile ? "Loading..." : adminName),
              accountEmail: Text(isLoadingProfile ? "" : adminEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.deepPurple),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
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
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
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
              // WELCOME CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, size: 32, color: Colors.deepPurple),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoadingProfile ? "Loading..." : "Welcome, $adminName 👋",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoadingProfile ? "" : adminEmail,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              isLoadingStats
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        AdminStatCard(
                          icon: Icons.people,
                          title: "Total Users",
                          value: "$totalUsers",
                          color: Colors.blue,
                        ),
                        AdminStatCard(
                          icon: Icons.home_repair_service,
                          title: "Providers",
                          value: "$totalProviders",
                          color: Colors.green,
                        ),
                        AdminStatCard(
                          icon: Icons.person,
                          title: "Customers",
                          value: "$totalCustomers",
                          color: Colors.orange,
                        ),
                        AdminStatCard(
                          icon: Icons.block,
                          title: "Inactive",
                          value: "$inactiveCount",
                          color: Colors.red,
                        ),
                      ],
                    ),

              const SizedBox(height: 24),

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.people, color: Colors.blue),
                      ),
                      title: const Text("Manage Users"),
                      subtitle: const Text("View, change role, activate/deactivate"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _openManageUsers,
                    ),
                    ListTile(
  leading: const Icon(Icons.category),
  title: const Text("Manage Categories"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminCategoryScreen()),
    );
  },
),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.bar_chart, color: Colors.green),
                      ),
                      title: const Text("View Platform Reports"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}