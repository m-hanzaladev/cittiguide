import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/attraction_provider.dart';
import '../../providers/city_provider.dart';
import '../../models/attraction_model.dart';
import 'add_edit_attraction_screen.dart';
import '../../widgets/app_image.dart';

class ManageAttractionsScreen extends StatelessWidget {
  const ManageAttractionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We need to load attractions. For simplicity in admin, let's load ALL or by selected city.
    // Ideally, we'd have a dropdown to filter by city.
    // For now, let's assume we want to manage attractions for the *selected* city in CityProvider,
    // or we fetch ALL. DatabaseService has getAllAttractions().
    // Let's rely on what's loaded or fetch for a specific city. 
    // To make it dynamic, let's add a City Dropdown at the top.
    
    final cityProvider = Provider.of<CityProvider>(context);
    final attractionProvider = Provider.of<AttractionProvider>(context);

    // Initial load handling could be better, but let's assume user picks a city
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Attractions'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          if (cityProvider.selectedCity == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a city first')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditAttractionScreen(cityId: cityProvider.selectedCity!.id),
            ),
          );
        },
        child: const Icon(Icons.add, color: AppTheme.backgroundColor),
      ),
      body: Column(
        children: [
          // City Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: DropdownButtonFormField<String>(
              value: cityProvider.cities.any((c) => c.id == cityProvider.selectedCity?.id) 
                  ? cityProvider.selectedCity?.id 
                  : null,
              decoration: const InputDecoration(
                labelText: 'Select City',
                border: OutlineInputBorder(),
              ),
              dropdownColor: AppTheme.surfaceColor,
              items: cityProvider.cities.map((city) {
                return DropdownMenuItem(
                  value: city.id,
                  child: Text(city.name, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (cityId) {
                if (cityId != null) {
                  final city = cityProvider.cities.firstWhere((c) => c.id == cityId);
                  cityProvider.selectCity(city);
                  attractionProvider.loadAttractions(cityId);
                }
              },
            ),
          ),
          
          // List
          Expanded(
            child: attractionProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attractionProvider.attractions.isEmpty
                    ? const Center(child: Text('No attractions found for this city.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: attractionProvider.attractions.length,
                        itemBuilder: (context, index) {
                          final attraction = attractionProvider.attractions[index];
                          return Card(
                            color: AppTheme.surfaceColor,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AppImage(
                                  imageUrl: attraction.imageUrls.isNotEmpty 
                                      ? attraction.imageUrls.first 
                                      : '',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                              title: Text(attraction.name, style: const TextStyle(color: Colors.white)),
                              subtitle: Text(attraction.category, style: const TextStyle(color: Colors.grey)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppTheme.accentBlue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditAttractionScreen(
                                            cityId: attraction.cityId,
                                            attraction: attraction,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                    onPressed: () {
                                      // Confirm delete
                                      Provider.of<AttractionProvider>(context, listen: false)
                                          .deleteAttraction(attraction.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
