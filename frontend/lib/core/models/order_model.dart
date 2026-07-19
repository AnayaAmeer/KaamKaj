class OrderServiceItem {
  final String serviceId;
  final String name;
  final double price;

  OrderServiceItem({
    required this.serviceId,
    required this.name,
    required this.price,
  });

  factory OrderServiceItem.fromJson(Map<String, dynamic> json) {
    return OrderServiceItem(
      serviceId: json["service"] is Map
          ? (json["service"]["_id"] ?? "")
          : (json["service"] ?? ""),
      name: json["name"] ?? "",
      price: (json["price"] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String providerName;
  final String providerEmail;
  final String providerProfileId;
  final List<OrderServiceItem> services;
  final double totalAmount;
  final double advanceAmount;
  final DateTime bookingDate;
  final String bookingTime;
  final String providerStatus;
  final String paymentStatus;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.providerName,
    required this.providerEmail,
    required this.providerProfileId,
    required this.services,
    required this.totalAmount,
    required this.advanceAmount,
    required this.bookingDate,
    required this.bookingTime,
    required this.providerStatus,
    required this.paymentStatus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json["_id"] ?? "",
      customerName: json["customerName"] ?? "",
      customerEmail: json["customerEmail"] ?? "",
      customerPhone: json["customerPhone"] ?? "",
      customerAddress: json["customerAddress"] ?? "",
      providerName: json["providerName"] ?? "",
      providerEmail: json["providerEmail"] ?? "",
      providerProfileId: json["providerProfile"] is Map
          ? (json["providerProfile"]["_id"] ?? "")
          : (json["providerProfile"]?.toString() ?? ""),
      services: json["services"] == null
          ? []
          : (json["services"] as List)
              .map((e) => OrderServiceItem.fromJson(e))
              .toList(),
      totalAmount: (json["totalAmount"] ?? 0).toDouble(),
      advanceAmount: (json["advanceAmount"] ?? 0).toDouble(),
      bookingDate:
          DateTime.tryParse(json["bookingDate"] ?? "") ?? DateTime.now(),
      bookingTime: json["bookingTime"] ?? "",
      providerStatus: json["providerStatus"] ?? "pending",
      paymentStatus: json["paymentStatus"] ?? "pending",
    );
  }
}