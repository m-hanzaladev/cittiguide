import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/database_service.dart';

class ReviewProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  void loadReviews(String attractionId) {
    _isLoading = true;
    notifyListeners();

    _databaseService.getReviewsForAttraction(attractionId).listen((reviewsData) {
      _reviews = reviewsData;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addReview(ReviewModel review) async {
    await _databaseService.addReview(review);
  }

  Future<void> toggleLike(String attractionId, String reviewId, String userId) async {
    await _databaseService.toggleReviewLike(attractionId, reviewId, userId);
  }
}
