import 'package:flutter/material.dart';
import 'package:my_app/features/auth/screens/login_screen.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/features/provider/provider_profile_screen.dart';
import 'package:my_app/features/provider/provider_orders_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  String providerName = "Loading...";
  String providerEmail = "";
  String providerPhone = "";
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await AuthService.getProfile();
    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        providerName = result.data!["name"] ?? "Provider";
        providerEmail = result.data!["email"] ?? "";
        providerPhone = result.data!["phoneNumber"] ?? "";
        isLoadingProfile = false;
      });
    } else {
      setState(() => isLoadingProfile = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen(role: "provider")),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(role: "provider")),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Provider Dashboard"),
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
              decoration: const BoxDecoration(color: Colors.teal),
              accountName: Text(isLoadingProfile ? "Loading..." : providerName),
              accountEmail: Text(isLoadingProfile ? "" : providerEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.home_repair_service, size: 40, color: Colors.teal),
              ),
            ),
           ListTile(
  leading: const Icon(Icons.home),
  title: const Text("Home"),
  onTap: () => Navigator.pop(context),
),

ListTile(
  leading: const Icon(Icons.person),
  title: const Text("Profile Settings"),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProviderProfileScreen(),
      ),
    );
  },
),

ListTile(
  leading: const Icon(Icons.assignment),
  title: const Text("My Jobs"),
  onTap: () {
    Navigator.pop(context); // drawer close karo pehle
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProviderOrdersScreen(),
      ),
    );
  },
),

ListTile(
  leading: const Icon(Icons.attach_money),
  title: const Text("Earnings"),
  onTap: () {},
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
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE / WELCOME CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.tealAccent],
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
                      child: Icon(Icons.home_repair_service, size: 30, color: Colors.teal),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoadingProfile ? "Loading..." : "Welcome, $providerName 👋",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoadingProfile ? "" : providerEmail,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          if (!isLoadingProfile && providerPhone.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                providerPhone,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
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

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.assignment_turned_in,
                      title: "Active Jobs",
                      value: "3",
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.star,
                      title: "Rating",
                      value: "4.8",
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "Recent Requests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const RequestTile(customerName: "Ali Khan", service: "Plumbing", status: "Pending"),
              const RequestTile(customerName: "Sara Ahmed", service: "Electrical", status: "Accepted"),
              const RequestTile(customerName: "Bilal Raza", service: "Cleaning", status: "Completed"),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class RequestTile extends StatelessWidget {
  final String customerName;
  final String service;
  final String status;

  const RequestTile({
    super.key,
    required this.customerName,
    required this.service,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case "Accepted":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2F1),
          child: Icon(Icons.person, color: Colors.teal),
        ),
        title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(service),
        trailing: Chip(
          label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: statusColor,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}