import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/FilterSheet.dart';
import 'package:mobile_app_project/Pages/RestaurantCard.dart';
import 'package:mobile_app_project/Pages/mock_data.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onRestaurantClick;

  const HomeScreen({Key? key, required this.onRestaurantClick})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  bool _showMap = false;

  RestaurantFilters _filters = RestaurantFilters(
    cuisine: [],
    priceRange: [],
    rating: 0,
    distance: 10,
  );

  final List<String> cuisineTypes = [
    'Italien',
    'Français',
    'Japonais',
    'Indien',
    'Mexicain',
    'Chinois',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF5F5F5),
          child: Column(
            children: [
              _buildHeader(),
              _buildQuickFilters(),
              Expanded(
                child: _showMap ? _buildMapView() : _buildRestaurantList(),
              ),
            ],
          ),
        ),
        // FilterSheet overlay
        FilterSheet(
          open: _showFilters,
          onClose: () => setState(() => _showFilters = false),
          filters: _filters,
          onFiltersChange: (newFilters) {
            setState(() => _filters = newFilters);
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Découvrir des restaurants',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant, cuisine...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Boutons Filtres et Carte
          Row(
            children: [
              Expanded(
                child: _buildHeaderButton(
                  icon: Icons.tune,
                  label: 'Filtres',
                  onTap: () => setState(() => _showFilters = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderButton(
                  icon: Icons.map,
                  label: _showMap ? 'Liste' : 'Carte',
                  onTap: () => setState(() => _showMap = !_showMap),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickFilterChip(icon: Icons.star, label: 'Top notés'),
              const SizedBox(width: 8),
              _buildQuickFilterChip(
                icon: Icons.location_on,
                label: 'Près de moi',
              ),
              const SizedBox(width: 8),
              _buildQuickFilterChip(
                icon: Icons.attach_money,
                label: 'Bon marché',
              ),
              const SizedBox(width: 8),
              ...cuisineTypes
                  .take(3)
                  .map(
                    (cuisine) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildQuickFilterChip(label: cuisine),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip({IconData? icon, required String label}) {
    return GestureDetector(
      onTap: () {
        // Action pour le filtre rapide
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Vue Carte Interactive',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Intégration Google Maps / Mapbox',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLoadingDot(0),
                  const SizedBox(width: 8),
                  _buildLoadingDot(200),
                  const SizedBox(width: 8),
                  _buildLoadingDot(400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) setState(() {});
        });
      },
    );
  }

  Widget _buildRestaurantList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${mockRestaurants.length} restaurants trouvés',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        ...mockRestaurants.map(
          (restaurant) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RestaurantCard(
              restaurant: restaurant,
              onClick: () => widget.onRestaurantClick(restaurant.id),
            ),
          ),
        ),
      ],
    );
  }
}
