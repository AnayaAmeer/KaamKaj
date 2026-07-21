import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/services/category_service.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _pickedImage;
  bool _isSaving = false;

  bool get isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEditMode && _pickedImage == null) {
      _showSnack("Image select karein", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final result = isEditMode
        ? await CategoryService.updateCategory(
            id: widget.category!.id,
            name: _nameController.text.trim(),
            imageFile: _pickedImage,
          )
        : await CategoryService.addCategory(
            name: _nameController.text.trim(),
            imageFile: _pickedImage!,
          );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result.success) {
      _showSnack(
        isEditMode ? "Category update ho gayi" : "Category add ho gayi",
      );
      Navigator.pop(context, true);
    } else {
      _showSnack(result.message, isError: true);
    }
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
          isEditMode ? "Edit Category" : "Add Category",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // ===== Image Picker =====
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      height: 170,
                      width: 170,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildImagePreview(),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.amber,
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image_rounded, color: Colors.amber.shade700),
                label: Text(
                  _pickedImage != null || isEditMode
                      ? "Image Change Karein"
                      : "Image Select Karein",
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== Form Card =====
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
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon:
                        Icon(Icons.category_rounded, color: Colors.amber.shade700),
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
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Category name required hai";
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditMode ? "Update Category" : "Save Category",
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
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(_pickedImage!, fit: BoxFit.cover),
      );
    }
    if (isEditMode) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(widget.category!.imageUrl, fit: BoxFit.cover),
      );
    }
    return Icon(
      Icons.add_a_photo_rounded,
      size: 40,
      color: Colors.amber.shade700,
    );
  }
}