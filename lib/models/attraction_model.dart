class AttractionModel {
  final String id;
  final String name;
  final String cityId;
  final String category;
  final String description;
  final List<String> imageUrls;
  final LocationData location;
  final ContactInfo contactInfo;
  final Map<String, String> openingHours;
  final String website;
  final double averageRating;
  final int reviewCount;
  final String priceRange;

  AttractionModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.category,
    required this.description,
    this.imageUrls = const [],
    required this.location,
    required this.contactInfo,
    this.openingHours = const {},
    this.website = '',
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.priceRange = '',
  });

  // From JSON
  factory AttractionModel.fromJson(Map<String, dynamic> json, String id) {
    return AttractionModel(
      id: id,
      name: json['name'] ?? '',
      cityId: json['cityId'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      location: LocationData.fromJson(Map<String, dynamic>.from(json['location'] ?? {})),
      contactInfo: ContactInfo.fromJson(Map<String, dynamic>.from(json['contactInfo'] ?? {})),
      openingHours: json['openingHours'] != null 
          ? Map<String, String>.from(json['openingHours'])
          : {},
      website: json['website'] ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      priceRange: json['priceRange'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cityId': cityId,
      'category': category,
      'description': description,
      'imageUrls': imageUrls,
      'location': location.toJson(),
      'contactInfo': contactInfo.toJson(),
      'openingHours': openingHours,
      'website': website,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'priceRange': priceRange,
    };
  }

  // Copy with
  AttractionModel copyWith({
    String? id,
    String? name,
    String? cityId,
    String? category,
    String? description,
    List<String>? imageUrls,
    LocationData? location,
    ContactInfo? contactInfo,
    Map<String, String>? openingHours,
    String? website,
    double? averageRating,
    int? reviewCount,
    String? priceRange,
  }) {
    return AttractionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      contactInfo: contactInfo ?? this.contactInfo,
      openingHours: openingHours ?? this.openingHours,
      website: website ?? this.website,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceRange: priceRange ?? this.priceRange,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address = '',
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class ContactInfo {
  final String phone;
  final String webUrl;
  final String email;

  ContactInfo({
    this.phone = '',
    this.webUrl = '',
    this.email = '',
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] ?? '',
      webUrl: json['webUrl'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'webUrl': webUrl,
      'email': email,
    };
  }
}
