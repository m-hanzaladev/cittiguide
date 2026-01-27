import 'package:flutter/material.dart';
import '../models/city_model.dart';
import '../services/database_service.dart';

class CityProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<CityModel> _cities = [];
  bool _isLoading = true;
  String _searchQuery = '';
  CityModel? _selectedCity;

  List<CityModel> get cities => _searchQuery.isEmpty
      ? _cities
      : _cities
          .where((city) =>
              city.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              city.country.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  bool get isLoading => _isLoading;
  CityModel? get selectedCity => _selectedCity;

  CityProvider() {
    _loadCities();
  }

  void _loadCities() {
    _databaseService.getCities().listen((citiesData) {
      _cities = citiesData;
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectCity(CityModel city) {
    _selectedCity = city;
    notifyListeners();
  }

  void searchCities(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addCity(CityModel city) async {
    await _databaseService.addCity(city);
    // Stream will auto-update the list
  }

  Future<void> updateCity(CityModel city) async {
    await _databaseService.updateCity(city);
  }

  Future<void> deleteCity(String id) async {
    await _databaseService.deleteCity(id);
  }
}
