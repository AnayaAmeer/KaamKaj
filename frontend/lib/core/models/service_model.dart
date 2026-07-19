class ServiceModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json["_id"] ?? "",
      categoryId: json["category"] is Map
          ? (json["category"]["_id"] ?? "")
          : (json["category"] ?? ""),
      categoryName: json["category"] is Map
          ? (json["category"]["name"] ?? "")
          : "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      isActive: json["isActive"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "category": categoryId,
      "name": name,
      "description": description,
      "isActive": isActive,
    };
  }
}