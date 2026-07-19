import 'package:flutter/material.dart';

import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/models/provider_profile_model.dart';
import 'package:my_app/core/services/provider_profile_service.dart';
import 'package:my_app/features/customer/provider_detail_screen.dart';


class CategoryProvidersScreen extends StatefulWidget {

  final CategoryModel category;

  const CategoryProvidersScreen({super.key, required this.category});

  @override
  State<CategoryProvidersScreen> createState() =>
      _CategoryProvidersScreenState();
}


class _CategoryProvidersScreenState extends State<CategoryProvidersScreen> {

  List<ProviderProfileModel> providers = [];
  bool loading = true;


  @override
  void initState() {
    super.initState();
    _loadProviders();
  }


  Future<void> _loadProviders() async {

    setState(() {
      loading = true;
    });

    final result =
        await ProviderProfileService.getProvidersByCategory(
      widget.category.id,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        providers = result.data;
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProviders,
          ),
        ],
      ),

      body: loading

          ? const Center(child: CircularProgressIndicator())

          : providers.isEmpty

              ? const Center(
                  child: Text(
                    "No providers available in this category yet",
                    textAlign: TextAlign.center,
                  ),
                )

              : RefreshIndicator(
                  onRefresh: _loadProviders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: providers.length,
                    itemBuilder: (context, index) {

                      final provider = providers[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProviderDetailScreen(
                                  provider: provider,
                                ),
                              ),
                            );
                          },

                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: provider.image.isNotEmpty
                                ? NetworkImage(provider.image)
                                : null,
                            child: provider.image.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),

                          title: Text(
                            provider.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "Experience: ${provider.experience}",
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  children: [

                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        i < provider.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),

                                    const SizedBox(width: 6),

                                    Text(
                                      "(${provider.rating})",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                  ],
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  children: [

                                    Icon(
                                      Icons.circle,
                                      size: 10,
                                      color:
                                          provider.availabilityStatus ==
                                                  "available"
                                              ? Colors.green
                                              : Colors.red,
                                    ),

                                    const SizedBox(width: 6),

                                    Text(
                                      provider.availabilityStatus ==
                                              "available"
                                          ? "Available"
                                          : "Unavailable",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                  ],
                                ),

                              ],
                            ),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,
                          ),

                          isThreeLine: true,

                        ),
                      );

                    },
                  ),
                ),

    );

  }

}