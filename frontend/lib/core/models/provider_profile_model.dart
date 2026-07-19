class ProviderServiceModel {
  final String serviceId;
  final String serviceName;
  final String description;
  final double price;

  ProviderServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.description,
    required this.price,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    final service = json["service"];

    return ProviderServiceModel(
      serviceId: service is Map
          ? (service["_id"] ?? "")
          : (service ?? ""),

      serviceName: service is Map
          ? (service["name"] ?? "")
          : "",

      description: service is Map
          ? (service["description"] ?? "")
          : "",

      price: (json["price"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "service": serviceId,
      "price": price,
    };
  }
}

class ProviderProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  final String image;
  final String imagePublicId;

  final String experience;
  final String about;

  final String categoryId;
  final String categoryName;

  final List<ProviderServiceModel> services;

  final String availabilityStatus;
  final String status;
  final bool published;

  final double rating;

  ProviderProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.image,
    required this.imagePublicId,
    required this.experience,
    required this.about,
    required this.categoryId,
    required this.categoryName,
    required this.services,
    required this.availabilityStatus,
    required this.status,
    required this.published,
    required this.rating,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    final category = json["category"];

    return ProviderProfileModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",

      image: json["image"] ?? "",
      imagePublicId: json["imagePublicId"] ?? "",

      experience: json["experience"] ?? "",
      about: json["about"] ?? "",

      categoryId: category is Map
          ? (category["_id"] ?? "")
          : (category?.toString() ?? ""),

      categoryName: category is Map
          ? (category["name"] ?? "")
          : "",

      services: json["services"] == null
          ? []
          : (json["services"] as List)
              .map((e) => ProviderServiceModel.fromJson(e))
              .toList(),

      availabilityStatus:
          json["availabilityStatus"] ?? "available",

      status: json["status"] ?? "pending",

      published: json["published"] ?? false,

      rating: (json["rating"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "image": image,
      "imagePublicId": imagePublicId,
      "experience": experience,
      "about": about,
      "category": categoryId,
      "services": services.map((e) => e.toJson()).toList(),
      "availabilityStatus": availabilityStatus,
      "status": status,
      "published": published,
      "rating": rating,
    };
  }
}