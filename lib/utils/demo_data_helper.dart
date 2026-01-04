import '../models/city_model.dart';
import '../models/attraction_model.dart';
import '../services/database_service.dart';

class DemoDataHelper {
  static final DatabaseService _db = DatabaseService();

  static Future<void> seedDatabase() async {
    // 1. Seed Cities
    final cities = [
      CityModel(
        id: '', // Firebase will generate
        name: 'Kyoto',
        country: 'Japan',
        description: 'Immerse yourself in the cultural heart of Japan, where ancient temples, sublime gardens, and traditional teahouses meet modern convenience. Kyoto offers a glimpse into the soul of old Japan.',
        imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
      ),
      CityModel(
        id: '',
        name: 'Paris',
        country: 'France',
        description: 'The City of Light beckons with its world-class art, fashion, gastronomy, and culture. From the Eiffel Tower to the charming streets of Montmartre, Paris is a timeless masterpiece.',
        imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
      ),
      CityModel(
        id: '',
        name: 'New York',
        country: 'USA',
        description: 'The city that never sleeps. Experience the electric energy of Times Square, the tranquility of Central Park, and the architectural marvels that define the Manhattan skyline.',
        imageUrl: 'https://images.unsplash.com/photo-1496442226666-8d4a0e62e6e9?w=800',
      ),
       CityModel(
        id: '',
        name: 'Cape Town',
        country: 'South Africa',
        description: 'Where the mountains meet the sea. Cape Town offers breathtaking landscapes, vibrant culture, and world-class vineyards just a short drive away.',
        imageUrl: 'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800',
      ),
    ];

    // Map to store new IDs for attractions
    final Map<String, String> cityIds = {};

    for (var city in cities) {
      final ref = _db.database.child('cities').push();
      // Temporarily assign ID for local mapping (ref.key is the real ID)
      cityIds[city.name] = ref.key!; 
      await ref.set(city.toJson());
    }

    // 2. Seed Attractions
    if (cityIds.isNotEmpty) {
      final attractions = [
        // Kyoto
        AttractionModel(
          id: '',
          name: 'Fushimi Inari Shrine',
          cityId: cityIds['Kyoto']!,
          category: 'Landmark',
          description: 'Famous for its thousands of vermilion torii gates, which straddle a network of trails behind its main buildings.',
          imageUrls: ['https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?w=800'],
          priceRange: 'Free',
          location: LocationData(latitude: 34.9671, longitude: 135.7727, address: '68 Fukakusa Yabunouchicho, Fushimi Ward, Kyoto'),
          contactInfo: ContactInfo(webUrl: 'http://inari.jp/en/'),
          openingHours: {'Mon-Sun': 'Open 24 hours'},
          averageRating: 4.8,
          reviewCount: 3200,
        ),
        AttractionModel(
          id: '',
          name: 'Arashiyama Bamboo Grove',
          cityId: cityIds['Kyoto']!,
          category: 'Nature',
          description: 'A mesmerizing grove of towering bamboo stalks that is one of Kyoto\'s top sights.',
          imageUrls: ['https://images.unsplash.com/photo-1576675466969-38eeae4b41f6?w=800'],
          priceRange: 'Free',
          location: LocationData(latitude: 35.0094, longitude: 135.6670, address: 'Arashiyama, Ukyo Ward, Kyoto'),
          contactInfo: ContactInfo(),
          openingHours: {'Mon-Sun': 'Open 24 hours'},
          averageRating: 4.6,
          reviewCount: 1500,
        ),
         // Paris
        AttractionModel(
          id: '',
          name: 'Eiffel Tower',
          cityId: cityIds['Paris']!,
          category: 'Landmark',
          description: 'The Iron Lady of Paris. Steps to the top or an elevator ride offer the best views of the city.',
          imageUrls: ['https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=800'],
          priceRange: '\$\$',
          location: LocationData(latitude: 48.8584, longitude: 2.2945, address: 'Champ de Mars, 5 Av. Anatole France, 75007 Paris'),
          contactInfo: ContactInfo(webUrl: 'https://www.toureiffel.paris/'),
          openingHours: {'Mon-Sun': '9:30 AM - 10:45 PM'},
          averageRating: 4.7,
          reviewCount: 5000,
        ),
         AttractionModel(
          id: '',
          name: 'Louvre Museum',
          cityId: cityIds['Paris']!,
          category: 'Museum',
          description: 'The world\'s largest art museum and a historic monument in Paris, home to the Mona Lisa.',
          imageUrls: ['https://images.unsplash.com/photo-1499856871940-a09e328237e8?w=800'],
          priceRange: '\$\$',
          location: LocationData(latitude: 48.8606, longitude: 2.3376, address: 'Rue de Rivoli, 75001 Paris'),
          contactInfo: ContactInfo(webUrl: 'https://www.louvre.fr/en'),
          openingHours: {'Wed-Mon': '9:00 AM - 6:00 PM'},
          averageRating: 4.7,
          reviewCount: 4200,
        ),
         // New York
        AttractionModel(
          id: '',
          name: 'Central Park',
          cityId: cityIds['New York']!,
          category: 'Park',
          description: 'An urban oasis in the middle of Manhattan, featuring a zoo, lakes, and miles of walking paths.',
          imageUrls: ['https://images.unsplash.com/photo-1534270804882-6b5048b1c1fc?w=800'],
          priceRange: 'Free',
          location: LocationData(latitude: 40.785091, longitude: -73.968285, address: 'New York, NY 10024'),
          contactInfo: ContactInfo(webUrl: 'https://www.centralparknyc.org/'),
          openingHours: {'Mon-Sun': '6:00 AM - 1:00 AM'},
          averageRating: 4.8,
          reviewCount: 3800,
        ),
      ];

      for (var attraction in attractions) {
        // Use addAttraction from implementation which handles ID generation
         await _db.addAttraction(attraction);
      }
    }
  }
}
