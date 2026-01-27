import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/attraction_provider.dart';
import '../../widgets/attraction_card.dart';
import '../../widgets/city_card.dart';
import '../attractions/attraction_detail_screen.dart';
import '../cities/city_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Ensure all data is being synchronized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttractionProvider>(context, listen: false).loadAllAttractions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: Text('Please log in to view favorites')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: AppTheme.surfaceColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Cities'),
            Tab(text: 'Attractions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoriteCitiesList(context),
          _buildFavoriteAttractionsList(context),
        ],
      ),
    );
  }

  Widget _buildFavoriteCitiesList(BuildContext context) {
    return Consumer2<AuthProvider, CityProvider>(
      builder: (context, auth, cityProv, _) {
        final favoriteIds = auth.currentUser?.favoriteCities ?? [];
        final favoriteCities = cityProv.cities.where((c) => favoriteIds.contains(c.id)).toList();

        if (cityProv.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favoriteCities.isEmpty) {
          return _buildEmptyState('No favorite cities yet');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteCities.length,
          itemBuilder: (context, index) {
            final city = favoriteCities[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CityCard(
                city: city,
                onTap: () {
                  cityProv.selectCity(city);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CityDetailScreen()),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoriteAttractionsList(BuildContext context) {
    return Consumer2<AuthProvider, AttractionProvider>(
      builder: (context, auth, attrProv, _) {
        final favoriteIds = auth.currentUser?.favorites ?? [];
        final favoriteAttractions = attrProv.attractions.where((a) => favoriteIds.contains(a.id)).toList();

        if (attrProv.isLoading && favoriteAttractions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favoriteAttractions.isEmpty) {
          return _buildEmptyState('No favorite attractions yet');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteAttractions.length,
          itemBuilder: (context, index) {
            final attraction = favoriteAttractions[index];
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
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
