import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/RestaurantCard.dart';
import 'package:mobile_app_project/Pages/mock_data.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(int) onRestaurantClick;

  const FavoritesScreen({Key? key, required this.onRestaurantClick})
    : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = mockRestaurants.sublist(0, 3);
    final recentlyViewed = mockRestaurants.sublist(2, 5);
    final recommendations = mockRestaurants.sublist(1, 4);

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFavoritesTab(favorites),
                        _buildRecentTab(recentlyViewed),
                        _buildRecommendedTab(recommendations),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            'Mes favoris',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos restaurants préférés et recommandations',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: 16),
                SizedBox(width: 6),
                Text('Favoris'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 6),
                Text('Récents'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 16),
                SizedBox(width: 6),
                Text('Pour vous'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(List<Restaurant> favorites) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${favorites.length} restaurants',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          ...favorites.map(
            (restaurant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RestaurantCard(
                restaurant: restaurant,
                onClick: () => widget.onRestaurantClick(restaurant.id),
              ),
            ),
          ),
        ] else
          _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'Aucun favori',
            message:
                'Ajoutez vos restaurants préférés pour les retrouver facilement',
          ),
      ],
    );
  }

  Widget _buildRecentTab(List<Restaurant> recentlyViewed) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique de recherche',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              TextButton(
                onPressed: () {
                  // Logique pour effacer l'historique
                },
                child: const Text(
                  'Effacer',
                  style: TextStyle(color: Color(0xFF3B82F6), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        ...recentlyViewed.map(
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

  Widget _buildRecommendedTab(List<Restaurant> recommendations) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildAIRecommendationCard(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${recommendations.length} suggestions pour vous',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        ...recommendations.map(
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

  Widget _buildAIRecommendationCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFAF5FF), // purple-50
            Color(0xFFFDF2F8), // pink-50
          ],
        ),
        border: Border.all(color: const Color(0xFFE9D5FF)), // purple-200
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFA855F7), // purple-500
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommandations IA personnalisées',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Basées sur vos préférences culinaires et votre localisation',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge('Italien'),
                    _buildBadge('Budget moyen'),
                    _buildBadge('Près de vous'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
