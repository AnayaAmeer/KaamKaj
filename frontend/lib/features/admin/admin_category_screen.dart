import 'package:flutter/material.dart';
import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/services/category_service.dart';
import 'package:my_app/features/admin/add_edit_category_screen.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  List<CategoryModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);

    final result = await CategoryService.getCategories();

    if (!mounted) return;

    setState(() {
      if (result.success) {
        categories = result.data as List<CategoryModel>;
      }
      isLoading = false;
    });

    if (!result.success) {
      _showSnack(result.message, isError: true);
    }
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          "Delete Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Kya aap "${category.name}" delete karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await CategoryService.deleteCategory(category.id);

    if (!mounted) return;

    if (result.success) {
      _showSnack("Category delete ho gayi");
      _loadCategories();
    } else {
      _showSnack(result.message, isError: true);
    }
  }

  Future<void> _openForm({CategoryModel? category}) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(category: category),
      ),
    );

    if (updated == true) _loadCategories();
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
          "Manage Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Category",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.amber.shade700,
        onRefresh: _loadCategories,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.amber.shade700),
              )
            : categories.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.category_rounded,
                                size: 50,
                                color: Colors.amber.shade700,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              "No Categories Found",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Tap \"Add Category\" pe click karke naya add karein",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
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
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [

                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  cat.imageUrl,
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 54,
                                    height: 54,
                                    color: Colors.amber.shade50,
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: Colors.amber.shade700,
                                  size: 21,
                                ),
                                onPressed: () => _openForm(category: cat),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red.shade400,
                                  size: 21,
                                ),
                                onPressed: () => _confirmDelete(cat),
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