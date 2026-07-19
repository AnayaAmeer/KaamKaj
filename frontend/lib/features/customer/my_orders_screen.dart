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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
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


  Future<void> _payNow(OrderModel order) async {

    setState(() => payingOrderId = order.id);

    final intentResult = await OrderService.createPaymentIntent(order.id);

    if (!mounted) return;

    if (!intentResult.success) {
      setState(() => payingOrderId = "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(intentResult.message), backgroundColor: Colors.red),
      );
      return;
    }

    final clientSecret = intentResult.data as String;

    // Debug: check karo ke client secret sahi aa raha hai ya nahi
    debugPrint("Client secret received: $clientSecret");

    // Payment Sheet ki jagah, apna custom card form modal kholte hain
    setState(() => payingOrderId = "");

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _CardPaymentModal(
        amount: order.advanceAmount,
        clientSecret: clientSecret,
        onSuccess: () async {
          final confirmResult = await OrderService.confirmPayment(order.id);

          if (!mounted) return;

          if (confirmResult.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment successful"),
                backgroundColor: Colors.green,
              ),
            );
            _loadOrders();
          } else {
            debugPrint("Confirm payment failed: ${confirmResult.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(confirmResult.message), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Orders"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),

      body: loading

          ? const Center(child: CircularProgressIndicator())

          : orders.isEmpty

              ? const Center(child: Text("No orders yet"))

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
                                order.providerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

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

                              if (order.providerStatus == "approved" &&
                                  order.paymentStatus == "pending") ...[

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.payment),
                                    label: Text(
                                      payingOrderId == order.id
                                          ? "Processing..."
                                          : "Pay Now (Rs. ${order.advanceAmount.toStringAsFixed(0)})",
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
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

}


// ----------------------------------------------------------------------
// Custom card payment modal — card number, expiry, CVC yahan se enter hote hain
// aur seedha Stripe ko confirm kiya jata hai (Payment Sheet use nahi hota).
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


  Future<void> _submitPayment() async {

    if (!_cardComplete) {
      setState(() => _errorMessage = "Card ki details sahi se bharein (number, expiry, CVC).");
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

      // Yahan tak koi exception nahi aayi to card se payment ho gaya
      if (!mounted) return;

      Navigator.of(context).pop();

      await widget.onSuccess();

    } on StripeException catch (e) {

      debugPrint("STRIPE CARD ERROR: ${e.error.code} - ${e.error.message} - ${e.error.localizedMessage}");

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _errorMessage = e.error.localizedMessage ?? e.error.message ?? "Card payment fail ho gaya.";
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const Text(
                "Card Payment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                "Advance Amount: Rs. ${widget.amount.toStringAsFixed(0)}",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),

              const SizedBox(height: 20),

              // Card number, expiry date, CVC — sab isi ek field me
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CardField(
                  onCardChanged: (cardDetails) {
                    setState(() {
                      _cardComplete = cardDetails?.complete ?? false;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Card number, MM/YY, CVC",
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
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
                      : Text("Pay Rs. ${widget.amount.toStringAsFixed(0)}"),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),

            ],
          ),
        ),
      ),
    );

  }

}