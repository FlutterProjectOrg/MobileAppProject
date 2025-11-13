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
  List<Restaurant> _allRestaurants = []; // Store all restaurants
  String _searchQuery = '';

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
    // Listen to search input
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
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
          _allRestaurants = restaurants;
          _restaurants = restaurants;
          _isLoading = false;
        });
        _applyFilters(); // Apply any active filters
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

  /// ⚡ Filter restaurants based on current filters and search query
  void _applyFilters() {
    List<Restaurant> filtered = List.from(_allRestaurants);

    // ✅ Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((restaurant) {
        return restaurant.name.toLowerCase().contains(query) ||
               restaurant.cuisine.toLowerCase().contains(query);
      }).toList();
    }

    // ✅ Apply cuisine filter
    if (_filters.cuisine.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        return _filters.cuisine.any((cuisine) =>
            restaurant.cuisine.toLowerCase().contains(cuisine.toLowerCase()));
      }).toList();
    }

    // ✅ Apply price range filter
    if (_filters.priceRange.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        return _filters.priceRange.contains(restaurant.priceRange);
      }).toList();
    }

    // ✅ Apply rating filter
    if (_filters.rating > 0) {
      filtered = filtered.where((restaurant) {
        return restaurant.rating >= _filters.rating;
      }).toList();
    }

    // ✅ Apply distance filter (if we had real location data)
    // Distance filtering would require actual GPS coordinates
    // For now, we'll skip this since we use default "1.5 km"

    setState(() {
      _restaurants = filtered;
    });
  }

  /// Quick filter actions
  void _applyQuickFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'Top notés':
          _filters = _filters.copyWith(rating: 4.0);
          break;
        case 'Près de moi':
          _filters = _filters.copyWith(distance: 5.0);
          break;
        case 'Bon marché':
          _filters = _filters.copyWith(priceRange: ['€', '€€']);
          break;
        default:
          // Cuisine filter
          if (cuisineTypes.contains(filterType)) {
            if (_filters.cuisine.contains(filterType)) {
              _filters = _filters.copyWith(
                cuisine: _filters.cuisine.where((c) => c != filterType).toList(),
              );
            } else {
              _filters = _filters.copyWith(
                cuisine: [..._filters.cuisine, filterType],
              );
            }
          }
      }
      _applyFilters();
    });
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _filters = RestaurantFilters(
        cuisine: [],
        priceRange: [],
        rating: 0,
        distance: 10,
      );
      _searchQuery = '';
      _searchController.clear();
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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
            setState(() {
              _filters = newFilters;
            });
            _applyFilters(); // ✅ Apply filters when changed
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
    // Check if this filter is active
    bool isActive = false;
    if (label == 'Top notés') {
      isActive = _filters.rating >= 4.0;
    } else if (label == 'Près de moi') {
      isActive = _filters.distance <= 5.0;
    } else if (label == 'Bon marché') {
      isActive = _filters.priceRange.contains('€') || 
                 _filters.priceRange.contains('€€');
    } else if (cuisineTypes.contains(label)) {
      isActive = _filters.cuisine.contains(label);
    }

    return GestureDetector(
      onTap: () => _applyQuickFilter(label), // ✅ Make functional
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.gradientPrimary : null,
          color: isActive ? null : Colors.white,
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppColors.primaryOrange.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(isActive ? 0.3 : 0.05),
              blurRadius: isActive ? 8 : 4,
              offset: Offset(0, isActive ? 3 : 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : AppColors.primaryOrange,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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

    // Check if any filters are active
    final bool hasActiveFilters = _filters.cuisine.isNotEmpty ||
        _filters.priceRange.isNotEmpty ||
        _filters.rating > 0 ||
        _searchQuery.isNotEmpty;

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilters ? Icons.filter_alt_off : Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters
                  ? 'Aucun restaurant trouvé'
                  : 'Aucun restaurant disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
                  ? 'Essayez de modifier vos filtres'
                  : 'Revenez plus tard ou ajoutez-en un',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Effacer les filtres'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
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
          // Filter status bar
          if (hasActiveFilters)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary.scale(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getActiveFiltersText(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Effacer'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_restaurants.length} restaurant${_restaurants.length > 1 ? 's' : ''} trouvé${_restaurants.length > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          // Restaurant list
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

  /// Get text describing active filters
  String _getActiveFiltersText() {
    List<String> parts = [];
    
    if (_searchQuery.isNotEmpty) {
      parts.add('Recherche: "$_searchQuery"');
    }
    if (_filters.cuisine.isNotEmpty) {
      parts.add('${_filters.cuisine.length} cuisine${_filters.cuisine.length > 1 ? 's' : ''}');
    }
    if (_filters.priceRange.isNotEmpty) {
      parts.add('Prix: ${_filters.priceRange.join(", ")}');
    }
    if (_filters.rating > 0) {
      parts.add('Note ≥ ${_filters.rating.toStringAsFixed(1)}');
    }
    
    return parts.join(' • ');
  }
}
