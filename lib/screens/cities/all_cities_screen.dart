import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/city_provider.dart';
import '../../widgets/city_card.dart';
import 'city_detail_screen.dart';

class AllCitiesScreen extends StatelessWidget {
  const AllCitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cityProvider = Provider.of<CityProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('All Cities'),
        backgroundColor: AppTheme.surfaceColor,
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
      body: cityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cityProvider.cities.isEmpty
              ? const Center(child: Text('No cities found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cityProvider.cities.length,
                  itemBuilder: (context, index) {
                    final city = cityProvider.cities[index];
                    return CityCard(
                      city: city,
                      onTap: () {
                        cityProvider.selectCity(city);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CityDetailScreen()),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
