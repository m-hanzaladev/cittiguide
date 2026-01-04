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
      
      // Add dummy data if empty (for demo)
      if (_attractions.isEmpty) {
        _addDummyAttractions(cityId);
      }
      
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

  Future<void> _addDummyAttractions(String cityId) async {
    // Only adding dummy data for demo purposes if the DB is empty
    final dummyAttractions = [
      AttractionModel(
        id: '',
        name: 'The Great Tower',
        cityId: cityId,
        category: 'Landmark',
        description: 'An iconic symbol of the city, offering panoramic views from its observation deck.',
        imageUrls: [
          'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=800',
          'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=800',
        ],
        location: LocationData(latitude: 0, longitude: 0, address: '123 Main St'),
        averageRating: 4.8,
        reviewCount: 1250,
        contactInfo: ContactInfo(phone: '+1 234 567 8900', webUrl: 'https://example.com'),
        openingHours: {'Mon-Sun': '9:00 AM - 10:00 PM'},
        priceRange: '\$\$',
      ),
      AttractionModel(
        id: '',
        name: 'National Museum',
        cityId: cityId,
        category: 'Museum',
        description: 'Home to thousands of artifacts detailing the rich history and culture of the region.',
        imageUrls: ['https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=800'],
        location: LocationData(latitude: 0, longitude: 0, address: '456 History Ln'),
        averageRating: 4.5,
        reviewCount: 890,
        contactInfo: ContactInfo(phone: '+1 234 567 8900', webUrl: 'https://museum.example.com'),
        openingHours: {'Tue-Sun': '10:00 AM - 6:00 PM'},
        priceRange: '\$',
      ),
      AttractionModel(
        id: '',
        name: 'City Park',
        cityId: cityId,
        category: 'Park',
        description: 'A lush green oasis in the heart of the city, perfect for picnics and leisurely strolls.',
        imageUrls: ['https://images.unsplash.com/photo-1496070242169-ca9e25a85536?w=800'],
        location: LocationData(latitude: 0, longitude: 0, address: '789 Park Ave'),
        averageRating: 4.9,
        reviewCount: 2100,
        contactInfo: ContactInfo(phone: '+1 234 567 8900', webUrl: ''),
        openingHours: {'Mon-Sun': 'Open 24 Hours'},
        priceRange: 'Free',
      ),
    ];

    for (var attraction in dummyAttractions) {
      await _databaseService.addAttraction(attraction);
    }
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
