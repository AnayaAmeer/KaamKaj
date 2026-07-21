import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/models/provider_profile_model.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/core/services/category_service.dart';
import 'package:my_app/core/services/provider_profile_service.dart';
import 'package:my_app/core/models/service_model.dart';
import 'package:my_app/core/services/service_service.dart';


class ProviderProfileFormScreen extends StatefulWidget {

  final ProviderProfileModel? existingProfile;

  const ProviderProfileFormScreen({super.key, this.existingProfile});

  @override
  State<ProviderProfileFormScreen> createState() =>
      _ProviderProfileFormScreenState();
}


class _ProviderProfileFormScreenState
    extends State<ProviderProfileFormScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final experienceController = TextEditingController();
  final aboutController = TextEditingController();
  final servicePriceController = TextEditingController();

  List<CategoryModel> categories = [];
  List<ServiceModel> availableServices = [];
  ServiceModel? selectedService;
  List<ProviderServiceModel> services = [];
  String? selectedCategory;
  String availabilityStatus = "available";

  File? pickedImage;

  bool loadingCategories = true;
  bool submitting = false;

  bool get isEdit => widget.existingProfile != null;


  @override
  void initState() {
    super.initState();
    _init();
  }


  Future<void> _init() async {

    await _loadCategories();

    if (isEdit) {

      final profile = widget.existingProfile!;

      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      addressController.text = profile.address;
      experienceController.text = profile.experience;
      aboutController.text = profile.about;
      selectedCategory = profile.categoryId;

      availabilityStatus = profile.availabilityStatus;
      services = List<ProviderServiceModel>.from(profile.services);

    } else {

      final userResult = await AuthService.getProfile();

      if (userResult.success && userResult.data != null) {
        nameController.text = userResult.data!["name"] ?? "";
        emailController.text = userResult.data!["email"] ?? "";
      }

    }

    if (mounted) setState(() {});

  }


  Future<void> _loadCategories() async {

    final result = await CategoryService.getCategories();

    if (result.success) {
      setState(() {
        categories = result.data;
        loadingCategories = false;
      });
    } else {
      setState(() {
        loadingCategories = false;
      });
    }

  }


  Future<void> _pickImage() async {

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }

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


  Future<void> _submit() async {

    if (
      phoneController.text.isEmpty ||
      addressController.text.isEmpty ||
      experienceController.text.isEmpty ||
      aboutController.text.isEmpty ||
      selectedCategory == null || services.isEmpty
    ) {

      _showSnack(
        "Please fill all fields and add at least one service",
        isError: true,
      );

      return;

    }

    setState(() {
      submitting = true;
    });

    final result = isEdit

        ? await ProviderProfileService.updateProfile(
            id: widget.existingProfile!.id,
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            address: addressController.text.trim(),
            experience: experienceController.text.trim(),
            about: aboutController.text.trim(),
            category: selectedCategory!,
            services: services,
            availabilityStatus: availabilityStatus,
            image: pickedImage,
          )

        : await ProviderProfileService.submitProfile(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            address: addressController.text.trim(),
            experience: experienceController.text.trim(),
            about: aboutController.text.trim(),
            category: selectedCategory!,
            services: services,
            availabilityStatus: availabilityStatus,
            image: pickedImage,
          );

    setState(() {
      submitting = false;
    });

    if (!mounted) return;

    if (result.success) {

      _showSnack(
        isEdit
            ? "Profile updated. Status: Pending"
            : "Profile submitted. Status: Pending",
      );

      Navigator.pop(context, true);

    } else {

      _showSnack(result.message, isError: true);

    }

  }


  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.amber.shade700)
          : null,
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
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
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
          isEdit ? "Edit Profile" : "Add New Profile",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ===== Profile Image =====
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.amber.shade50,
                        backgroundImage: pickedImage != null

                            ? FileImage(pickedImage!)

                            : (isEdit &&
                                    widget.existingProfile!.image.isNotEmpty)

                                ? NetworkImage(
                                    widget.existingProfile!.image,
                                  ) as ImageProvider

                                : null,

                        child: (pickedImage == null &&
                                (!isEdit ||
                                    widget.existingProfile!.image.isEmpty))

                            ? Icon(
                                Icons.person_rounded,
                                size: 55,
                                color: Colors.amber.shade700,
                              )

                            : null,
                      ),
                    ),

                    Positioned(
                      bottom: 2,
                      right: 2,
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
            ),

            const SizedBox(height: 30),

            // ===== Basic Info Card =====
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
              child: Column(
                children: [

                  _sectionTitle("Basic Information"),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration(
                      label: "Name",
                      icon: Icons.badge_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: emailController,
                    decoration: _inputDecoration(
                      label: "Email",
                      icon: Icons.email_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: "Phone Number",
                      hint: "03xxxxxxxxx",
                      icon: Icons.phone_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: addressController,
                    decoration: _inputDecoration(
                      label: "Address",
                      icon: Icons.location_on_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  loadingCategories

                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Loading categories...",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )

                      : DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: _inputDecoration(
                            label: "Category",
                            icon: Icons.category_rounded,
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              selectedCategory = value;
                              selectedService = null;
                              availableServices = [];
                            });

                            if (value != null) {
                              final result = await ServiceService
                                  .getServicesByCategory(value);
                              if (result.success) {
                                setState(() {
                                  availableServices = result.data;
                                });
                              }
                            }
                          },
                        ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: experienceController,
                    decoration: _inputDecoration(
                      label: "Experience",
                      hint: "e.g. 3 years",
                      icon: Icons.work_history_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: aboutController,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      label: "About",
                      hint: "Tell customers about your work",
                      icon: Icons.info_rounded,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== Services Card =====
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
              child: Column(
                children: [

                  _sectionTitle("Services"),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<ServiceModel>(
                    value: selectedService,
                    decoration: _inputDecoration(
                      label: "Select Service",
                      icon: Icons.design_services_rounded,
                    ),
                    items: availableServices.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedService = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: servicePriceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Price",
                      prefixText: "Rs. ",
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: Icon(
                        Icons.add_rounded,
                        color: Colors.amber.shade700,
                      ),
                      label: Text(
                        "Add Service",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.amber.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (selectedService == null ||
                            servicePriceController.text.isEmpty) {
                          _showSnack(
                            "Select a service and enter price",
                            isError: true,
                          );
                          return;
                        }

                        final alreadyAdded = services.any(
                          (s) => s.serviceId == selectedService!.id,
                        );

                        if (alreadyAdded) {
                          _showSnack("Service already added", isError: true);
                          return;
                        }

                        setState(() {
                          services.add(
                            ProviderServiceModel(
                              serviceId: selectedService!.id,
                              serviceName: selectedService!.name,
                              description: selectedService!.description,
                              price: double.parse(
                                  servicePriceController.text),
                            ),
                          );

                          selectedService = null;
                          servicePriceController.clear();
                        });
                      },
                    ),
                  ),

                  if (services.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50.withOpacity(.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.amber.shade100,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              service.serviceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.5,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              "Rs. ${service.price}",
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red.shade400,
                              ),
                              onPressed: () {
                                setState(() {
                                  services.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== Availability Card =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 10),
                    child: _sectionTitle("Availability"),
                  ),
                  Row(
                    children: [

                      Expanded(
                        child: RadioListTile<String>(
                          activeColor: Colors.amber.shade700,
                          title: const Text(
                            "Available",
                            style: TextStyle(fontSize: 13.5),
                          ),
                          value: "available",
                          groupValue: availabilityStatus,
                          onChanged: (value) {
                            setState(() {
                              availabilityStatus = value!;
                            });
                          },
                        ),
                      ),

                      Expanded(
                        child: RadioListTile<String>(
                          activeColor: Colors.amber.shade700,
                          title: const Text(
                            "Unavailable",
                            style: TextStyle(fontSize: 13.5),
                          ),
                          value: "unavailable",
                          groupValue: availabilityStatus,
                          onChanged: (value) {
                            setState(() {
                              availabilityStatus = value!;
                            });
                          },
                        ),
                      ),

                    ],
                  ),
                ],
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
                onPressed: submitting ? null : _submit,
                child: submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? "Update Profile" : "Submit Profile",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

          ],
        ),
      ),

    );

  }


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    experienceController.dispose();
    aboutController.dispose();
    servicePriceController.dispose();
    super.dispose();
  }

}