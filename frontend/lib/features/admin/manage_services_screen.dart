import 'package:flutter/material.dart';
import 'package:my_app/core/models/service_model.dart';
import 'package:my_app/core/services/service_service.dart';
import 'package:my_app/features/admin/add_edit_service_screen.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() =>
      _ManageServicesScreenState();
}

class _ManageServicesScreenState
    extends State<ManageServicesScreen> {
  List<ServiceModel> services = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    setState(() {
      isLoading = true;
    });

    final result = await ServiceService.getAllServices();

    if (!mounted) return;

    if (result.success) {
      services = result.data;
    } else {
      _showSnack(result.message, isError: true);
    }

    setState(() {
      isLoading = false;
    });
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

  Future<void> deleteService(ServiceModel service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Delete Service",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete '${service.name}'? This cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            )
          ],
        );
      },
    );

    if (confirm != true) return;

    final result = await ServiceService.deleteService(service.id);

    if (!mounted) return;

    _showSnack(result.message, isError: !result.success);

    if (result.success) {
      loadServices();
    }
  }

  Future<void> openForm({ServiceModel? service}) async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(service: service),
      ),
    );

    if (refresh == true) {
      loadServices();
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
        title: const Text(
          "Manage Services",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Service",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.amber.shade700),
            )
          : services.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.miscellaneous_services_rounded,
                            size: 50,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "No Services Found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tap \"Add Service\" to create your\nfirst service",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.amber.shade700,
                  onRefresh: loadServices,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];

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
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.design_services_rounded,
                                  color: Colors.amber.shade700,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        service.categoryName,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber.shade700,
                                        ),
                                      ),
                                    ),
                                    if (service.description.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        service.description,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_rounded,
                                      color: Colors.amber.shade700,
                                      size: 21,
                                    ),
                                    onPressed: () {
                                      openForm(service: service);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red.shade400,
                                      size: 21,
                                    ),
                                    onPressed: () {
                                      deleteService(service);
                                    },
                                  ),
                                ],
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