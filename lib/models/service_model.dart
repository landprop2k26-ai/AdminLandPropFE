class ServiceModel {
  final int serviceId;
  final String serviceName;
  final String category;
  final List<SubOption> subOptions;

  ServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.subOptions,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      category: json['category'] ?? '',
      subOptions: (json['subOptions'] as List? ?? [])
          .map((i) => SubOption.fromJson(i))
          .toList(),
    );
  }
}

class SubOption {
  final int subOptionId;
  final String subOptionName;
  final String category;
  final int? serviceId;

  SubOption({
    required this.subOptionId,
    required this.subOptionName,
    required this.category,
    this.serviceId,
  });

  factory SubOption.fromJson(Map<String, dynamic> json) {
    return SubOption(
      subOptionId: json['subOptionId'] ?? 0,
      subOptionName: json['subOptionName'] ?? '',
      category: json['category'] ?? '',
      serviceId: json['serviceId'],
    );
  }
}
