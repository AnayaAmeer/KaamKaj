import 'package:flutter/material.dart';
import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/models/service_model.dart';
import 'package:my_app/core/services/category_service.dart';
import 'package:my_app/core/services/service_service.dart';

class AddEditServiceScreen extends StatefulWidget {
  final ServiceModel? service;

  const AddEditServiceScreen({
    super.key,
    this.service,
  });

  @override
  State<AddEditServiceScreen> createState() =>
      _AddEditServiceScreenState();
}

class _AddEditServiceScreenState
    extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  List<CategoryModel> categories = [];

  CategoryModel? selectedCategory;

  bool isLoading = true;

  bool isSaving = false;

  bool get isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
    }

    loadCategories();
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

  Future<void> loadCategories() async {
    final result = await CategoryService.getCategories();

    if (!mounted) return;

    if (result.success) {
      categories = result.data as List<CategoryModel>;

      if (isEdit) {
        try {
          selectedCategory = categories.firstWhere(
            (e) => e.id == widget.service!.categoryId,
          );
        } catch (_) {}
      }
    } else {
      _showSnack(result.message, isError: true);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      _showSnack("Please select category", isError: true);
      return;
    }

    setState(() {
      isSaving = true;
    });

    ServiceResult result;

    if (isEdit) {
      result = await ServiceService.updateService(
        id: widget.service!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isActive: widget.service!.isActive,
      );
    } else {
      result = await ServiceService.addService(
        categoryId: selectedCategory!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (result.success) {
      _showSnack(isEdit ? "Service Updated" : "Service Added");
      Navigator.pop(context, true);
    } else {
      _showSnack(result.message, isError: true);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.amber.shade700),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: Colors.amber.shade50.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.amber, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
    );
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
        title: Text(
          isEdit ? "Edit Service" : "Add Service",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.amber.shade700),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEdit
                            ? Icons.edit_rounded
                            : Icons.design_services_rounded,
                        size: 44,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          // Category Dropdown
                          DropdownButtonFormField<CategoryModel>(
                            value: selectedCategory,
                            decoration: _inputDecoration(
                              label: "Category",
                              icon: Icons.category_rounded,
                            ),
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: isEdit
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                            validator: (value) {
                              if (value == null) {
                                return "Please select category";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Service Name
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              label: "Service Name",
                              icon: Icons.miscellaneous_services_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Service name is required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              label: "Description (Optional)",
                              icon: Icons.description_rounded,
                              alignLabelWithHint: true,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSaving ? null : saveService,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isEdit
                                  ? Icons.edit_rounded
                                  : Icons.save_rounded,
                            ),
                      label: Text(
                        isEdit ? "Update Service" : "Save Service",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}