class CityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String country;

  CityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.country,
  });

  // From JSON
  factory CityModel.fromJson(Map<String, dynamic> json, String id) {
    return CityModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      country: json['country'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'country': country,
    };
  }

  // Copy with
  CityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? country,
  }) {
    return CityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      country: country ?? this.country,
    );
  }
}
