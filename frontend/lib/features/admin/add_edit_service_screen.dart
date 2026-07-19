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

  bool get isEdit =>
      widget.service != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _nameController.text =
          widget.service!.name;

      _descriptionController.text =
          widget.service!.description;
    }

    loadCategories();
  }

  Future<void> loadCategories() async {
    final result =
        await CategoryService.getCategories();

    if (!mounted) return;

    if (result.success) {
      categories =
          result.data as List<CategoryModel>;

      if (isEdit) {
        try {
          selectedCategory =
              categories.firstWhere(
            (e) =>
                e.id ==
                widget.service!.categoryId,
          );
        } catch (_) {}
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(result.message),
        ),
      );
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
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Please select category"),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    ServiceResult result;

    if (isEdit) {
      result =
          await ServiceService.updateService(
        id: widget.service!.id,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim(),
        isActive:
            widget.service!.isActive,
      );
    } else {
      result =
          await ServiceService.addService(
        categoryId: selectedCategory!.id,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim(),
      );
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Service Updated"
                : "Service Added",
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(result.message),
        ),
      );
    }
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Service" : "Add Service",
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    // Category Dropdown
                    DropdownButtonFormField<CategoryModel>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
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
                      decoration: const InputDecoration(
                        labelText: "Service Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.miscellaneous_services),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
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
                      decoration: const InputDecoration(
                        labelText: "Description (Optional)",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            isSaving ? null : saveService,
                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isEdit
                                    ? Icons.edit
                                    : Icons.save,
                              ),
                        label: Text(
                          isEdit
                              ? "Update Service"
                              : "Save Service",
                        ),
                      ),
                    ),
                  ],
                ),
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