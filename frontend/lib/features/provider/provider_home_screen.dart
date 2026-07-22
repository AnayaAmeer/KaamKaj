import 'package:flutter/material.dart';
import 'package:my_app/core/models/provider_dashboard_model.dart';
import 'package:my_app/core/services/provider_dashboard_service.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/features/auth/screens/login_screen.dart';
import 'package:my_app/features/provider/provider_orders_screen.dart';
import 'package:my_app/features/provider/provider_profile_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  bool _isLoading = true;
  bool _hasError = false;

  String _errorMessage = "";

  ProviderDashboardModel? dashboard;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final response = await ProviderDashboardService.getDashboard();

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        dashboard = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = response.message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(role: "provider"),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = dashboard?.provider;
    final stats = dashboard?.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // halka cream-white
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF5),
        foregroundColor: Colors.black87,
        title: const Text(
          "Provider Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: Icon(Icons.refresh_rounded, color: Colors.amber.shade700),
          ),
        ],
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
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: provider != null && provider.image.isNotEmpty
                    ? NetworkImage(provider.image)
                    : null,
                child: provider == null || provider.image.isEmpty
                    ? Icon(
                        Icons.home_repair_service_rounded,
                        color: Colors.amber.shade700,
                        size: 35,
                      )
                    : null,
              ),
              accountName: Text(
                provider?.name ?? "Loading...",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(provider?.email ?? ""),
            ),

            ListTile(
              leading: Icon(Icons.home_rounded, color: Colors.amber.shade700),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading:
                  Icon(Icons.person_rounded, color: Colors.amber.shade700),
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
              leading:
                  Icon(Icons.assignment_rounded, color: Colors.amber.shade700),
              title: const Text("My Jobs"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProviderOrdersScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading:
                  Icon(Icons.currency_rupee_rounded, color: Colors.amber.shade700),
              title: const Text("Earnings"),
              subtitle: Text(
                "PKR ${stats?.earnings.toStringAsFixed(0) ?? "0"}",
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        color: Colors.amber.shade700,
        onRefresh: _loadDashboard,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.amber.shade700,
                ),
              )
            : _hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red.shade400,
                            size: 70,
                          ),

                          const SizedBox(height: 20),

                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _loadDashboard,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text(
                              "Retry",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ===== Welcome Header Card =====
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.amber.shade700,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
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
                                  radius: 32,
                                  backgroundColor: Colors.amber.shade50,
                                  backgroundImage:
                                      provider != null &&
                                              provider.image.isNotEmpty
                                          ? NetworkImage(
                                              provider.image,
                                            )
                                          : null,

                                  child:
                                      provider == null ||
                                              provider.image.isEmpty
                                          ? Icon(
                                              Icons.home_repair_service_rounded,
                                              size: 32,
                                              color: Colors.amber.shade700,
                                            )
                                          : null,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      "Welcome, ${provider?.name ?? ""} 👋",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      provider?.email ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      provider?.phone ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),

                                    if ((provider?.category ?? "")
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          provider!.category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
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

                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.assignment_turned_in_rounded,
                                title: "Approved Jobs",
                                value:
                                    "${stats?.approvedJobs ?? 0}",
                                color: Colors.green.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.pending_actions_rounded,
                                title: "Pending Jobs",
                                value:
                                    "${stats?.pendingJobs ?? 0}",
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.star_rounded,
                                title: "Rating",
                                value:
                                    "${stats?.rating.toStringAsFixed(1) ?? "0.0"}",
                                color: Colors.amber.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.currency_rupee_rounded,
                                title: "Earnings",
                                value:
                                    "PKR ${stats?.earnings.toStringAsFixed(0) ?? "0"}",
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Recent Requests",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 15),

                        if (dashboard!.recentRequests.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.inbox_outlined,
                                    size: 44,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  "No Requests Yet",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "New booking requests will appear here",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount:
                                dashboard!.recentRequests.length,
                            itemBuilder: (context, index) {
                              final request =
                                  dashboard!.recentRequests[index];

                              return RequestTile(
                                customerName:
                                    request.customerName,
                                service:
                                    request.category,
                                status:
                                    request.providerStatus,
                              );
                            },
                          ),

                        const SizedBox(height: 30),
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(.12),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
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
    switch (status.toLowerCase()) {
      case "approved":
      case "accepted":
        return Colors.blue.shade600;

      case "completed":
        return Colors.green.shade600;

      case "cancelled":
      case "rejected":
        return Colors.red.shade400;

      case "pending":
      default:
        return Colors.amber.shade700;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case "approved":
      case "accepted":
        return Icons.check_circle_rounded;

      case "completed":
        return Icons.task_alt_rounded;

      case "cancelled":
      case "rejected":
        return Icons.cancel_rounded;

      case "pending":
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.amber.shade50,
            child: Icon(
              Icons.person_rounded,
              color: Colors.amber.shade700,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  service,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 16,
                ),

                const SizedBox(width: 5),

                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}