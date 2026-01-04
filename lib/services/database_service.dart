import 'package:firebase_database/firebase_database.dart';
import '../models/city_model.dart';
import '../models/attraction_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../utils/app_constants.dart';

class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  DatabaseReference get database => _database;

  Stream<List<CityModel>> getCities() {
    return _database.child(AppConstants.citiesCollection).onValue.map((event) {
      final List<CityModel> cities = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> citiesMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        citiesMap.forEach((key, value) {
          cities.add(CityModel.fromJson(
            Map<String, dynamic>.from(value as Map),
            key.toString(),
          ));
        });
      }
      return cities;
    });
  }

  Future<CityModel?> getCityById(String cityId) async {
    try {
      final snapshot =
          await _database.child(AppConstants.citiesCollection).child(cityId).get();
      if (snapshot.exists) {
        return CityModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          cityId,
        );
      }
      return null;
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> addCity(CityModel city) async {
    try {
      final newCityRef = _database.child(AppConstants.citiesCollection).push();
      await newCityRef.set(city.toJson());
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> updateCity(CityModel city) async {
    try {
      await _database
          .child(AppConstants.citiesCollection)
          .child(city.id)
          .update(city.toJson());
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> deleteCity(String cityId) async {
    try {
      await _database.child(AppConstants.citiesCollection).child(cityId).remove();
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Stream<List<AttractionModel>> getAttractions(String cityId) => getAttractionsByCity(cityId);

  Stream<List<AttractionModel>> getAttractionsByCity(String cityId) {
    return _database
        .child(AppConstants.attractionsCollection)
        .orderByChild('cityId')
        .equalTo(cityId)
        .onValue
        .map((event) {
      final List<AttractionModel> attractions = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> attractionsMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        attractionsMap.forEach((key, value) {
          attractions.add(AttractionModel.fromJson(
            Map<String, dynamic>.from(value as Map),
            key.toString(),
          ));
        });
      }
      return attractions;
    });
  }

  Stream<List<AttractionModel>> getAllAttractions() {
    return _database.child(AppConstants.attractionsCollection).onValue.map((event) {
      final List<AttractionModel> attractions = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> attractionsMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        attractionsMap.forEach((key, value) {
          attractions.add(AttractionModel.fromJson(
            Map<String, dynamic>.from(value as Map),
            key.toString(),
          ));
        });
      }
      return attractions;
    });
  }

  Future<AttractionModel?> getAttractionById(String attractionId) async {
    try {
      final snapshot = await _database
          .child(AppConstants.attractionsCollection)
          .child(attractionId)
          .get();
      if (snapshot.exists) {
        return AttractionModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          attractionId,
        );
      }
      return null;
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> addAttraction(AttractionModel attraction) async {
    try {
      final newAttractionRef =
          _database.child(AppConstants.attractionsCollection).push();
      await newAttractionRef.set(attraction.toJson());
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> updateAttraction(AttractionModel attraction) async {
    try {
      await _database
          .child(AppConstants.attractionsCollection)
          .child(attraction.id)
          .update(attraction.toJson());
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> deleteAttraction(String attractionId) async {
    try {
      await _database
          .child(AppConstants.attractionsCollection)
          .child(attractionId)
          .remove();
      // Also delete all reviews for this attraction
      await _database
          .child(AppConstants.reviewsCollection)
          .child(attractionId)
          .remove();
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Stream<List<ReviewModel>> getReviewsForAttraction(String attractionId) {
    return _database
        .child(AppConstants.reviewsCollection)
        .child(attractionId)
        .onValue
        .map((event) {
      final List<ReviewModel> reviews = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> reviewsMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        reviewsMap.forEach((key, value) {
          reviews.add(ReviewModel.fromJson(
            Map<String, dynamic>.from(value as Map),
            key.toString(),
          ));
        });
        // Sort by timestamp (newest first)
        reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      return reviews;
    });
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      final newReviewRef = _database
          .child(AppConstants.reviewsCollection)
          .child(review.attractionId)
          .push();
      await newReviewRef.set(review.toJson());

      // Update attraction's average rating
      await _updateAttractionRating(review.attractionId);
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> toggleReviewLike(String attractionId, String reviewId, String userId) async {
    try {
      final reviewRef = _database
          .child(AppConstants.reviewsCollection)
          .child(attractionId)
          .child(reviewId);

      final snapshot = await reviewRef.get();
      if (snapshot.exists) {
        final reviewData = Map<String, dynamic>.from(snapshot.value as Map);
        final List<String> likedBy = reviewData['likedBy'] != null
            ? List<String>.from(reviewData['likedBy'])
            : [];

        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }

        await reviewRef.update({
          'likedBy': likedBy,
          'likes': likedBy.length,
        });
      }
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> _updateAttractionRating(String attractionId) async {
    try {
      final reviewsSnapshot = await _database
          .child(AppConstants.reviewsCollection)
          .child(attractionId)
          .get();

      if (reviewsSnapshot.exists) {
        final Map<dynamic, dynamic> reviewsMap =
            reviewsSnapshot.value as Map<dynamic, dynamic>;
        double totalRating = 0;
        int count = 0;

        reviewsMap.forEach((key, value) {
          final reviewData = Map<String, dynamic>.from(value as Map);
          totalRating += (reviewData['rating'] ?? 0.0).toDouble();
          count++;
        });

        final double averageRating = count > 0 ? totalRating / count : 0.0;

        await _database
            .child(AppConstants.attractionsCollection)
            .child(attractionId)
            .update({
          'averageRating': averageRating,
          'reviewCount': count,
        });
      }
    } catch (e) {
      // Silently fail - this is a background operation
    }
  }

  Stream<List<CategoryModel>> getCategories() {
    return _database.child('categories').onValue.map((event) {
      final List<CategoryModel> categories = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> categoriesMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        categoriesMap.forEach((key, value) {
          categories.add(CategoryModel.fromJson(
            Map<String, dynamic>.from(value as Map),
            key.toString(),
          ));
        });
      }
      return categories;
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final newCategoryRef = _database.child('categories').push();
      // Use push ID as ID if not provided, but model handles ID. 
      // Actually push() generates ID. We should update model with that ID or ignore ID in toJson.
      // Better:
      await newCategoryRef.set(category.toJson());
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _database.child('categories').child(categoryId).remove();
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _database.child(AppConstants.usersCollection).child(user.id).update(user.toJson());
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> addToFavorites(String userId, String attractionId) async {
    try {
      final userRef = _database.child(AppConstants.usersCollection).child(userId);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        final List<String> favorites = userData['favorites'] != null
            ? List<String>.from(userData['favorites'])
            : [];

        if (!favorites.contains(attractionId)) {
          favorites.add(attractionId);
          await userRef.update({'favorites': favorites});
        }
      }
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<void> removeFromFavorites(String userId, String attractionId) async {
    try {
      final userRef = _database.child(AppConstants.usersCollection).child(userId);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        final List<String> favorites = userData['favorites'] != null
            ? List<String>.from(userData['favorites'])
            : [];

        if (favorites.contains(attractionId)) {
          favorites.remove(attractionId);
          await userRef.update({'favorites': favorites});
        }
      }
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  Future<List<AttractionModel>> getUserFavorites(String userId) async {
    try {
      final userSnapshot =
          await _database.child(AppConstants.usersCollection).child(userId).get();

      if (userSnapshot.exists) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        final List<String> favoriteIds = userData['favorites'] != null
            ? List<String>.from(userData['favorites'])
            : [];

        final List<AttractionModel> favorites = [];
        for (final id in favoriteIds) {
          final attraction = await getAttractionById(id);
          if (attraction != null) {
            favorites.add(attraction);
          }
        }
        return favorites;
      }
      return [];
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }
}
