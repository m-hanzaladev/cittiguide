import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/city_provider.dart';
import '../../providers/attraction_provider.dart';
import '../../widgets/city_card.dart';
import '../../widgets/attraction_card.dart';
import '../cities/city_detail_screen.dart';
import '../attractions/attraction_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityProvider = Provider.of<CityProvider>(context);
    final attractionProvider = Provider.of<AttractionProvider>(context);

    // Perform Search
    final filteredCities = _query.isEmpty 
        ? <dynamic>[]
        : cityProvider.cities.where((city) => 
            city.name.toLowerCase().contains(_query.toLowerCase())).toList();
            
    // For attractions, we ideally need ALL attractions loaded or search logic in provider
    // Assuming provider has some loaded attractions. If empty, maybe we searching only loaded ones.
    // Real app would query DB. Here we filter loaded attractions.
    final filteredAttractions = _query.isEmpty
        ? <dynamic>[]
        : attractionProvider.attractions.where((attr) =>
            attr.name.toLowerCase().contains(_query.toLowerCase()) || 
            attr.category.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search cities, places...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
        ),
        backgroundColor: AppTheme.surfaceColor,
        automaticallyImplyLeading: false, // Hide back button if using as tab, or check Navigator.canPop
        // Or if we want back button ONLY when pushed:
        leading: Navigator.canPop(context) 
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }) 
            : null,
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _query = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.search, size: 64, color: AppTheme.surfaceColor),
                   const SizedBox(height: 16),
                   Text('Find your next adventure', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (filteredCities.isEmpty && filteredAttractions.isEmpty)
                   const Padding(
                     padding: EdgeInsets.only(top: 20),
                     child: Center(child: Text('No results found.', style: TextStyle(color: Colors.grey))),
                   ),
                   
                if (filteredCities.isNotEmpty) ...[
                  Text('Cities', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                         final city = filteredCities[index]; // Dynamic typing to avoid cast issues if any
                         return Padding(
                           padding: const EdgeInsets.only(right: 16),
                           // Reuse CityCard but maybe scale it down?
                           // CityCard is designed large.
                           child: SizedBox(
                             width: 260, // Fixed width for horizontal list items
                             child: CityCard(
                               city: city, // Correct type
                               onTap: () {
                                 cityProvider.selectCity(city);
                                 Navigator.push(
                                   context, 
                                   MaterialPageRoute(builder: (_) => const CityDetailScreen())
                                 );
                               },
                             ),
                           ),
                         );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (filteredAttractions.isNotEmpty) ...[
                  Text('Attractions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                   SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredAttractions.length,
                      itemBuilder: (context, index) {
                         final attr = filteredAttractions[index];
                         return AttractionCard(
                           attraction: attr,
                           onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttractionDetailScreen(attraction: attr),
                                ),
                              );
                           },
                         );
                      },
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
