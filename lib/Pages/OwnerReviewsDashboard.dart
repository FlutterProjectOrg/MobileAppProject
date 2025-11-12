import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/StarRating.dart';
import 'package:mobile_app_project/Pages/UI/ReviewCard.dart';
import 'package:mobile_app_project/services/Review/ReviewService.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerReviewsDashboard extends StatefulWidget {
  const OwnerReviewsDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerReviewsDashboard> createState() => _OwnerReviewsDashboardState();
}

class _OwnerReviewsDashboardState extends State<OwnerReviewsDashboard> {
  List<Map<String, dynamic>> _restaurants = [];
  Map<int, List<Map<String, dynamic>>> _restaurantReviews = {};
  Map<int, Map<String, dynamic>> _restaurantRatings = {};
  bool _isLoading = true;
  int? _selectedRestaurantId;

  @override
  void initState() {
    super.initState();
    _loadOwnerRestaurants();
  }

  Future<void> _loadOwnerRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerId = prefs.getInt('userId');

      if (ownerId == null) {
        throw Exception('Owner ID not found');
      }

      // Get all restaurants owned by this user
      final restaurants = await RestaurantService.instance.getRestaurantsByOwner(ownerId);

      // Load reviews and ratings for each restaurant
      final Map<int, List<Map<String, dynamic>>> reviews = {};
      final Map<int, Map<String, dynamic>> ratings = {};

      for (final restaurant in restaurants) {
        final restaurantId = restaurant['id'] as int;
        
        // Get reviews
        final restaurantReviews = await ReviewService.instance.getRestaurantReviews(restaurantId);
        reviews[restaurantId] = restaurantReviews;

        // Get rating summary
        final ratingData = await ReviewService.instance.getRestaurantRating(restaurantId);
        if (ratingData != null) {
          ratings[restaurantId] = ratingData;
        }
      }

      if (mounted) {
        setState(() {
          _restaurants = restaurants;
          _restaurantReviews = reviews;
          _restaurantRatings = ratings;
          _isLoading = false;
          
          // Auto-select first restaurant if available
          if (_restaurants.isNotEmpty && _selectedRestaurantId == null) {
            _selectedRestaurantId = _restaurants.first['id'] as int;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading owner restaurants: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Mes Avis Clients',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOwnerRestaurants,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            )
          : _restaurants.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun restaurant trouvé',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez un restaurant pour voir les avis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Restaurant selector
        if (_restaurants.length > 1) _buildRestaurantSelector(),
        
        // Summary cards
        _buildSummaryCards(),
        
        // Reviews list
        Expanded(child: _buildReviewsList()),
      ],
    );
  }

  Widget _buildRestaurantSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<int>(
        value: _selectedRestaurantId,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)),
        items: _restaurants.map((restaurant) {
          return DropdownMenuItem<int>(
            value: restaurant['id'] as int,
            child: Text(
              restaurant['name'] ?? 'Restaurant',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRestaurantId = value;
          });
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_selectedRestaurantId == null) return const SizedBox.shrink();

    final ratingData = _restaurantRatings[_selectedRestaurantId];
    final averageRating = (ratingData?['average_rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (ratingData?['total_reviews'] as int?) ?? 0;
    final reviews = _restaurantReviews[_selectedRestaurantId] ?? [];

    // Calculate recent reviews (last 7 days)
    final now = DateTime.now();
    final recentReviews = reviews.where((review) {
      try {
        final createdAt = DateTime.parse(review['created_at'] as String);
        return now.difference(createdAt).inDays <= 7;
      } catch (e) {
        return false;
      }
    }).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Average Rating Card
          Expanded(
            child: _buildStatCard(
              icon: Icons.star,
              title: 'Note moyenne',
              value: averageRating.toStringAsFixed(1),
              subtitle: StarRating(rating: averageRating, size: 16),
              color: const Color(0xFFFFC107),
            ),
          ),
          const SizedBox(width: 12),
          // Total Reviews Card
          Expanded(
            child: _buildStatCard(
              icon: Icons.rate_review,
              title: 'Total avis',
              value: totalReviews.toString(),
              subtitle: Text(
                'Tous les avis',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          // Recent Reviews Card
          Expanded(
            child: _buildStatCard(
              icon: Icons.trending_up,
              title: 'Cette semaine',
              value: recentReviews.toString(),
              subtitle: Text(
                'Nouveaux avis',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              color: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Widget subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          subtitle,
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_selectedRestaurantId == null) return const SizedBox.shrink();

    final reviews = _restaurantReviews[_selectedRestaurantId] ?? [];

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun avis pour ce restaurant',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les avis de vos clients apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Avis clients (${reviews.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ReviewCard(
                  review: reviews[index],
                  canEdit: false, // Owners cannot edit customer reviews
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
