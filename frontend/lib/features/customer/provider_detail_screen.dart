import 'package:flutter/material.dart';

import 'package:my_app/core/models/provider_profile_model.dart';
import 'package:my_app/features/customer/booking_form_screen.dart';


class ProviderDetailScreen extends StatelessWidget {

  final ProviderProfileModel provider;

  const ProviderDetailScreen({super.key, required this.provider});


  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(provider.name),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: provider.image.isNotEmpty
                    ? NetworkImage(provider.image)
                    : null,
                child: provider.image.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                provider.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                provider.categoryName,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < provider.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "${provider.rating}/5",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 10),

            _infoTile(Icons.email, "Email", provider.email),
            _infoTile(Icons.phone, "Phone", provider.phone),
            _infoTile(Icons.location_on, "Address", provider.address),
            _infoTile(
              Icons.work_history,
              "Experience",
              provider.experience,
            ),
            _infoTile(
              Icons.circle,
              "Availability",
              provider.availabilityStatus == "available"
                  ? "Available"
                  : "Unavailable",
            ),
            _infoTile(Icons.info_outline, "About", provider.about),

            if (provider.services.isNotEmpty) ...[

              const SizedBox(height: 10),

              const Divider(),

              const SizedBox(height: 10),

              const Text(
                "Services Offered",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...provider.services.map(
                (service) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.miscellaneous_services,
                      color: Colors.deepPurple,
                    ),
                    title: Text(
                      service.serviceName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: service.description.isNotEmpty
                        ? Text(service.description)
                        : null,
                    trailing: Text(
                      "Rs. ${service.price}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            ],

            // Book button ke liye jagah, taake content ke neeche
            // chup na jaye
            const SizedBox(height: 80),

          ],
        ),
      ),

      // Book button hamesha neeche fixed rahega
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label: const Text(
              "Book",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            onPressed: provider.availabilityStatus == "available"
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingFormScreen(provider: provider),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),

    );

  }

}