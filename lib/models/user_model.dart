class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final List<String> favorites;
  final List<String> favoriteCities;
  final Map<String, dynamic> preferences;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.favorites = const [],
    this.favoriteCities = const [],
    this.preferences = const {},
    this.isAdmin = false,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    // Safely extract lists
    final dynamic favoritesData = json['favorites'];
    final dynamic favoriteCitiesData = json['favoriteCities'];
    final dynamic preferencesData = json['preferences'];

    return UserModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString(),
      favorites: favoritesData is List 
          ? List<String>.from(favoritesData.map((e) => e.toString())) 
          : [],
      favoriteCities: favoriteCitiesData is List 
          ? List<String>.from(favoriteCitiesData.map((e) => e.toString())) 
          : [],
      preferences: preferencesData is Map<String, dynamic> 
          ? preferencesData 
          : {},
      isAdmin: json['isAdmin'] == true,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'favorites': favorites,
      'favoriteCities': favoriteCities,
      'preferences': preferences,
      'isAdmin': isAdmin,
    };
  }

  // Copy with
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    List<String>? favorites,
    List<String>? favoriteCities,
    Map<String, dynamic>? preferences,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      favorites: favorites ?? this.favorites,
      favoriteCities: favoriteCities ?? this.favoriteCities,
      preferences: preferences ?? this.preferences,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
