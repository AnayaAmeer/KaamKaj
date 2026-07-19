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
        SnackBar(content: Text(result.message)),
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
          backgroundColor: Colors.green,
        ),
      );

      _loadOrders();

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Booking Requests"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),

      body: loading

          ? const Center(child: CircularProgressIndicator())

          : orders.isEmpty

              ? const Center(child: Text("No booking requests yet"))

              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {

                      final order = orders[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                order.customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              Text(order.customerEmail),
                              Text(order.customerPhone),
                              Text(order.customerAddress),

                              const SizedBox(height: 8),

                              ...order.services.map(
                                (s) => Text("${s.name} - Rs. ${s.price.toStringAsFixed(0)}"),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Date: ${DateFormat("dd MMM yyyy").format(order.bookingDate)}  |  Time: ${order.bookingTime}",
                              ),

                              const SizedBox(height: 6),

                              Text("Total: Rs. ${order.totalAmount.toStringAsFixed(0)}"),
                              Text(
                                "Advance (20%): Rs. ${order.advanceAmount.toStringAsFixed(0)}",
                              ),

                              const SizedBox(height: 10),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order.providerStatus)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "Provider: ${order.providerStatus.toUpperCase()}",
                                      style: TextStyle(
                                        color: _statusColor(order.providerStatus),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (order.paymentStatus == "paid"
                                              ? Colors.green
                                              : Colors.orange)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "Payment: ${order.paymentStatus.toUpperCase()}",
                                      style: TextStyle(
                                        color: order.paymentStatus == "paid"
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                              if (order.providerStatus == "pending") ...[

                                const SizedBox(height: 12),

                                Row(
                                  children: [

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text("Accept"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () => _respond(order, "approved"),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: const Text("Reject"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () => _respond(order, "rejected"),
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