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
      
      // If no cities in DB (first run), add dummy data
      if (_cities.isEmpty) {
        _addDummyData();
      }
      
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

  Future<void> _addDummyData() async {
    final List<CityModel> dummyCities = [
      CityModel(
        id: '',
        name: 'Kyoto',
        country: 'Japan',
        description: 'Immerse yourself in the cultural heart of Japan, where ancient temples, sublime gardens, and traditional teahouses meet modern convenience.',
        imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
      ),
      CityModel(
        id: '',
        name: 'Paris',
        country: 'France',
        description: 'The City of Light beckons with its world-class art, fashion, gastronomy, and culture. From the Eiffel Tower to Montmartre, Paris is timeless.',
        imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
      ),
      CityModel(
        id: '',
        name: 'New York',
        country: 'USA',
        description: 'The city that never sleeps. Experience the electric energy of Times Square, Central Park, and the architectural marvels of Manhattan.',
        imageUrl: 'https://images.unsplash.com/photo-1496442226666-8d4a0e62e6e9?w=800',
      ),
      CityModel(
        id: '',
        name: 'London',
        country: 'UK',
        description: 'A global city with Roman roots. Explore the Tower of London, Buckingham Palace, and the vibrant culture of the West End.',
        imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800',
      ),
      CityModel(
        id: '',
        name: 'Dubai',
        country: 'UAE',
        description: 'Known for luxury shopping, ultramodern architecture, and a lively nightlife scene. Burj Khalifa dominates the skyscraper-filled skyline.',
        imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea90b7cadc9?w=800',
      ),
      CityModel(
        id: '',
        name: 'Rome',
        country: 'Italy',
        description: 'The Eternal City. A sprawling cosmopolitan city with nearly 3,000 years of globally influential art, architecture, and culture on display.',
        imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
      ),
      CityModel(
        id: '',
        name: 'Tokyo',
        country: 'Japan',
        description: 'Japan\'s busy capital, mixes the ultramodern and the traditional, from neon-lit skyscrapers to historic temples.',
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
      ),
      CityModel(
        id: '',
        name: 'Barcelona',
        country: 'Spain',
        description: 'The cosmopolitan capital of Spain’s Catalonia region, known for its art and architecture, particularly the fantastical Sagrada Família.',
        imageUrl: 'https://images.unsplash.com/photo-1583422409516-2895a77efbed?w=800',
      ),
      CityModel(
        id: '',
        name: 'Sydney',
        country: 'Australia',
        description: 'Defined by its harborfront Opera House, massive Darling Harbour and the arched Harbour Bridge. A gateway to adventure.',
        imageUrl: 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800',
      ),
      CityModel(
        id: '',
        name: 'Cape Town',
        country: 'South Africa',
        description: 'A port city on South Africa’s southwest coast, on a peninsula beneath the imposing Table Mountain.',
        imageUrl: 'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800',
      ),
      CityModel(
        id: '',
        name: 'Rio de Janeiro',
        country: 'Brazil',
        description: 'A huge seaside city in Brazil, famed for its Copacabana and Ipanema beaches, 38m Christ the Redeemer statue atop Mount Corcovado.',
        imageUrl: 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?w=800',
      ),
      CityModel(
        id: '',
        name: 'Singapore',
        country: 'Singapore',
        description: 'An island city-state off southern Malaysia, a global financial center with a tropical climate and multicultural population.',
        imageUrl: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=800',
      ),
      CityModel(
        id: '',
        name: 'Istanbul',
        country: 'Turkey',
        description: 'A major city in Turkey that straddles Europe and Asia across the Bosphorus Strait. Its Old City reflects cultural influences of the many empires that once ruled here.',
        imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800',
      ),
      CityModel(
        id: '',
        name: 'Bangkok',
        country: 'Thailand',
        description: 'Thailand’s capital, a large city known for ornate shrines and vibrant street life. The boat-filled Chao Phraya River feeds its network of canals.',
        imageUrl: 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=800',
      ),
      CityModel(
        id: '',
        name: 'Amsterdam',
        country: 'Netherlands',
        description: 'The Netherlands’ capital, known for its artistic heritage, elaborate canal system and narrow houses with gabled facades.',
        imageUrl: 'https://images.unsplash.com/photo-1512470876302-687da745ca9e?w=800',
      ),
      CityModel(
        id: '',
        name: 'San Francisco',
        country: 'USA',
        description: 'A hilly city on the tip of a peninsula surrounded by the Pacific Ocean and San Francisco Bay.',
        imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800',
      ),
      CityModel(
        id: '',
        name: 'Berlin',
        country: 'Germany',
        description: 'Germany’s capital, dates to the 13th century. Reminders of the city\'s turbulent 20th-century history include its Holocaust memorial and the Berlin Wall remains.',
        imageUrl: 'https://images.unsplash.com/photo-1560969184-10fe8719e047?w=800',
      ),
      CityModel(
        id: '',
        name: 'Prague',
        country: 'Czech Republic',
        description: 'The capital of the Czech Republic, bisected by the Vltava River. Nicknamed "the City of a Hundred Spires," it\'s known for its Old Town Square.',
        imageUrl: 'https://images.unsplash.com/photo-1519677100094-1a72a6401c22?w=800',
      ),
      CityModel(
        id: '',
        name: 'Seoul',
        country: 'South Korea',
        description: 'A huge metropolis where modern skyscrapers, high-tech subways and pop culture meet Buddhist temples, palaces and street markets.',
        imageUrl: 'https://images.unsplash.com/photo-1538485399081-7191377e8241?w=800',
      ),
      CityModel(
        id: '',
        name: 'Toronto',
        country: 'Canada',
        description: 'A major Canadian city along Lake Ontario’s northwestern shore. It\'s a dynamic metropolis with a core of soaring skyscrapers.',
        imageUrl: 'https://images.unsplash.com/photo-1517935706615-2717063c2225?w=800',
      ),
    ];
    
    // Check if we need to add them (avoid duplicates if possible, though this is a simple check)
    // We only add if DB is near empty. To avoid duplicates on re-runs with partial data,
    // we could check names, but for this demo assume if count < 5 we re-seed mostly everything.
    // Ideally we check each.
    
    for (var city in dummyCities) {
      if (!_cities.any((c) => c.name == city.name)) {
        await _databaseService.addCity(city);
      }
    }
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
