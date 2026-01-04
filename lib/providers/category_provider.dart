import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    _listenToCategories();
  }

  void _listenToCategories() {
    _isLoading = true;
    notifyListeners();

    _db.getCategories().listen((categories) {
      _categories = categories;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching categories: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addCategory(String name, String imageUrl) async {
    try {
      await _db.addCategory(CategoryModel(id: '', name: name, imageUrl: imageUrl));
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _db.deleteCategory(id);
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }
}
