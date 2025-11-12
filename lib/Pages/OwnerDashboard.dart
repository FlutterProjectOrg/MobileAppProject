import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app_project/services/Auth/auth_service.dart';
import 'package:mobile_app_project/Pages/AddRestaurantModal.dart';
import 'package:mobile_app_project/Pages/RestaurantDetailOwner.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class Restaurant {
  final int id;
  final String name;
  final String adresse;

  Restaurant({required this.id, required this.name, required this.adresse});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      adresse: json['adresse'],
    );
  }
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final _authService = AuthService();
  String _ownerName = 'Loading...';
  bool _isLoading = true;
  List<Restaurant> _restaurants = [];
  int? _ownerId;

  @override
  void initState() {
    super.initState();
    _loadOwnerInfo();
  }

  Future<void> _loadOwnerInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        setState(() {
          _ownerId = userId;
        });

        final profile = await _authService.getOwnerProfile(userId);
        if (profile != null && mounted) {
          setState(() {
            _ownerName = profile.name;
          });
        }

        // Fetch restaurants
        await _loadRestaurants(userId);
      }
    } catch (e) {
      debugPrint('Error loading owner info: $e');
      if (mounted) {
        setState(() {
          _ownerName = 'Owner';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRestaurants(int ownerId) async {
    try {
      // Fetch restaurants from local SQLite database
      final data = await RestaurantService.instance.getRestaurantsByOwner(ownerId);
      
      if (mounted) {
        setState(() {
          _restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
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

  void _showAddRestaurantModal() {
    if (_ownerId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddRestaurantModal(
          ownerId: _ownerId!,
          onRestaurantAdded: () {
            // Reload restaurants after adding
            _loadOwnerInfo();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _restaurants.isEmpty
                    ? _buildEmptyState()
                    : _buildRestaurantList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Bonjour, $_ownerName! 👋',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Vous n\'avez pas encore de restaurants',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddRestaurantModal,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un restaurant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantList() {
    return Column(
      children: [
        // Welcome message
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.waving_hand, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, $_ownerName!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_restaurants.length} restaurant${_restaurants.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes restaurants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              IconButton(
                onPressed: _showAddRestaurantModal,
                icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)),
                iconSize: 32,
              ),
            ],
          ),
        ),
        // Restaurant list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = _restaurants[index];
              return _buildRestaurantCard(restaurant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RestaurantDetailOwner(restaurantId: restaurant.id),
              ),
            ).then((_) {
              // Refresh the list when returning from detail screen
              if (_ownerId != null) {
                _loadRestaurants(_ownerId!);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Restaurant info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant.adresse,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tableau de bord',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gérez vos restaurants et plats',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
