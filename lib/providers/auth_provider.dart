import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      _isLoading = true;
      notifyListeners();

      if (firebaseUser != null) {
        try {
          _currentUser = await _authService.getUserData(firebaseUser.uid);
          if (_currentUser == null) {
            // New user scenario or data fetch failed, try to get basic data
            _currentUser = UserModel(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email ?? '',
            );
          }
        } catch (e) {
          debugPrint('Error fetching user data: $e');
        }
      } else {
        _currentUser = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refreshUserData() async {
    if (_currentUser != null) {
      final updatedUser = await _authService.getUserData(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();
    
    final db = DatabaseService();
    await db.updateUser(updatedUser);
    
    _currentUser = updatedUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePreference(String key, dynamic value) async {
    if (_currentUser == null) return;

    // Create a new map to ensure immutability is handled correctly
    final newPreferences = Map<String, dynamic>.from(_currentUser!.preferences);
    newPreferences[key] = value;

    final updatedUser = _currentUser!.copyWith(preferences: newPreferences);
    
    // Optimistic update
    _currentUser = updatedUser;
    notifyListeners();

    // Persist to DB
    final db = DatabaseService();
    await db.updateUser(updatedUser);
  }

  Future<void> toggleFavorite(String attractionId) async {
    if (_currentUser == null) return;
    
    final db = DatabaseService();
    final isFavorite = _currentUser!.favorites.contains(attractionId);
    
    if (isFavorite) {
      await db.removeFromFavorites(_currentUser!.id, attractionId);
      _currentUser!.favorites.remove(attractionId);
    } else {
      await db.addToFavorites(_currentUser!.id, attractionId);
      _currentUser!.favorites.add(attractionId);
    }
    notifyListeners();
  }
}
