import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/attraction_provider.dart';
import '../../widgets/attraction_card.dart';
import '../attractions/attraction_detail_screen.dart';

class InterestResultScreen extends StatefulWidget {
  final String category;

  const InterestResultScreen({super.key, required this.category});

  @override
  State<InterestResultScreen> createState() => _InterestResultScreenState();
}

class _InterestResultScreenState extends State<InterestResultScreen> {
  @override
  void initState() {
    super.initState();
    // Load all attractions to filter by category
    // In a real app, we might query by category at DB level
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttractionProvider>(context, listen: false).loadAllAttractions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final attractionProvider = Provider.of<AttractionProvider>(context);
    final filteredAttractions = attractionProvider.attractions
        .where((a) => a.category.toLowerCase() == widget.category.toLowerCase() || 
                      (widget.category == 'Adventure' && (a.category == 'Park' || a.category == 'Nature')) || // Mapping logic
                      (widget.category == 'Beaches' && a.description.toLowerCase().contains('beach'))
              ) 
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.category),
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
          : filteredAttractions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.explore_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No ${widget.category} found', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredAttractions.length,
                  itemBuilder: (context, index) {
                    final attraction = filteredAttractions[index];
                    return AttractionCard(
                      attraction: attraction,
                      onTap: () {
                         Navigator.push(
                           context, 
                           MaterialPageRoute(builder: (_) => AttractionDetailScreen(attraction: attraction))
                         );
                      },
                    );
                  },
                ),
    );
  }
}
