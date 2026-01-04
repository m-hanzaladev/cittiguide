import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/attraction_model.dart';
import '../../widgets/attraction_card.dart';
import '../attractions/attraction_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final DatabaseService db = DatabaseService();

    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<List<AttractionModel>>(
      future: db.getUserFavorites(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey[800]),
                const SizedBox(height: 16),
                const Text('No favorites yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final attraction = favorites[index];
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
}
