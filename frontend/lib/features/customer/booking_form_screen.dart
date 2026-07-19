import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_app/core/models/provider_profile_model.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/core/services/order_service.dart';
import 'package:my_app/features/customer/my_orders_screen.dart';


class BookingFormScreen extends StatefulWidget {
  final ProviderProfileModel provider;

  const BookingFormScreen({super.key, required this.provider});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}


class _BookingFormScreenState extends State<BookingFormScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final Set<String> selectedServiceIds = {};

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool loadingProfile = true;
  bool submitting = false;


  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }


  Future<void> _loadCustomer() async {

    final result = await AuthService.getProfile();

    if (result.success && result.data != null) {
      nameController.text = result.data!["name"] ?? "";
      emailController.text = result.data!["email"] ?? "";
    }

    if (mounted) setState(() => loadingProfile = false);

  }


  double get totalAmount {
    double total = 0;
    for (final s in widget.provider.services) {
      if (selectedServiceIds.contains(s.serviceId)) {
        total += s.price;
      }
    }
    return total;
  }


  double get advanceAmount =>
      double.parse((totalAmount * 0.2).toStringAsFixed(2));


  Future<void> _pickDate() async {

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }

  }


  Future<void> _pickTime() async {

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }

  }


  Future<void> _submit() async {

    if (phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone aur address required hai")),
      );
      return;

    }

    if (selectedServiceIds.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kam az kam ek service select karein")),
      );
      return;

    }

    if (selectedDate == null || selectedTime == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date aur time select karein")),
      );
      return;

    }

    setState(() => submitting = true);

    final selectedServices = widget.provider.services
        .where((s) => selectedServiceIds.contains(s.serviceId))
        .map((s) => {
              "serviceId": s.serviceId,
              "name": s.serviceName,
              "price": s.price,
            })
        .toList();

    final bookingDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    final timeString = selectedTime!.format(context);

    final result = await OrderService.createOrder(
      providerProfileId: widget.provider.id,
      customerName: nameController.text.trim(),
      customerEmail: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      services: selectedServices,
      bookingDate: bookingDateTime,
      bookingTime: timeString,
    );

    if (!mounted) return;

    setState(() => submitting = false);

    if (result.success) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking request send ho gayi hai"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );

    }

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Book Service")),

      body: loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Your Email",
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

                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Provider",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            widget.provider.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Text(widget.provider.email),

                          const SizedBox(height: 8),

                          Text("Category: ${widget.provider.categoryName}"),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Select Services",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ...widget.provider.services.map((service) {

                    final checked = selectedServiceIds.contains(service.serviceId);

                    return CheckboxListTile(
                      value: checked,
                      title: Text(service.serviceName),
                      subtitle: Text("Rs. ${service.price}"),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedServiceIds.add(service.serviceId);
                          } else {
                            selectedServiceIds.remove(service.serviceId);
                          }
                        });
                      },
                    );

                  }),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month),
                          label: Text(
                            selectedDate == null
                                ? "Pick Date"
                                : DateFormat("dd MMM yyyy").format(selectedDate!),
                          ),
                          onPressed: _pickDate,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            selectedTime == null
                                ? "Pick Time"
                                : selectedTime!.format(context),
                          ),
                          onPressed: _pickTime,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 20),

                  Card(
                    color: Colors.deepPurple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Amount"),
                              Text(
                                "Rs. ${totalAmount.toStringAsFixed(0)}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Advance Payable (20%)"),
                              Text(
                                "Rs. ${advanceAmount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit Booking Request"),
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
    super.dispose();
  }

}