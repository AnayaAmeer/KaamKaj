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

  // null == naya profile create karna hai
  // non-null == is profile ko edit karna hai
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

      // naya profile — name/email login se le lo
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


  Future<void> _submit() async {

    if (
      phoneController.text.isEmpty ||
      addressController.text.isEmpty ||
      experienceController.text.isEmpty ||
      aboutController.text.isEmpty ||
      selectedCategory == null || services.isEmpty
    ) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and add at least one service")),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Profile updated. Status: Pending"
                : "Profile submitted. Status: Pending",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // caller (list screen) ko batao ke refresh kar le
      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );

    }

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(isEdit ? "Edit Profile" : "Add New Profile"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [

                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade200,
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

                          ? const Icon(
                              Icons.person,
                              size: 55,
                              color: Colors.grey,
                            )

                          : null,
                    ),

                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Naya profile create karte waqt bhi name/email edit
            // ho sakte hain, taake har profile ki apni detail ho sake
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "03xxxxxxxxx",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            loadingCategories

                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Loading categories..."),
                  )

                : DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
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
    final result = await ServiceService.getServicesByCategory(value);
    if (result.success) {
      setState(() {
        availableServices = result.data;
      });
    }
  }
},
                  ),

            const SizedBox(height: 15),

            TextField(
              controller: experienceController,
              decoration: const InputDecoration(
                labelText: "Experience",
                hintText: "e.g. 3 years",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: aboutController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "About",
                hintText: "Tell customers about your work",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),
            const SizedBox(height: 20),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Services",
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 10),

DropdownButtonFormField<ServiceModel>(
  value: selectedService,
  decoration: const InputDecoration(
    labelText: "Select Service",
    border: OutlineInputBorder(),
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

const SizedBox(height: 12),

TextField(
  controller: servicePriceController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "Price",
    prefixText: "Rs. ",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.add),
    label: const Text("Add Service"),
    onPressed: () {
      if (selectedService == null || servicePriceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a service and enter price")),
        );
        return;
      }

      final alreadyAdded = services.any(
        (s) => s.serviceId == selectedService!.id,
      );

      if (alreadyAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Service already added")),
        );
        return;
      }

      setState(() {
        services.add(
          ProviderServiceModel(
            serviceId: selectedService!.id,
            serviceName: selectedService!.name,
            description: selectedService!.description,
            price: double.parse(servicePriceController.text),
          ),
        );

        selectedService = null;
        servicePriceController.clear();
      });
    },
  ),
),

const SizedBox(height: 15),

ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: services.length,
  itemBuilder: (context, index) {
    final service = services[index];

    return Card(
      child: ListTile(
        title: Text(service.serviceName),
        subtitle: Text("Rs. ${service.price}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
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

const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Available"),
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
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Unavailable"),
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

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitting ? null : _submit,
                child: submitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(isEdit ? "Update Profile" : "Submit Profile"),
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