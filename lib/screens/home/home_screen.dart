import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/attraction_provider.dart';
import '../../widgets/city_card.dart';
import '../../widgets/app_image.dart';
import '../../models/user_model.dart';
import '../../utils/app_constants.dart';
import '../cities/city_detail_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../favorites/favorites_screen.dart';
import '../search/search_screen.dart';
import 'interest_result_screen.dart';
import '../../providers/category_provider.dart';
import 'all_interests_screen.dart';
import '../cities/all_cities_screen.dart';
import '../notifications/notification_screen.dart';
import '../profile/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Home as center

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cityProvider = Provider.of<CityProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBody: true,
      drawer: _buildDrawer(context, user, authProvider),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            const SearchScreen(),
            const AllInterestsScreen(),
            _buildHomeBody(context, user, cityProvider),
            const FavoritesScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 50.0,
        items: const <Widget>[
          Icon(Icons.search, size: 30, color: AppTheme.backgroundColor),
          Icon(Icons.category, size: 30, color: AppTheme.backgroundColor),
          Icon(Icons.home, size: 30, color: AppTheme.backgroundColor),
          Icon(Icons.favorite, size: 30, color: AppTheme.backgroundColor),
          Icon(Icons.person, size: 30, color: AppTheme.backgroundColor),
        ],
        color: AppTheme.primaryColor,
        buttonBackgroundColor: AppTheme.primaryColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel? user, AuthProvider authProvider) {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            accountName: Text(
              user?.name ?? 'Traveler',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: GoogleFonts.inter(),
            ),
            currentAccountPicture: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                  ? AppImage(
                      imageUrl: user.profilePicture!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'T',
                        style: const TextStyle(fontSize: 24, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppTheme.textPrimary),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context, UserModel? user, CityProvider cityProvider) {
    final displayName = user?.name ?? 'Traveler';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                              ? AppImage(
                                  imageUrl: user.profilePicture!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $displayName',
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Good morning',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Image.asset(
                    'assets/app_logo.png',
                    height: 40,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  if (user?.isAdmin == true) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Cities',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllCitiesScreen()),
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

          SizedBox(
            height: 420,
            child: cityProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cityProvider.cities.isEmpty
                    ? Center(
                        child: Text(
                          'No cities found',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : PageView.builder(
                        controller: PageController(viewportFraction: 0.9),
                        itemCount: cityProvider.cities.length,
                        itemBuilder: (context, index) {
                          final city = cityProvider.cities[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: CityCard(
                              city: city,
                              onTap: () {
                                cityProvider.selectCity(city);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CityDetailScreen(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore by Interest',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllInterestsScreen()),
                  );
                },
                child: Text(
                  'View all',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Consumer<CategoryProvider>(
            builder: (context, catProvider, child) {
              if (catProvider.isLoading) {
                 return const Center(child: CircularProgressIndicator());
              }
              if (catProvider.categories.isEmpty) {
                 return const SizedBox.shrink();
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: catProvider.categories.map((category) {
                     return Padding(
                       padding: const EdgeInsets.only(right: 16),
                       child: _buildInterestCard(context, category.name, category.imageUrl),
                     );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInterestCard(BuildContext context, String title, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InterestResultScreen(category: title),
          ),
        );
      },
      child: Container(
        width: 120,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomCenter,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen() {
    return const Center(
      child: Text('Coming Soon'),
    );
  }
}
