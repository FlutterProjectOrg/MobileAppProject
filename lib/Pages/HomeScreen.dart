import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/FilterSheet.dart';
import 'package:mobile_app_project/Pages/RestaurantCard.dart';
import 'package:mobile_app_project/Pages/mock_data.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onRestaurantClick;

  const HomeScreen({Key? key, required this.onRestaurantClick})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RestaurantService _restaurantService = RestaurantService.instance;
  final ScrollController _scrollController = ScrollController();

  bool _showFilters = false;
  bool _showMap = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _restaurants = [];
  String? _error;

  RestaurantFilters _filters = RestaurantFilters(
    cuisine: [],
    priceRange: [],
    rating: 0,
    distance: 10,
  );

  // Color scheme matching restaurant details
  final Color _primaryBlue = Color(0xFF4983A5);
  final Color _primaryPurple = Color(0xFFD19981);
  final Color _lightBlue = Color(0xFFE3F2FD);
  final Color _lightPurple = Color(0xFFF8E8E1);
  final Color _darkBlue = Color(0xFF114477);
  final Color _darkPurple = Color(0xFFB86847);

  final List<String> cuisineTypes = [
    'Italien',
    'Français',
    'Japonais',
    'Indien',
    'Mexicain',
    'Chinois',
    'Libanais',
    'Thaïlandais',
  ];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final restaurants = await _restaurantService.getAllRestaurants();

      if (mounted) {
        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading restaurants in HomeScreen: $e');
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement des restaurants';
          _isLoading = false;
        });
      }
    }
  }

  Restaurant _convertToMockRestaurant(Map<String, dynamic> restaurant) {
    final pictures = (restaurant['pictures'] as List?)?.cast<String>() ?? [];

    return Restaurant(
      id: restaurant['id'] as int,
      name: restaurant['name'] as String? ?? 'Nom inconnu',
      cuisine: 'Cuisine variée',
      rating: 4.5,
      reviews: 0,
      distance: '1.2 km',
      priceRange: '€€',
      isOpen: _isRestaurantOpen(restaurant),
      openUntil: '22:00',
      image: pictures.isNotEmpty ? pictures[0] : 'https://via.placeholder.com/300x200?text=Restaurant',
    );
  }

  bool _isRestaurantOpen(Map<String, dynamic> restaurant) {
    final workTime = (restaurant['work_time'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final now = DateTime.now();
    final currentDay = _getCurrentDay();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final daySchedule in workTime) {
      if (daySchedule['day'] == currentDay &&
          daySchedule['is_closed'] != true) {
        final openTime = daySchedule['open_time'] as String? ?? '00:00';
        final closeTime = daySchedule['close_time'] as String? ?? '23:59';

        return currentTime.compareTo(openTime) >= 0 &&
            currentTime.compareTo(closeTime) <= 0;
      }
    }

    return false;
  }

  String _getCurrentDay() {
    final days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days[DateTime.now().weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: _showMap ? _buildModernMapView() : _buildScrollableHomeScreen(),
        ),
        // FilterSheet overlay
        if (_showFilters)
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

  Widget _buildScrollableHomeScreen() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: _buildModernHeader(),
        ),

        // Quick Filters Section
        SliverToBoxAdapter(
          child: _buildModernQuickFilters(),
        ),

        // Restaurant List Section
        _buildRestaurantListSliver(),
      ],
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkBlue, _primaryBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Bonjour 👋',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Découvrez les meilleurs\nrestaurants près de chez vous',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 24),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant, une cuisine...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryBlue, _primaryPurple],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_rounded, color: Colors.white, size: 20),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildModernHeaderButton(
                  icon: Icons.tune_rounded,
                  label: 'Filtres',
                  onTap: () => setState(() => _showFilters = true),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildModernHeaderButton(
                  icon: _showMap ? Icons.list_rounded : Icons.map_rounded,
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

  Widget _buildModernHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernQuickFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Filtres rapides',
              style: TextStyle(
                color: _darkBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 4),
                _buildModernQuickFilterChip(
                  icon: Icons.star_rounded,
                  label: 'Top notés',
                  color: Colors.amber,
                ),
                SizedBox(width: 8),
                _buildModernQuickFilterChip(
                  icon: Icons.location_on_rounded,
                  label: 'Près de moi',
                  color: _primaryBlue,
                ),
                SizedBox(width: 8),
                _buildModernQuickFilterChip(
                  icon: Icons.attach_money_rounded,
                  label: 'Bon marché',
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                _buildModernQuickFilterChip(
                  icon: Icons.access_time_rounded,
                  label: 'Ouverts',
                  color: _primaryPurple,
                ),
                SizedBox(width: 8),
                ...cuisineTypes.take(4).map(
                      (cuisine) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildModernQuickFilterChip(label: cuisine),
                  ),
                ),
                SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuickFilterChip({
    IconData? icon,
    required String label,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        // Action pour le filtre rapide
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: color != null
              ? LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          )
              : LinearGradient(
            colors: [_lightBlue, _lightPurple.withOpacity(0.3)],
          ),
          border: Border.all(
            color: color?.withOpacity(0.3) ?? _primaryBlue.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: color ?? _primaryBlue,
              ),
              SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color ?? _darkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMapView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightBlue.withOpacity(0.1), _lightPurple.withOpacity(0.1)],
          ),
        ),
        child: Column(
          children: [
            // App Bar for Map View
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_darkBlue, _primaryBlue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => setState(() => _showMap = false),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Carte des restaurants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.my_location_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: _lightBlue),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryBlue, _primaryPurple],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.map_rounded, size: 40, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Vue Carte Interactive',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _darkBlue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Explorez les restaurants sur la carte',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _showMap = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Voir la liste',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantListSliver() {
    if (_isLoading) {
      return SliverFillRemaining(
        child: _buildModernLoadingState(),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: _buildModernErrorState(),
      );
    }

    if (_restaurants.isEmpty) {
      return SliverFillRemaining(
        child: _buildModernEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index == 0) {
            // Results count header
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_restaurants.length} restaurant${_restaurants.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: _darkBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.tune_rounded, color: _primaryBlue, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Trier',
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final restaurantIndex = index - 1;
          if (restaurantIndex < _restaurants.length) {
            final restaurant = _restaurants[restaurantIndex];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: RestaurantCard(
                restaurant: _convertToMockRestaurant(restaurant),
                onClick: () => widget.onRestaurantClick(restaurant['id'] as int),
              ),
            );
          }

          return SizedBox.shrink();
        },
        childCount: _restaurants.length + 1, // +1 for the header
      ),
    );
  }

  Widget _buildModernLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryBlue, _primaryPurple],
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Chargement des restaurants...',
            style: TextStyle(
              fontSize: 16,
              color: _darkBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nous préparons les meilleures adresses pour vous',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: _primaryPurple,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Oups !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Réessayer',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_lightBlue, _lightPurple],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 60,
                color: _primaryBlue,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Aucun restaurant disponible',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Les restaurants apparaîtront ici une fois créés.\nRevenez bientôt !',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Actualiser',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}