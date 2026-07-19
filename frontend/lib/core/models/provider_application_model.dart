class ProviderApplicationModel {

  final String id;
  final String name;
  final String email;
  final String phone;

  // ab multi-select hai, isliye list of category names
  final List<String> categories;

  final String interestReason;
  final String status;


  ProviderApplicationModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.categories,
    required this.interestReason,
    required this.status,
  });



  factory ProviderApplicationModel.fromJson(
      Map<String,dynamic> json){

    // backend "category" ko populate karta hai, ye ek array
    // of {_id, name} objects hoti hai (multi-select)

    final rawCategories =
        json["category"] as List<dynamic>? ?? [];

    final categoryNames = rawCategories
        .map((c) => (c is Map)
            ? (c["name"]?.toString() ?? "")
            : c.toString())
        .where((name) => name.isNotEmpty)
        .toList();

    return ProviderApplicationModel(

      id: json["_id"] ?? "",

      name: json["name"] ?? "",

      email: json["email"] ?? "",

      phone: json["phone"] ?? "",


      categories: categoryNames,


      interestReason:
      json["interestReason"] ?? "",


      status:
      json["status"] ?? "pending",

    );

  }

}