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

  void _showSnack(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.amber.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.amber.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      _showSnack("Phone aur address required hai");
      return;
    }

    if (selectedServiceIds.isEmpty) {
      _showSnack("Kam az kam ek service select karein");
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      _showSnack("Date aur time select karein");
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
      _showSnack("Booking request send ho gayi hai", isError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
      );
    } else {
      _showSnack(result.message);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.amber.shade700, size: 20),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // halka cream-white
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFFDF5),
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Book Service",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loadingProfile
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ================= PROVIDER CARD =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: widget.provider.image.isNotEmpty
                              ? NetworkImage(widget.provider.image)
                              : null,
                          child: widget.provider.image.isEmpty
                              ? Icon(Icons.person_rounded,
                                  color: Colors.amber.shade700, size: 28)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.provider.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.provider.categoryName,
                                style: TextStyle(
                                  color: Colors.amber.shade50,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= YOUR DETAILS =================
                  _sectionTitle("Your Details"),

                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration(
                      label: "Your Name",
                      icon: Icons.person_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: emailController,
                    decoration: _inputDecoration(
                      label: "Your Email",
                      icon: Icons.email_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: "Phone Number",
                      icon: Icons.phone_rounded,
                      hint: "03xxxxxxxxx",
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

                  const SizedBox(height: 28),

                  // ================= SERVICES =================
                  _sectionTitle("Select Services"),

                  ...widget.provider.services.map((service) {
                    final checked =
                        selectedServiceIds.contains(service.serviceId);

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          if (checked) {
                            selectedServiceIds.remove(service.serviceId);
                          } else {
                            selectedServiceIds.add(service.serviceId);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: checked ? Colors.amber.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: checked
                                ? Colors.amber
                                : Colors.grey.shade200,
                            width: checked ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              checked
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: checked
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade300,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                service.serviceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              "Rs. ${service.price}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 28),

                  // ================= DATE & TIME =================
                  _sectionTitle("Schedule"),

                  Row(
                    children: [
                      Expanded(
                        child: _pickerButton(
                          icon: Icons.calendar_month_rounded,
                          label: selectedDate == null
                              ? "Pick Date"
                              : DateFormat("dd MMM yyyy").format(selectedDate!),
                          selected: selectedDate != null,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _pickerButton(
                          icon: Icons.access_time_rounded,
                          label: selectedTime == null
                              ? "Pick Time"
                              : selectedTime!.format(context),
                          selected: selectedTime != null,
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ================= PAYMENT SUMMARY =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.04),
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Amount",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Rs. ${totalAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Advance Payable (20%)",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Rs. ${advanceAmount.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

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
                          : const Text(
                              "Submit Booking Request",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _pickerButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.amber.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.amber : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? Colors.amber.shade700 : Colors.grey.shade500),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.amber.shade800 : Colors.grey.shade600,
                ),
              ),
            ),
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