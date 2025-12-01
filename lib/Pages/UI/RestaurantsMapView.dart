import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class RestaurantsMapView extends StatefulWidget {
  final List<Map<String, dynamic>> restaurants;
  final Function(int restaurantId)? onRestaurantTap;

  const RestaurantsMapView({
    Key? key,
    required this.restaurants,
    this.onRestaurantTap,
  }) : super(key: key);

  @override
  State<RestaurantsMapView> createState() => _RestaurantsMapViewState();
}

class _RestaurantsMapViewState extends State<RestaurantsMapView> {
  late MapController _mapController;
  Map<String, dynamic>? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  LatLng _getCenterPosition() {
    // Filter restaurants with valid coordinates
    final validRestaurants = widget.restaurants
        .where((r) => r['latitude'] != null && r['longitude'] != null)
        .toList();

    if (validRestaurants.isEmpty) {
      // Default to Paris, France
      return LatLng(48.8566, 2.3522);
    }

    if (validRestaurants.length == 1) {
      return LatLng(
        validRestaurants[0]['latitude'] as double,
        validRestaurants[0]['longitude'] as double,
      );
    }

    // Calculate center of all restaurants
    double totalLat = 0;
    double totalLng = 0;
    for (var restaurant in validRestaurants) {
      totalLat += restaurant['latitude'] as double;
      totalLng += restaurant['longitude'] as double;
    }
    return LatLng(
      totalLat / validRestaurants.length,
      totalLng / validRestaurants.length,
    );
  }

  List<Marker> _buildMarkers() {
    return widget.restaurants
        .where((r) => r['latitude'] != null && r['longitude'] != null)
        .map((restaurant) {
      final position = LatLng(
        restaurant['latitude'] as double,
        restaurant['longitude'] as double,
      );

      return Marker(
        point: position,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedRestaurant = restaurant;
            });
            _mapController.move(position, 15);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              // Marker
              const Icon(
                Icons.location_on,
                color: AppColors.primaryOrange,
                size: 40,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final validRestaurants = widget.restaurants
        .where((r) => r['latitude'] != null && r['longitude'] != null)
        .length;

    if (validRestaurants == 0) {
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
                    color: AppColors.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_off,
                    size: 48,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aucun restaurant avec localisation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Les restaurants apparaîtront ici une fois\nleur emplacement ajouté sur la carte',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _getCenterPosition(),
            initialZoom: 12.0,
            minZoom: 3.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.foodfinder.mobile',
            ),
            MarkerLayer(
              markers: _buildMarkers(),
            ),
          ],
        ),

        // Restaurant count badge
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '$validRestaurants',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected restaurant info card
        if (_selectedRestaurant != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedRestaurant!['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _selectedRestaurant!['adresse'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
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
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          color: AppColors.primaryOrange,
                          onPressed: () {
                            if (widget.onRestaurantTap != null) {
                              widget.onRestaurantTap!(
                                _selectedRestaurant!['id'] as int,
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: Colors.grey[600],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _selectedRestaurant = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

