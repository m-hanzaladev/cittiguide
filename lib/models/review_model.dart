class ReviewModel {
  final String id;
  final String attractionId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  ReviewModel({
    required this.id,
    required this.attractionId,
    required this.userId,
    this.userName = 'Anonymous',
    this.userAvatarUrl = '',
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.likes = 0,
    this.likedBy = const [],
  });

  // From JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    return ReviewModel(
      id: id,
      attractionId: json['attractionId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatarUrl: json['userAvatarUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      likes: json['likes'] ?? 0,
      likedBy: json['likedBy'] != null ? List<String>.from(json['likedBy']) : [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'attractionId': attractionId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  // Copy with
  ReviewModel copyWith({
    String? id,
    String? attractionId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    double? rating,
    String? comment,
    DateTime? timestamp,
    int? likes,
    List<String>? likedBy,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      attractionId: attractionId ?? this.attractionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
