import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_app/core/models/order_model.dart';
import 'package:my_app/core/services/order_service.dart';

/// ================= COLOR PALETTE (White + Yellow / Amber) =================
class _AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryYellow = Color(0xFFFFC107); // Amber 500
  static const Color darkYellow = Color(0xFFFFA000); // Amber 700
  static const Color lightYellow = Color(0xFFFFF8E1); // Amber 50
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color approvedBg = Color(0xFFE8F5E9);
  static const Color approvedText = Color(0xFF2E7D32);
  static const Color rejectedBg = Color(0xFFFDECEA);
  static const Color rejectedText = Color(0xFFC62828);
  static const Color pendingBg = Color(0xFFFFF3E0);
  static const Color pendingText = Color(0xFFEF6C00);
  static const Color divider = Color(0xFFF0F0F0);
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<OrderModel> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ================= GET ORDERS =================

  Future<void> _loadOrders() async {
    setState(() => loading = true);

    final result = await OrderService.getAllOrdersAdmin();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        orders = result.data;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      _showSnackBar(result.message, isError: true);
    }
  }

  // ================= HELPERS =================

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor:
            isError ? _AppColors.rejectedText : _AppColors.darkYellow,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Map<String, Color> _statusColors(String status) {
    switch (status) {
      case "approved":
      case "paid":
        return {"bg": _AppColors.approvedBg, "text": _AppColors.approvedText};
      case "rejected":
        return {"bg": _AppColors.rejectedBg, "text": _AppColors.rejectedText};
      default:
        return {"bg": _AppColors.pendingBg, "text": _AppColors.pendingText};
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "All Orders",
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: _AppColors.lightYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: _AppColors.darkYellow),
              onPressed: _loadOrders,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _AppColors.divider, height: 1),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: _AppColors.primaryYellow,
              ),
            )
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No orders yet",
                        style: TextStyle(
                          color: _AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: _AppColors.darkYellow,
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final providerStatusColor =
                          _statusColors(order.providerStatus);
                      final paymentStatusColor =
                          _statusColors(order.paymentStatus);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: _AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _AppColors.divider),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
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
                              // ---------- Customer -> Provider ----------
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.customerName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: _AppColors.darkYellow,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      order.providerName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _AppColors.textPrimary,
                                      ),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ---------- Services ----------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _AppColors.lightYellow.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: order.services.map((s) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.name,
                                              style: const TextStyle(
                                                color: _AppColors.textPrimary,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Rs. ${s.price.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              color: _AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ---------- Date / Time ----------
                              _InfoRow(
                                icon: Icons.calendar_today_outlined,
                                text:
                                    "${DateFormat("dd MMM yyyy").format(order.bookingDate)}  •  ${order.bookingTime}",
                              ),

                              const SizedBox(height: 10),
                              Divider(color: _AppColors.divider, height: 1),
                              const SizedBox(height: 10),

                              // ---------- Amounts ----------
                              Row(
                                children: [
                                  Expanded(
                                    child: _AmountBlock(
                                      label: "Total",
                                      value: order.totalAmount,
                                    ),
                                  ),
                                  Expanded(
                                    child: _AmountBlock(
                                      label: "Advance",
                                      value: order.advanceAmount,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ---------- Status Badges ----------
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: providerStatusColor["bg"],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Provider: ${order.providerStatus.toUpperCase()}",
                                      style: TextStyle(
                                        color: providerStatusColor["text"],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: paymentStatusColor["bg"],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Payment: ${order.paymentStatus.toUpperCase()}",
                                      style: TextStyle(
                                        color: paymentStatusColor["text"],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
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

/// ================= Small reusable info row =================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// ================= Total / Advance amount block =================
class _AmountBlock extends StatelessWidget {
  final String label;
  final double value;

  const _AmountBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Rs. ${value.toStringAsFixed(0)}",
          style: const TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}