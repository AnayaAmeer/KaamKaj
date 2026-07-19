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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteService(ServiceModel service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Service"),
          content: Text(
            "Delete '${service.name}' ?",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Delete"),
            )
          ],
        );
      },
    );

    if (confirm != true) return;

    final result =
        await ServiceService.deleteService(service.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.success) {
      loadServices();
    }
  }

  Future<void> openForm(
      {ServiceModel? service}) async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEditServiceScreen(service: service),
      ),
    );

    if (refresh == true) {
      loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Services"),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => openForm(),
        icon: const Icon(Icons.add),
        label: const Text("Add Service"),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : services.isEmpty
              ? const Center(
                  child: Text(
                    "No Services Found",
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadServices,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(12),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service =
                          services[index];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          title: Text(
                            service.name,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                service.categoryName,
                              ),

                              if (service
                                  .description
                                  .isNotEmpty)
                                Text(
                                  service
                                      .description,
                                ),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color:
                                      Colors.blue,
                                ),
                                onPressed: () {
                                  openForm(
                                    service:
                                        service,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red,
                                ),
                                onPressed: () {
                                  deleteService(
                                      service);
                                },
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