enum PropertyStatus { active, sold, rented }
enum PropertyType { land, rental, flat, plot, office }

class Property {
  final String id;
  final String title;
  final String location;
  final PropertyType type;
  final PropertyStatus status;
  final double price;
  final String size;
  final String? imageUrl;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.status,
    required this.price,
    required this.size,
    this.imageUrl,
  });
}
