import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/attraction_provider.dart';
import '../../providers/city_provider.dart';
import '../../widgets/attraction_card.dart';
import '../attractions/attraction_detail_screen.dart';

class CityAttractionsScreen extends StatefulWidget {
  const CityAttractionsScreen({super.key});

  @override
  State<CityAttractionsScreen> createState() => _CityAttractionsScreenState();
}

class _CityAttractionsScreenState extends State<CityAttractionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final city = Provider.of<CityProvider>(context, listen: false).selectedCity;
      if (city != null) {
        Provider.of<AttractionProvider>(context, listen: false).loadAttractions(city.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final city = Provider.of<CityProvider>(context).selectedCity;
    final attractionProvider = Provider.of<AttractionProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(city != null ? 'Places in ${city.name}' : 'Places'),
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
      body: attractionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : attractionProvider.attractions.isEmpty
              ? const Center(child: Text('No places found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: attractionProvider.attractions.length,
                  itemBuilder: (context, index) {
                    final attraction = attractionProvider.attractions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AttractionCard(
                        attraction: attraction,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttractionDetailScreen(attraction: attraction),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
