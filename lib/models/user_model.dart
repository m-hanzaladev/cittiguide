class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final List<String> favorites;
  final Map<String, dynamic> preferences;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.favorites = const [],
    this.preferences = const {},
    this.isAdmin = false,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      favorites: json['favorites'] != null
          ? List<String>.from(json['favorites'])
          : [],
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : {},
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'favorites': favorites,
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
    Map<String, dynamic>? preferences,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      favorites: favorites ?? this.favorites,
      preferences: preferences ?? this.preferences,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
