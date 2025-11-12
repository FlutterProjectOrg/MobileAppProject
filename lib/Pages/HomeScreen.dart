import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/FilterSheet.dart';
import 'package:mobile_app_project/Pages/RestaurantCard.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';
import 'package:mobile_app_project/Pages/mock_data.dart';
import 'package:mobile_app_project/services/Review/ReviewService.dart';
import 'dart:convert';

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
  bool _isLoading = true;
  List<Restaurant> _restaurants = [];

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
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final restaurantsData = await ReviewService.instance.getRestaurantsWithRatings();
      
      final restaurants = restaurantsData.map((data) {
        // Parse pictures JSON
        final picturesStr = (data['pictures'] as String?) ?? '[]';
        final picturesList = List<String>.from(jsonDecode(picturesStr));
        final imageUrl = picturesList.isNotEmpty 
            ? picturesList[0] 
            : 'https://via.placeholder.com/400x200?text=Restaurant';

        // Get rating data
        final averageRating = (data['average_rating'] as num?)?.toDouble() ?? 0.0;
        final totalReviews = (data['total_reviews'] as int?) ?? 0;

        return Restaurant(
          id: data['id'] as int,
          name: data['name'] as String,
          cuisine: 'Cuisine variée', // Default cuisine type
          rating: averageRating,
          reviews: totalReviews,
          distance: '1.5 km', // Default distance
          priceRange: '€€', // Default price range
          image: imageUrl,
          isOpen: true, // Default to open
          openUntil: '22:00',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading restaurants: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
          color: AppColors.background,
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
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
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
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant, cuisine...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryOrange,
                ),
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
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
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
              color: AppColors.primaryOrange.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.primaryOrange),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.primaryOrange.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary.scale(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.map,
                  size: 48,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Vue Carte Interactive',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intégration Google Maps / Mapbox',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),
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
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun restaurant disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenez plus tard ou ajoutez-en un',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      color: const Color(0xFF3B82F6),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_restaurants.length} restaurant${_restaurants.length > 1 ? 's' : ''} trouvé${_restaurants.length > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          ..._restaurants.map(
            (restaurant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RestaurantCard(
                restaurant: restaurant,
                onClick: () => widget.onRestaurantClick(restaurant.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
