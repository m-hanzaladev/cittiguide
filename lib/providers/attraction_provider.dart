import 'package:flutter/material.dart';
import '../models/attraction_model.dart';
import '../services/database_service.dart';

class AttractionProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<AttractionModel> _attractions = [];
  bool _isLoading = false;

  List<AttractionModel> get attractions => _attractions;
  bool get isLoading => _isLoading;

  void loadAttractions(String cityId) {
    _isLoading = true;
    notifyListeners();

    _databaseService.getAttractions(cityId).listen((attractionsData) {
      _attractions = attractionsData;
      _isLoading = false;
      notifyListeners();
    });
  }

  void loadAllAttractions() {
    _isLoading = true;
    notifyListeners();

    _databaseService.getAllAttractions().listen((attractionsData) {
      _attractions = attractionsData;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addAttraction(AttractionModel attraction) async {
    await _databaseService.addAttraction(attraction);
  }

  Future<void> updateAttraction(AttractionModel attraction) async {
    await _databaseService.updateAttraction(attraction);
  }

  Future<void> deleteAttraction(String id) async {
    await _databaseService.deleteAttraction(id);
  }
}
