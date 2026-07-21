class ProviderDashboardModel {
  final ProviderInfo provider;
  final DashboardStats stats;
  final List<RecentRequest> recentRequests;

  ProviderDashboardModel({
    required this.provider,
    required this.stats,
    required this.recentRequests,
  });

  factory ProviderDashboardModel.fromJson(Map<String, dynamic> json) {
    return ProviderDashboardModel(
      provider: ProviderInfo.fromJson(json["provider"] ?? {}),
      stats: DashboardStats.fromJson(json["stats"] ?? {}),
      recentRequests: (json["recentRequests"] as List? ?? [])
          .map((e) => RecentRequest.fromJson(e))
          .toList(),
    );
  }
}

class ProviderInfo {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String image;
  final String category;
  final String about;
  final String experience;
  final String availability;

  ProviderInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.image,
    required this.category,
    required this.about,
    required this.experience,
    required this.availability,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      id: json["_id"] ??
          json["id"] ??
          "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ??
          json["phoneNumber"] ??
          "",
      role: json["role"] ?? "",
      image: json["image"] ?? "",
      category: json["category"] ?? "",
      about: json["about"] ?? "",
      experience: json["experience"]?.toString() ?? "",
      availability: json["availability"] ??
          json["availabilityStatus"] ??
          "",
    );
  }
}

class DashboardStats {
  final int approvedJobs;
  final int pendingJobs;
  final double rating;
  final double earnings;

  DashboardStats({
    required this.approvedJobs,
    required this.pendingJobs,
    required this.rating,
    required this.earnings,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      approvedJobs: json["approvedJobs"] ?? 0,
      pendingJobs: json["pendingJobs"] ?? 0,
      rating: (json["rating"] ?? 0).toDouble(),
      earnings: (json["earnings"] ?? 0).toDouble(),
    );
  }
}

class RecentRequest {
  final String id;
  final String customerName;
  final String category;
  final String providerStatus;

  RecentRequest({
    required this.id,
    required this.customerName,
    required this.category,
    required this.providerStatus,
  });

  factory RecentRequest.fromJson(Map<String, dynamic> json) {
    return RecentRequest(
      id: json["_id"] ??
          json["id"] ??
          "",
      customerName: json["customerName"] ??
          json["customer"] ??
          "",
      category: json["category"] ?? "",
      providerStatus: json["providerStatus"] ??
          json["status"] ??
          "pending",
    );
  }
}