class CityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String country;
  final double? latitude;
  final double? longitude;

  CityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.country,
    this.latitude,
    this.longitude,
  });

  // From JSON
  factory CityModel.fromJson(Map<String, dynamic> json, String id) {
    return CityModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Copy with
  CityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    return CityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
