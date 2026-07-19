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
        isLoadingProfile = false;
      });
    } else {
      setState(() {
        isLoadingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(isLoadingProfile ? "Loading..." : userName),
              accountEmail:
                  Text(isLoadingProfile ? "" : userEmail),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("My Orders"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyOrdersScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Saved Services"),
              onTap: () {},
            ),
           ListTile(
  leading: const Icon(Icons.work),
  title: const Text(
    "Apply for Service Provider",
  ),

  onTap: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ApplyProviderScreen(),
      ),
    );

  },
),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),

      body: isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello $userName 👋",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "What service do you need today?",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search services...",
                        prefixIcon:
                            const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),
                                        Expanded(
                      child: isLoadingCategories
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : categories.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No Categories Found",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : GridView.builder(
                                  itemCount: categories.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.9,
                                  ),
                                  itemBuilder: (context, index) {
                                    final category = categories[index];

                                    return CategoryCard(
                                      category: category,
                                      onTap: () =>
                                          _openCategory(category),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
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
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    category.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder:
                        (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}