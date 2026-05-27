class Property {
  final String? id; // mapped from saleId or rentalId
  final int serviceId;
  final int subOptionId;
  final String type;
  final String title;
  final String description;
  final double price;
  final PropertyLocation location;
  final int bedrooms;
  final int bathrooms;
  final int areaSqFt;
  final int plotArea;
  final List<String> images;
  final List<String> amenities;
  final String possessionDate; // or availableFrom for rentals
  final PropertyContact contact;

  Property({
    this.id,
    required this.serviceId,
    required this.subOptionId,
    required this.type,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqFt,
    required this.plotArea,
    required this.images,
    required this.amenities,
    required this.possessionDate,
    required this.contact,
  });

  bool get isRental => serviceId == 10;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: (json['saleId'] ?? json['rentalId'])?.toString(),
      serviceId: json['serviceId'] ?? 0,
      subOptionId: json['subOptionId'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: PropertyLocation.fromJson(json['location'] ?? {}),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      areaSqFt: json['areaSqFt'] ?? 0,
      plotArea: json['plotArea'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      possessionDate: json['possessionDate'] ?? json['availableFrom'] ?? '',
      contact: PropertyContact.fromJson(json['contact'] ?? {}),
    );
  }
}

class PropertyLocation {
  final String address;
  final String city;
  final String state;
  final String postalCode;

  PropertyLocation({
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }
}

class PropertyContact {
  final String phone;
  final String email;

  PropertyContact({
    required this.phone,
    required this.email,
  });

  factory PropertyContact.fromJson(Map<String, dynamic> json) {
    return PropertyContact(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
