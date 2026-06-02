class ServiceDetails {
  final String id;
  final int serviceId;
  final int subOptionId;
  final int categoryId;
  final String name;
  final String category;
  final List<DetailedSubCategory> subCategories;

  ServiceDetails({
    required this.id,
    required this.serviceId,
    required this.subOptionId,
    required this.categoryId,
    required this.name,
    required this.category,
    required this.subCategories,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? 0,
      subOptionId: json['subOptionId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subCategories: (json['subCategories'] as List? ?? [])
          .map((i) => DetailedSubCategory.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "serviceId": serviceId,
      "subOptionId": subOptionId,
      "categoryId": categoryId,
      "name": name,
      "category": category,
      "subCategories": subCategories.map((i) => i.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "categoryId": categoryId,
      "name": name,
      "category": category,
      "subCategories": subCategories.map((i) => i.toJson()).toList(),
    };
  }
}

class DetailedSubCategory {
  final String subCategoryName;
  final double rating;
  final int reviews;
  final double price;
  final String time;
  final int subCategoryId;

  DetailedSubCategory({
    required this.subCategoryName,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.time,
    required this.subCategoryId,
  });

  factory DetailedSubCategory.fromJson(Map<String, dynamic> json) {
    return DetailedSubCategory(
      subCategoryName: json['subCategoryName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      time: json['time'] ?? '',
      subCategoryId: json['subCategoryId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "subCategoryName": subCategoryName,
      "rating": rating,
      "reviews": reviews,
      "price": price,
      "time": time,
      "subCategoryId": subCategoryId,
    };
  }
}
