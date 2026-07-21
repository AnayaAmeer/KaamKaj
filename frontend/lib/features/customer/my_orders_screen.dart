import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:intl/intl.dart';

import 'package:my_app/core/models/order_model.dart';
import 'package:my_app/core/services/order_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<OrderModel> orders = [];
  bool loading = true;
  String payingOrderId = "";

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => loading = true);

    final result = await OrderService.getMyOrders();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        orders = result.data;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      _showSnack(result.message);
    }
  }

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

  IconData _statusIcon(String status) {
    switch (status) {
      case "approved":
        return Icons.check_circle_rounded;
      case "rejected":
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  Future<void> _payNow(OrderModel order) async {
    setState(() => payingOrderId = order.id);

    final intentResult = await OrderService.createPaymentIntent(order.id);

    if (!mounted) return;

    if (!intentResult.success) {
      setState(() => payingOrderId = "");
      _showSnack(intentResult.message);
      return;
    }

    final clientSecret = intentResult.data as String;

    debugPrint("Client secret received: $clientSecret");

    setState(() => payingOrderId = "");

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        child: _CardPaymentModal(
          amount: order.advanceAmount,
          clientSecret: clientSecret,
          onSuccess: () async {
            final confirmResult = await OrderService.confirmPayment(order.id);

            if (!mounted) return;

            if (confirmResult.success) {
              _showSnack("Payment successful", isError: false);
              _loadOrders();
            } else {
              _showSnack(confirmResult.message);
            }
          },
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
          "My Orders",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, color: Colors.amber.shade700),
              onPressed: _loadOrders,
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : orders.isEmpty
              ? Center(
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
                          Icons.receipt_long_rounded,
                          size: 44,
                          color: Colors.amber.shade300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No orders yet",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your bookings will show up here",
                        style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.amber,
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final canPay = order.providerStatus == "approved" &&
                          order.paymentStatus == "pending";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.04),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.home_repair_service_rounded,
                                        color: Colors.amber.shade700, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      order.providerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: order.services
                                      .map(
                                        (s) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat("dd MMM yyyy").format(order.bookingDate),
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(width: 14),
                                  Icon(Icons.access_time_rounded,
                                      size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Text(
                                    order.bookingTime,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total: Rs. ${order.totalAmount.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Advance: Rs. ${order.advanceAmount.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _statusChip(
                                    icon: _statusIcon(order.providerStatus),
                                    label: "Provider: ${order.providerStatus.toUpperCase()}",
                                    color: _statusColor(order.providerStatus),
                                  ),
                                  _statusChip(
                                    icon: order.paymentStatus == "paid"
                                        ? Icons.verified_rounded
                                        : Icons.pending_rounded,
                                    label: "Payment: ${order.paymentStatus.toUpperCase()}",
                                    color: order.paymentStatus == "paid"
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ],
                              ),

                              if (canPay) ...[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.payment_rounded, size: 19),
                                    label: Text(
                                      payingOrderId == order.id
                                          ? "Processing..."
                                          : "Pay Now (Rs. ${order.advanceAmount.toStringAsFixed(0)})",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: payingOrderId == order.id
                                        ? null
                                        : () => _payNow(order),
                                  ),
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

  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
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

// ----------------------------------------------------------------------
// Custom card payment modal — card number, expiry, CVC yahan se enter hote hain
// aur seedha Stripe ko confirm kiya jata hai (Payment Sheet use nahi hota).
// Styling ab modern "checkout page" jaisi hai: gradient header, subtle card
// preview strip, soft elevated input, brand icons row.
// ----------------------------------------------------------------------

class _CardPaymentModal extends StatefulWidget {
  final double amount;
  final String clientSecret;
  final Future<void> Function() onSuccess;

  const _CardPaymentModal({
    required this.amount,
    required this.clientSecret,
    required this.onSuccess,
  });

  @override
  State<_CardPaymentModal> createState() => _CardPaymentModalState();
}

class _CardPaymentModalState extends State<_CardPaymentModal> {
  bool _cardComplete = false;
  bool _isProcessing = false;
  String? _errorMessage;

  static const Color _primary = Color(0xFF1A1F36); // deep navy — modern "fintech" tone
  static const Color _accent = Color(0xFFFFB020); // warm amber accent, matches app theme

  Future<void> _submitPayment() async {
    if (!_cardComplete) {
      setState(() =>
          _errorMessage = "Card ki details sahi se bharein (number, expiry, CVC).");
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      await widget.onSuccess();
    } on StripeException catch (e) {
      debugPrint(
          "STRIPE CARD ERROR: ${e.error.code} - ${e.error.message} - ${e.error.localizedMessage}");

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _errorMessage =
            e.error.localizedMessage ?? e.error.message ?? "Card payment fail ho gaya.";
      });
    } catch (e, stackTrace) {
      debugPrint("CARD PAYMENT ERROR: $e");
      debugPrint("STACK TRACE: $stackTrace");

      if (!mounted) return;

      final msg = e.toString().contains("stripeSdk has not been initialized")
          ? "Stripe theek se load nahi hui. App ko band karke dobara kholein."
          : "Payment fail ho gaya: $e";

      setState(() {
        _isProcessing = false;
        _errorMessage = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 430,
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            // FIX: `const` hata diya kyunki BorderRadius.circular() ek const
            // constructor nahi hai — isi wajah se build fail ho raha tha.
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        // FIX: pehle Colors.white tha jo white sheet ke upar
                        // invisible ho raha tha — ab visible grey handle hai.
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),

                  // Header row: icon + title + secure badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.credit_card_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Card Payment",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.lock_rounded,
                                    size: 12, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  "Secured by Stripe",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Amount summary strip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_primary, _primary.withOpacity(0.85)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amount to pay",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rs. ${widget.amount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card details label + accepted brands
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "CARD DETAILS",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Row(
                        children: [
                          _brandBadge("VISA", const Color(0xFF1A1F71)),
                          const SizedBox(width: 6),
                          _brandBadge("MC", const Color(0xFFEB001B)),
                          const SizedBox(width: 6),
                          _brandBadge("AMEX", const Color(0xFF2E77BC)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Modern elevated input container with focus + validation states
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _errorMessage != null
                            ? Colors.red.shade300
                            : (_cardComplete
                                ? Colors.green.shade300
                                : Colors.grey.shade200),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CardField(
                            onCardChanged: (cardDetails) {
                              setState(() {
                                _cardComplete = cardDetails?.complete ?? false;
                                if (_cardComplete) _errorMessage = null;
                              });
                            },
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              hintText: "1234  1234  1234  1234",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: _cardComplete
                              ? Icon(Icons.check_circle_rounded,
                                  key: const ValueKey("ok"),
                                  color: Colors.green.shade500,
                                  size: 20)
                              : const SizedBox(key: ValueKey("empty"), width: 0),
                        ),
                      ],
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: Colors.red.shade400, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Aapki card details encrypted hain aur kabhi save nahi hoti.",
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _primary.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _isProcessing ? null : _submitPayment,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_rounded, size: 17),
                                const SizedBox(width: 8),
                                Text(
                                  "Pay Rs. ${widget.amount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: TextButton(
                      onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}