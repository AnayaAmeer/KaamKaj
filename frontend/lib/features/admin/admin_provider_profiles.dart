import 'package:flutter/material.dart';

import 'package:my_app/core/constants/api_constants.dart';
import 'package:my_app/core/models/provider_profile_model.dart';
import 'package:my_app/core/services/provider_profile_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class AdminProviderProfilesScreen extends StatefulWidget {
  const AdminProviderProfilesScreen({super.key});

  @override
  State<AdminProviderProfilesScreen> createState() =>
      _AdminProviderProfilesScreenState();
}


class _AdminProviderProfilesScreenState
    extends State<AdminProviderProfilesScreen> {

  List<ProviderProfileModel> profiles = [];
  bool loading = true;
  final _formKey = GlobalKey<FormState>();

final nameController = TextEditingController();
final emailController = TextEditingController();
final phoneController = TextEditingController();
final addressController = TextEditingController();
final experienceController = TextEditingController();
final aboutController = TextEditingController();

String availability = "available";

double rating = 0;

String editingId = "";

File? pickedImage;


  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }


  Future<void> _loadProfiles() async {

    setState(() {
      loading = true;
    });

    final result = await ProviderProfileService.getAllProfiles();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        profiles = result.data;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }

  }


  Future<void> _updateStatus(String id, String status) async {

    final result = await ProviderProfileService.updateStatus(id, status);

    if (!mounted) return;

    if (result.success) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile $status"),
          backgroundColor: Colors.green,
        ),
      );

      _loadProfiles();

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );

    }

  }


  Future<void> _publish(String id) async {

    final result = await ProviderProfileService.publishProfile(id);

    if (!mounted) return;

    if (result.success) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile published"),
          backgroundColor: Colors.green,
        ),
      );

      _loadProfiles();

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );

    }

  }


  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
  Future<void> _deleteProvider(String id) async {

  final confirm = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
  insetPadding: const EdgeInsets.symmetric(
    horizontal: 20,
  ),
        title: const Text("Delete Provider"),
        content: const Text(
          "Are you sure you want to delete this provider?"
        ),
        actions: [

          TextButton(
            onPressed: (){
              Navigator.pop(context,false);
            },
            child: const Text("Cancel"),
          ),


          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: (){
              Navigator.pop(context,true);
            },
            child: const Text("Delete"),
          ),

        ],
      );
    },
  );


  if(confirm != true) return;


  final result =
      await ProviderProfileService.adminDeleteProfile(id);


  if(!mounted) return;


  if(result.success){

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Provider deleted successfully"),
        backgroundColor: Colors.green,
      ),
    );


    _loadProfiles();

  }
  else{

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: Colors.red,
      ),
    );

  }

}
void _showEditDialog(ProviderProfileModel profile){

  nameController.text = profile.name;
  emailController.text = profile.email;
  phoneController.text = profile.phone;
  addressController.text = profile.address;
  experienceController.text = profile.experience;
  aboutController.text = profile.about;

  rating = profile.rating;


  showDialog(
    context: context,
    builder: (context){

      return StatefulBuilder(
        builder: (context,setState){


          return AlertDialog(

            title: const Text(
              "Edit Provider"
            ),


            content: SingleChildScrollView(

              child: Column(
                children: [

                  TextField(
                    controller: nameController,
                    decoration:
                    const InputDecoration(
                      labelText:"Name"
                    ),
                  ),


                  TextField(
                    controller: emailController,
                    decoration:
                    const InputDecoration(
                      labelText:"Email"
                    ),
                  ),


                  TextField(
                    controller: phoneController,
                    decoration:
                    const InputDecoration(
                      labelText:"Phone"
                    ),
                  ),


                  TextField(
                    controller: addressController,
                    decoration:
                    const InputDecoration(
                      labelText:"Address"
                    ),
                  ),


                  TextField(
                    controller: experienceController,
                    decoration:
                    const InputDecoration(
                      labelText:"Experience"
                    ),
                  ),


                  TextField(
                    controller: aboutController,
                    maxLines:3,
                    decoration:
                    const InputDecoration(
                      labelText:"About"
                    ),
                  ),


                  const SizedBox(height:15),


                  const Text(
                    "Give Rating"
                  ),


                 SizedBox(
  width: double.infinity,
  child: Wrap(
    alignment: WrapAlignment.center,
    children: List.generate(
      5,
      (index) {

        return IconButton(
          padding: EdgeInsets.zero,

          constraints: const BoxConstraints(
            minWidth: 35,
            minHeight: 35,
          ),

          onPressed: () {

            setState(() {

              rating = index + 1.0;

            });

          },

          icon: Icon(
            index < rating
                ? Icons.star
                : Icons.star_border,

            color: Colors.amber,
            size: 28,
          ),
        );

      },
    ),
  ),
),


                ],
              ),

            ),



            actions: [


              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child:
                const Text("Cancel"),
              ),



              ElevatedButton(

                onPressed: () async{


                  final result =
                 await ProviderProfileService.adminUpdateProfile(
  id: profile.id,
  name: nameController.text,
  email: emailController.text,
  phone: phoneController.text,
  address: addressController.text,
  experience: experienceController.text,
  about: aboutController.text,
  category: profile.categoryId,
  availabilityStatus: availability,
  status: profile.status,
  published: profile.published,
  rating: rating,
  image: pickedImage,
);


                  if(result.success){

                    Navigator.pop(context);

                    _loadProfiles();

                  }


                },


                child:
                const Text("Save"),

              )


            ],


          );


        },
      );


    },
  );

}


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Provider Profiles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
          ),
        ],
      ),

      body: loading

          ? const Center(child: CircularProgressIndicator())

          : profiles.isEmpty

              ? const Center(child: Text("No Provider Profiles Found"))

              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {

                    final profile = profiles[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: profile.image.isNotEmpty
    ? NetworkImage(profile.image)
    : null,
                                  child: profile.image.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        profile.categoryName,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),

                            const SizedBox(height: 10),

                            Text("Email: ${profile.email}"),
                            Text("Phone: ${profile.phone}"),
                            Text("Address: ${profile.address}"),
                            Text("Experience: ${profile.experience}"),

                            const SizedBox(height: 6),

                            const Text("About:"),
                            Text(profile.about),

                            if (profile.services.isNotEmpty) ...[

                              const SizedBox(height: 10),

                              const Text(
                                "Services:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              ...profile.services.map(
                                (service) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      const Icon(
                                        Icons.miscellaneous_services,
                                        size: 18,
                                        color: Colors.blue,
                                      ),

                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [

                                            Text(
                                              service.serviceName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            if (service.description.isNotEmpty)
                                              Text(
                                                service.description,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),

                                            Text(
                                              "Rs. ${service.price}",
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),

                            ],

                            const SizedBox(height: 6),

                            Text(
                              "Availability: ${profile.availabilityStatus == "available" ? "Available" : "Unavailable"}",
                            ),

                           
                            const SizedBox(height: 8),

Row(
  children: List.generate(
    5,
    (index) => Icon(
      index < profile.rating
          ? Icons.star
          : Icons.star_border,
      color: Colors.amber,
      size: 20,
    ),
  ),
),

const SizedBox(height: 8),

Text("Rating : ${profile.rating}/5"),

                            Wrap(
                              spacing: 8,
                              children: [

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(profile.status)
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    profile.status.toUpperCase(),
                                    style: TextStyle(
                                      color: _statusColor(profile.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                if (profile.published)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "PUBLISHED",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                              ],
                            ),
                            const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.edit),
    label: const Text("Edit"),
    onPressed: () {
      _showEditDialog(profile);
    },
  ),
),
const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
    ),
    icon: const Icon(Icons.delete),
    label: const Text("Delete"),
    onPressed: () {
      _deleteProvider(profile.id);
    },
  ),
),

                            const SizedBox(height: 15),

                            // Approve / Reject buttons
                            Row(
                              children: [

                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    label: const Text("Approve"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          profile.status == "approved"
                                              ? Colors.grey
                                              : Colors.green,
                                    ),
                                    onPressed: profile.status == "approved"
                                        ? null
                                        : () => _updateStatus(
                                              profile.id,
                                              "approved",
                                            ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.close),
                                    label: const Text("Reject"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          profile.status == "rejected"
                                              ? Colors.grey
                                              : Colors.red,
                                    ),
                                    onPressed: profile.status == "rejected"
                                        ? null
                                        : () => _updateStatus(
                                              profile.id,
                                              "rejected",
                                            ),
                                  ),
                                ),

                              ],
                            ),

                            // Publish button - sirf approved par dikhega
                            if (profile.status == "approved" &&
                                !profile.published) ...[

                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.publish),
                                  label: const Text("Publish"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  onPressed: () => _publish(profile.id),
                                ),
                              ),

                            ],

                          ],
                        ),
                      ),
                    );

                  },
                ),

    );

  }

}