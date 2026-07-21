import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_app/core/models/order_model.dart';
import 'package:my_app/core/services/order_service.dart';


class ProviderOrdersScreen extends StatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}


class _ProviderOrdersScreenState extends State<ProviderOrdersScreen> {

  List<OrderModel> orders = [];
  bool loading = true;


  @override
  void initState() {
    super.initState();
    _loadOrders();
  }


  Future<void> _loadOrders() async {

    setState(() => loading = true);

    final result = await OrderService.getProviderOrders();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        orders = result.data;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

  }


  Future<void> _respond(OrderModel order, String status) async {

    final result = await OrderService.updateProviderOrderStatus(order.id, status);

    if (!mounted) return;

    if (result.success) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order $status"),
          backgroundColor: Colors.green.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      _loadOrders();

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

    }

  }


  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green.shade600;
      case "rejected":
        return Colors.red.shade400;
      default:
        return Colors.amber.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "approved":
        return Icons.check_circle_rounded;
      case "rejected":
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
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
          "Booking Requests",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.amber.shade700),
            onPressed: _loadOrders,
          ),
        ],
      ),

      body: loading

          ? Center(
              child: CircularProgressIndicator(color: Colors.amber.shade700),
            )

          : orders.isEmpty

              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox_outlined,
                            size: 50,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "No Booking Requests Yet",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "New requests from customers will\nshow up here",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              : RefreshIndicator(
                  color: Colors.amber.shade700,
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {

                      final order = orders[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ===== Customer Header =====
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.amber.shade50,
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          order.customerEmail,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),
                              Divider(color: Colors.grey.shade200, height: 1),
                              const SizedBox(height: 14),

                              // ===== Contact Info =====
                              _InfoRow(
                                icon: Icons.phone_rounded,
                                text: order.customerPhone,
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.location_on_rounded,
                                text: order.customerAddress,
                              ),

                              const SizedBox(height: 14),

                              // ===== Services =====
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50.withOpacity(.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    ...order.services.map(
                                      (s) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                s.name,
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "Rs. ${s.price.toStringAsFixed(0)}",
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.amber.shade200,
                                      height: 16,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Total",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${order.totalAmount.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.amber.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Advance (20%)",
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${order.advanceAmount.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              _InfoRow(
                                icon: Icons.event_rounded,
                                text:
                                    "${DateFormat("dd MMM yyyy").format(order.bookingDate)}  •  ${order.bookingTime}",
                              ),

                              const SizedBox(height: 14),

                              // ===== Status Badges =====
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [

                                  _StatusChip(
                                    label:
                                        "Provider: ${order.providerStatus.toUpperCase()}",
                                    color: _statusColor(order.providerStatus),
                                    icon: _statusIcon(order.providerStatus),
                                  ),

                                  _StatusChip(
                                    label:
                                        "Payment: ${order.paymentStatus.toUpperCase()}",
                                    color: order.paymentStatus == "paid"
                                        ? Colors.green.shade600
                                        : Colors.amber.shade700,
                                    icon: order.paymentStatus == "paid"
                                        ? Icons.check_circle_rounded
                                        : Icons.schedule_rounded,
                                  ),

                                ],
                              ),

                              if (order.providerStatus == "pending") ...[

                                const SizedBox(height: 16),

                                Row(
                                  children: [

                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.check_rounded,
                                            size: 20,
                                          ),
                                          label: const Text(
                                            "Accept",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade600,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _respond(order, "approved"),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: OutlinedButton.icon(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                            color: Colors.red.shade400,
                                          ),
                                          label: Text(
                                            "Reject",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red.shade400,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.red.shade200,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _respond(order, "rejected"),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),

                              ],

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


// ===== Helper: Info Row (phone/address/date) =====
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}


// ===== Helper: Status Chip =====
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}