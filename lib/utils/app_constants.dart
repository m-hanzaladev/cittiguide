class AppConstants {
  // App Info
  static const String appName = 'City Guide';
  static const String appVersion = '1.0.0';
  
  // Categories
  static const String categoryRestaurant = 'restaurant';
  static const String categoryHotel = 'hotel';
  static const String categoryAttraction = 'attraction';
  static const String categoryEvent = 'event';
  
  static const List<String> categories = [
    categoryRestaurant,
    categoryHotel,
    categoryAttraction,
    categoryEvent,
  ];
  
  static const Map<String, String> categoryLabels = {
    categoryRestaurant: 'Restaurants',
    categoryHotel: 'Hotels',
    categoryAttraction: 'Attractions',
    categoryEvent: 'Events',
  };
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorEmptyField = 'This field cannot be empty.';
  
  // Success Messages
  static const String successRegistration = 'Account created successfully!';
  static const String successLogin = 'Welcome back!';
  static const String successPasswordReset = 'Password reset email sent. Check your inbox.';
  static const String successReviewSubmitted = 'Review submitted successfully!';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String citiesCollection = 'cities';
  static const String attractionsCollection = 'attractions';
  static const String reviewsCollection = 'reviews';
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
