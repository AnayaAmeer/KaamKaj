import 'package:flutter/material.dart';
import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/core/services/category_service.dart';
import 'package:my_app/features/auth/screens/login_screen.dart';
import 'package:my_app/features/customer/apply_provider_screen.dart';
import 'package:my_app/features/customer/category_providers_screen.dart';
import 'package:my_app/features/customer/my_orders_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String userName = "Loading...";
  String userEmail = "";
  String userPhone = "";

  bool isLoadingProfile = true;
  bool isLoadingCategories = true;

  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCategories();
  }

  // ================= PROFILE =================

  Future<void> _loadProfile() async {
    final result = await AuthService.getProfile();

    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        userName = result.data!["name"] ?? "User";
        userEmail = result.data!["email"] ?? "";
        userPhone = result.data!["phone"] ?? result.data!["phoneNumber"] ?? "";
        isLoadingProfile = false;
      });
    } else {
      setState(() {
        isLoadingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(role: "customer"),
        ),
        (route) => false,
      );
    }
  }

  // ================= CATEGORIES =================

  Future<void> _loadCategories() async {
    setState(() {
      isLoadingCategories = true;
    });

    final result = await CategoryService.getCategories();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        categories = result.data;
        isLoadingCategories = false;
      });
    } else {
      setState(() {
        isLoadingCategories = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ================= LOGOUT =================

  Future<void> _handleLogout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(role: "customer"),
      ),
      (route) => false,
    );
  }

  // ================= CATEGORY TAP =================

  void _openCategory(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProvidersScreen(category: category),
      ),
    );
  }

  // ================= PROFILE INFO DIALOG =================

  void _showProfileInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.amber.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.amber.shade50,
                  child: Icon(Icons.person_rounded,
                      size: 38, color: Colors.amber.shade700),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName.isEmpty ? "User" : userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 18),
              _profileInfoTile(
                icon: Icons.email_rounded,
                label: "Email",
                value: userEmail.isEmpty ? "Not available" : userEmail,
              ),
              const SizedBox(height: 10),
              _profileInfoTile(
                icon: Icons.phone_rounded,
                label: "Phone",
                value: userPhone.isEmpty ? "Not available" : userPhone,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // halka cream-white
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFFDF5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.amber.shade50,
                      child: Icon(Icons.person_rounded,
                          size: 30, color: Colors.amber.shade700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isLoadingProfile ? "Loading..." : userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLoadingProfile ? "" : userEmail,
                    style: TextStyle(color: Colors.amber.shade50, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _drawerTile(
              icon: Icons.home_rounded,
              title: "Home",
              onTap: () => Navigator.pop(context),
            ),

            _drawerTile(
              icon: Icons.history_rounded,
              title: "My Orders",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
            ),

            _drawerTile(
              icon: Icons.favorite_rounded,
              title: "Saved Services",
              onTap: () {},
            ),

            _drawerTile(
              icon: Icons.work_rounded,
              title: "Apply for Service Provider",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApplyProviderScreen()),
                );
              },
            ),

            _drawerTile(
              icon: Icons.settings_rounded,
              title: "Settings",
              onTap: () {},
            ),

            const Divider(height: 24, indent: 20, endIndent: 20),

            _drawerTile(
              icon: Icons.logout_rounded,
              title: "Logout",
              onTap: _handleLogout,
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),

      body: isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : RefreshIndicator(
              color: Colors.amber,
              onRefresh: _loadCategories,
              child: CustomScrollView(
                slivers: [
                  // ================= HEADER BANNER =================
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.amber.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // FIX: profile avatar ki jaga ab menu button
                                // (hamburger icon) hai jo drawer kholta hai.
                                Builder(
                                  builder: (context) => InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () => Scaffold.of(context).openDrawer(),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.menu_rounded,
                                          color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),
                                // FIX: notification icon hata kar profile icon
                                // laga diya — tap karne par name/email/phone
                                // wala dialog khulta hai.
                                InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: _showProfileInfo,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.amber.shade50,
                                      child: Icon(Icons.person_rounded,
                                          color: Colors.amber.shade700, size: 22),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Hello $userName 👋",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "What service do you need today?",
                              style: TextStyle(
                                color: Colors.amber.shade50,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ================= CATEGORIES HEADING =================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (categories.isNotEmpty)
                            Text(
                              "${categories.length} available",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ================= CATEGORIES GRID =================
                  if (isLoadingCategories)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    )
                  else if (categories.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.category_outlined,
                                  size: 40, color: Colors.amber.shade300),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "No Categories Found",
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = categories[index];
                            return CategoryCard(
                              category: category,
                              onTap: () => _openCategory(category),
                            );
                          },
                          childCount: categories.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.amber.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.amber.shade50,
                    child: Image.network(
                      category.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported_rounded,
                          size: 34,
                          color: Colors.amber.shade200,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.amber,
                            strokeWidth: 2,
                          ),
                        );
                      },
                    ),
                  ),
                  // subtle bottom gradient for polish
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                category.name,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}