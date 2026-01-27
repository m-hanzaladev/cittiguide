import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../providers/city_provider.dart';
import '../../providers/attraction_provider.dart';
import '../../widgets/attraction_card.dart';
import '../../utils/app_constants.dart';
import '../attractions/attraction_detail_screen.dart';
import '../../widgets/app_image.dart';
import '../../providers/auth_provider.dart';
import 'city_attractions_screen.dart';

class CityDetailScreen extends StatefulWidget {
  const CityDetailScreen({super.key});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
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

    if (city == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
            ),
            actions: [
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final isFavorite = auth.currentUser?.favoriteCities.contains(city.id) ?? false;
                  return GestureDetector(
                    onTap: () => auth.toggleCityFavorite(city.id),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppTheme.errorColor : Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    imageUrl: city.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.backgroundColor.withOpacity(0.8),
                          AppTheme.backgroundColor,
                        ],
                        stops: const [0.6, 0.9, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Name & Country
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          city.name,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          city.country,
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    city.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 32),

                  // Location Map
                  if (attractionProvider.attractions.isNotEmpty) ...[
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.surfaceColor),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            city.latitude ?? (attractionProvider.attractions.isNotEmpty 
                                ? attractionProvider.attractions.first.location.latitude 
                                : 0.0),
                            city.longitude ?? (attractionProvider.attractions.isNotEmpty 
                                ? attractionProvider.attractions.first.location.longitude 
                                : 0.0),
                          ),
                          initialZoom: 12.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.cittiguide.app',
                          ),
                          MarkerLayer(
                            markers: attractionProvider.attractions.map((attr) {
                              return Marker(
                                point: LatLng(
                                  attr.location.latitude,
                                  attr.location.longitude,
                                ),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppTheme.errorColor,
                                  size: 24,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Popular Attractions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Popular Places',
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CityAttractionsScreen()),
                          );
                        },
                        child: Text(
                          'See all',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Attractions List
                  SizedBox(
                    height: 240,
                    child: attractionProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: attractionProvider.attractions.length,
                            itemBuilder: (context, index) {
                              final attraction = attractionProvider.attractions[index];
                              return AttractionCard(
                                attraction: attraction,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttractionDetailScreen(attraction: attraction),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
