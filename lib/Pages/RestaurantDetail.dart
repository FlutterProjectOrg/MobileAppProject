import 'package:flutter/material.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';
import 'package:mobile_app_project/services/Review/review_service.dart';
import 'package:mobile_app_project/Pages/ReservationDialog.dart';
import 'package:mobile_app_project/Pages/AddReviewDialog.dart';

import '../services/Auth/auth_service.dart';
import '../services/Like/like_service.dart';
import 'LikesListDialog.dart';

class RestaurantDetail extends StatefulWidget {
  final int restaurantId;
  final VoidCallback onBack;

  const RestaurantDetail({
    Key? key,
    required this.restaurantId,
    required this.onBack,
  }) : super(key: key);

  @override
  State<RestaurantDetail> createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _showReservation = false;
  bool _showAddReviewDialog = false;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // REAL DATA - Replace mock data with real data
  Map<String, dynamic>? _restaurant;
  bool _isLoading = true;
  String? _error;

  // Dynamic reviews data
  List<Review> _reviews = [];
  Map<String, dynamic> _reviewStats = {
    'totalReviews': 0,
    'averageRating': 0.0,
    'distribution': {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0},
  };
  bool _isLoadingReviews = false;

  // Mock menu data
  final List<Map<String, dynamic>> _mockMenuItems = [
    {
      'name': 'Salade César',
      'description': 'Laitue romaine, croûtons, parmesan, sauce césar',
      'price': 12.50,
      'isPopular': true,
      'image': 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=150'
    },
    {
      'name': 'Steak Frites',
      'description': 'Steak de bœuf 200g, frites maison, sauce au choix',
      'price': 18.90,
      'isPopular': true,
      'image': 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=150'
    },
    {
      'name': 'Pâtes Carbonara',
      'description': 'Pâtes fraîches, lardons, crème, parmesan',
      'price': 14.50,
      'isPopular': false,
      'image': 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=150'
    },
    {
      'name': 'Tiramisu',
      'description': 'Dessert italien au café et mascarpone',
      'price': 7.50,
      'isPopular': true,
      'image': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=150'
    },
  ];

  // Color scheme
  final Color _primaryBlue = Color(0xFF4983A5);
  final Color _primaryPurple = Color(0xFFD19981);
  final Color _lightBlue = Color(0xFFE3F2FD);
  final Color _lightPurple = Color(0xFFF8E8E1);
  final Color _darkBlue = Color(0xFF114477);
  final Color _darkPurple = Color(0xFFB86847);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRestaurantDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantDetails() async {
    try {
      final restaurantData = await RestaurantService.instance.getRestaurant(widget.restaurantId);

      if (mounted) {
        if (restaurantData != null) {
          setState(() {
            _restaurant = restaurantData;
            _isLoading = false;
          });
          _loadReviews();
        } else {
          setState(() {
            _error = 'Restaurant non trouvé';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading restaurant details: $e');
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLikeReview(Review review) async {
    final authService = AuthService();
    final currentUserId = authService.currentUserId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour liker un avis'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final likeService = LikeService.instance;
      final hasLiked = await likeService.hasUserLikedReview(currentUserId, review.id);

      if (hasLiked) {
        // Retirer le like
        await likeService.removeLike(currentUserId, review.id);
      } else {
        // Ajouter le like
        await likeService.addLike(currentUserId, review.id);
      }

      // Recharger les avis pour mettre à jour les compteurs
      _loadReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasLiked ? 'Like retiré' : 'Avis liké !'),
          backgroundColor: hasLiked ? Colors.grey : _primaryPurple,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

// Mettez à jour la méthode _loadReviews pour inclure les likes
  Future<void> _loadReviews() async {
    if (mounted) {
      setState(() {
        _isLoadingReviews = true;
      });
    }

    try {
      final authService = AuthService();
      final currentUserId = authService.currentUserId;

      // Récupérer les avis avec les compteurs de likes actualisés
      final reviews = await ReviewService.instance.getReviewsByRestaurantWithLikes(widget.restaurantId);
      final stats = await ReviewService.instance.getReviewStats(widget.restaurantId);

      // Vérifier les likes de l'utilisateur connecté
      if (currentUserId != null) {
        final userLikedReviews = await LikeService.instance.getUserLikedReviews(currentUserId);

        // Marquer les reviews likées par l'utilisateur
        for (int i = 0; i < reviews.length; i++) {
          reviews[i] = reviews[i].copyWith(
            isLikedByUser: userLikedReviews.contains(reviews[i].id),
          );
        }
      }

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _reviewStats = stats;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  void _openReservationDialog() {
    setState(() {
      _showReservation = true;
    });
  }

  void _closeReservationDialog() {
    setState(() {
      _showReservation = false;
    });
  }

  void _addReview() {
    setState(() {
      _showAddReviewDialog = true;
    });
  }

  void _closeAddReviewDialog() {
    setState(() {
      _showAddReviewDialog = false;
    });
  }

  void _onReviewAdded() {
    _loadReviews(); // Recharger les avis après ajout
    _closeAddReviewDialog();
  }

  // Helper methods to get restaurant data
  String get _restaurantName => _restaurant?['name'] as String? ?? 'Nom inconnu';
  String get _restaurantPhone => _restaurant?['phone'] as String? ?? 'Non disponible';
  String get _restaurantAddress => _restaurant?['adresse'] as String? ?? 'Adresse non spécifiée';
  List<String> get _restaurantPictures => (_restaurant?['pictures'] as List?)?.cast<String>() ?? [];
  String get _firstImage => _restaurantPictures.isNotEmpty ? _restaurantPictures[0] : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400';

  bool get _isRestaurantOpen {
    try {
      final workTime = (_restaurant?['work_time'] as List?)?.cast<Map<String, dynamic>>() ?? [];
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
    } catch (e) {
      debugPrint('Error checking restaurant open status: $e');
      return false;
    }
  }

  String _getCurrentDay() {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[DateTime.now().weekday - 1];
  }

  String _generateAISummary() {
    if (_reviews.isEmpty) {
      return 'Aucun avis disponible pour le moment. Soyez le premier à partager votre expérience !';
    }

    final averageRating = _reviewStats['averageRating'];
    final totalReviews = _reviewStats['totalReviews'];

    if (averageRating >= 4.5) {
      return '★★★★★ Les clients adorent ce restaurant ! La qualité exceptionnelle des plats et le service impeccable sont fréquemment mentionnés.';
    } else if (averageRating >= 4.0) {
      return '★★★★☆ Excellente expérience globale. Les clients apprécient particulièrement la qualité des plats et l\'ambiance chaleureuse.';
    } else if (averageRating >= 3.5) {
      return '★★★☆☆ Bon restaurant avec plusieurs points forts. La majorité des clients sont satisfaits de leur expérience.';
    } else if (averageRating >= 3.0) {
      return '★★★☆☆ Expérience correcte. Le restaurant a du potentiel mais certains points d\'amélioration sont mentionnés.';
    } else {
      return '★★☆☆☆ Retours mitigés. Certains aspects pourraient être améliorés selon les commentaires des clients.';
    }
  }

  Future<void> _markReviewHelpful(int reviewId) async {
    try {
      await ReviewService.instance.markHelpful(reviewId);
      _loadReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merci pour votre retour !'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primaryBlue,
        ),
      );
    } catch (e) {
      debugPrint('Error marking review as helpful: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_error != null || _restaurant == null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(),
                _buildModernTabBar(),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildMenuTab(),
                _buildReviewsTab(),
              ],
            ),
          ),

          // Floating Action Button for Reservation
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _openReservationDialog,
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: Icon(Icons.calendar_today, size: 20),
              label: Text('Réserver', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),

          if (_showReservation)
            ReservationDialog(
              open: _showReservation,
              onClose: _closeReservationDialog,
              restaurantName: _restaurantName,
              restaurantId: widget.restaurantId,
            ),

          if (_showAddReviewDialog)
            AddReviewDialog(
              open: _showAddReviewDialog,
              onClose: _closeAddReviewDialog,
              restaurantId: widget.restaurantId,
              restaurantName: _restaurantName,
              onReviewAdded: _onReviewAdded,
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: _primaryBlue,
              strokeWidth: 2,
            ),
            SizedBox(height: 20),
            Text(
              'Chargement du restaurant...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _primaryBlue),
          onPressed: widget.onBack,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 80, color: _primaryPurple),
              SizedBox(height: 24),
              Text(
                _error ?? 'Restaurant introuvable',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: widget.onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Retour à l\'accueil', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_rounded, size: 20, color: _primaryBlue),
        ),
        onPressed: widget.onBack,
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 20,
              color: _isFavorite ? _primaryPurple : _primaryBlue,
            ),
          ),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.share_rounded, size: 20, color: _primaryBlue),
          ),
          onPressed: _shareRestaurant,
        ),
        SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _firstImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: _lightBlue,
                child: Icon(Icons.restaurant_rounded, size: 80, color: _primaryBlue),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _darkBlue.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _restaurantName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              _reviewStats['averageRating'].toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '€€ • Cuisine variée',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildModernTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 20),

            // Quick Info Chips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModernInfoChip(
                    icon: Icons.location_on_rounded,
                    label: '1.2 km',
                  ),
                  _buildModernInfoChip(
                    icon: Icons.access_time_rounded,
                    label: _isRestaurantOpen ? 'Ouvert' : 'Fermé',
                    isHighlighted: _isRestaurantOpen,
                  ),
                  _buildModernInfoChip(
                    icon: Icons.phone_rounded,
                    label: 'Appeler',
                    onTap: _callRestaurant,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Modern Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: _lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lightBlue.withOpacity(0.5)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryPurple, _primaryPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: _primaryBlue,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(4),
                tabs: [
                  Tab(
                    icon: Icon(Icons.info_rounded, size: 20),
                    text: 'Infos',
                  ),
                  Tab(
                    icon: Icon(Icons.restaurant_menu_rounded, size: 20),
                    text: 'Menu',
                  ),
                  Tab(
                    icon: Icon(Icons.reviews_rounded, size: 20),
                    text: 'Avis (${_reviewStats['totalReviews']})',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoChip({
    required IconData icon,
    required String label,
    bool isHighlighted = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? LinearGradient(
            colors: [_primaryBlue, _primaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isHighlighted ? null : _lightBlue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted ? Colors.transparent : _primaryBlue.withOpacity(0.3),
          ),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: _primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isHighlighted ? Colors.white : _primaryBlue,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? Colors.white : _primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModernSection(
            title: 'Description',
            icon: Icons.description_rounded,
            child: Text(
              'Découvrez ${_restaurantName}, un restaurant proposant une cuisine de qualité dans une ambiance chaleureuse. Parfait pour les repas en famille ou entre amis.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildModernSection(
            title: 'Contact',
            icon: Icons.contact_phone_rounded,
            child: Column(
              children: [
                _buildModernContactItem(
                  icon: Icons.phone_rounded,
                  title: 'Téléphone',
                  value: _restaurantPhone,
                  onTap: _callRestaurant,
                ),
                SizedBox(height: 12),
                _buildModernContactItem(
                  icon: Icons.location_on_rounded,
                  title: 'Adresse',
                  value: _restaurantAddress,
                  onTap: _openMaps,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildModernSection(
            title: 'Horaires d\'ouverture',
            icon: Icons.schedule_rounded,
            child: _buildModernOpeningHours(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _lightBlue.withOpacity(0.5),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_lightBlue, _lightPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: _primaryBlue),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildModernContactItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _lightBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _lightBlue),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: _darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _primaryPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildModernOpeningHours() {
    final workTime = (_restaurant?['work_time'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    if (workTime.isEmpty) {
      return Text(
        'Horaires non disponibles',
        style: TextStyle(color: Colors.grey[600]),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _lightPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lightPurple),
      ),
      child: Column(
        children: days.map((day) {
          final schedule = workTime.firstWhere(
                (s) => s['day'] == day,
            orElse: () => {},
          );

          final isClosed = schedule['is_closed'] == true;
          final openTime = schedule['open_time'] as String? ?? '--:--';
          final closeTime = schedule['close_time'] as String? ?? '--:--';
          final isToday = day == _getCurrentDay();

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: day == days.last
                    ? BorderSide.none
                    : BorderSide(color: _lightPurple),
              ),
              color: isToday ? _primaryBlue.withOpacity(0.1) : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isToday ? _primaryBlue : _darkBlue,
                        fontSize: 15,
                      ),
                    ),
                    if (isToday) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryBlue, _primaryPurple],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Aujourd\'hui',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  isClosed ? 'Fermé' : '$openTime - $closeTime',
                  style: TextStyle(
                    color: isClosed ? Colors.red : (isToday ? _primaryPurple : _darkBlue),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          ..._mockMenuItems.map((item) => _buildModernMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildModernMenuItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _lightBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['isPopular'] == true) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryBlue, _primaryPurple],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🌟 Populaire',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _darkBlue,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${item['price']}€',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Image.network(
              item['image'] ?? '',
              width: 120,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 140,
                color: _lightBlue,
                child: Icon(Icons.restaurant_rounded, color: _primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primaryBlue),
            SizedBox(height: 16),
            Text(
              'Chargement des avis...',
              style: TextStyle(color: _darkBlue),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Modern Rating Summary Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _lightBlue,
                  _lightPurple,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.2),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          _reviewStats['averageRating'].toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: _darkBlue,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                                (index) => Icon(
                              Icons.star_rounded,
                              color: index < _reviewStats['averageRating'].round()
                                  ? Colors.amber
                                  : Colors.grey[300],
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${_reviewStats['totalReviews']} avis',
                          style: TextStyle(
                            color: _darkPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildModernRatingBar(5, _reviewStats['distribution'][5] ?? 0.0),
                          _buildModernRatingBar(4, _reviewStats['distribution'][4] ?? 0.0),
                          _buildModernRatingBar(3, _reviewStats['distribution'][3] ?? 0.0),
                          _buildModernRatingBar(2, _reviewStats['distribution'][2] ?? 0.0),
                          _buildModernRatingBar(1, _reviewStats['distribution'][1] ?? 0.0),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _generateAISummary(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _darkBlue,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // "Ajouter mon avis" Button - ALWAYS VISIBLE
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _lightBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(color: _lightBlue),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.reviews_rounded,
                  size: 40,
                  color: _primaryPurple,
                ),
                SizedBox(height: 12),
                Text(
                  'Partagez votre expérience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Votre avis aide les autres clients à faire leur choix',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _addReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_comment_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ajouter mon avis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Modern Reviews List
          if (_reviews.isNotEmpty) ...[
            Text(
              'Avis des clients (${_reviews.length})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
            ),
            SizedBox(height: 16),
            ..._reviews.map((review) => _buildModernReviewCard(review)),
            SizedBox(height: 16),
            if (_reviews.length > 3)
              OutlinedButton(
                onPressed: () {
                  // TODO: Implement "Voir tous les avis" functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fonctionnalité "Voir tous les avis" à implémenter'),
                      backgroundColor: _primaryBlue,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  side: BorderSide(color: _primaryBlue),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Voir tous les avis'),
              ),
          ],

          // Empty state when no reviews
          if (_reviews.isEmpty) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: _lightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _lightBlue),
              ),
              child: Column(
                children: [
                  Icon(Icons.rate_review_rounded, size: 60, color: _primaryBlue),
                  SizedBox(height: 16),
                  Text(
                    'Soyez le premier à donner votre avis !',
                    style: TextStyle(
                      fontSize: 16,
                      color: _darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Votre expérience aidera d\'autres clients à découvrir ce restaurant',
                    style: TextStyle(
                      fontSize: 14,
                      color: _darkPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernReviewCard(Review review) {
    final authService = AuthService();
    final currentUserId = authService.currentUserId;
    final isCurrentUserAuthor = currentUserId == review.userId;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _lightBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: _lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryBlue, _primaryPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: _darkBlue,
                          ),
                        ),
                        if (isCurrentUserAuthor) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _primaryBlue),
                            ),
                            child: Text(
                              'Vous',
                              style: TextStyle(
                                fontSize: 10,
                                color: _primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      review.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: _darkPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton de suppression (uniquement pour l'auteur)
              if (isCurrentUserAuthor)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: _primaryBlue,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(review);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                Icons.star_rounded,
                size: 18,
                color: index < review.rating ? Colors.amber : _lightBlue,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // Bouton Like avec état visuel
              TextButton.icon(
                onPressed: () => _toggleLikeReview(review),
                icon: Icon(
                  review.isLikedByUser ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                  size: 16,
                  color: review.isLikedByUser ? _primaryPurple : _primaryBlue,
                ),
                label: Text(
                  'Utile (${review.helpful})',
                  style: TextStyle(
                    color: review.isLikedByUser ? _primaryPurple : _primaryBlue,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: review.isLikedByUser ? _primaryPurple : _primaryBlue,
                ),
              ),
              Spacer(),
              // Nouveau bouton pour voir la liste des likes
              if (review.helpful > 0)
                TextButton.icon(
                  onPressed: () => _showLikesList(review),
                  icon: Icon(
                    Icons.people_rounded,
                    size: 16,
                    color: _primaryBlue,
                  ),
                  label: Text(
                    'Voir les likes',
                    style: TextStyle(
                      color: _primaryBlue,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryBlue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmation(Review review) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Supprimer l\'avis'),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer votre avis ? Cette action est irréversible.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: _primaryBlue),
              ),
            ),
            ElevatedButton(
              onPressed: () => _deleteReview(review),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReview(Review review) async {
    try {
      Navigator.of(context).pop(); // Fermer la boîte de dialogue

      // Supprimer d'abord tous les likes associés à cet avis
      final likeService = LikeService.instance;
      await likeService.removeAllLikesForReview(review.id);

      // Puis supprimer l'avis
      final result = await ReviewService.instance.deleteReview(review.id);

      if (result > 0) {
        // Recharger les avis
        _loadReviews();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Votre avis a été supprimé avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Erreur lors de la suppression');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }



  void _showLikesList(Review review) {
    showDialog(
      context: context,
      builder: (context) => LikesListDialog(
        reviewId: review.id,
        reviewAuthor: review.userName,
      ),
    );
  }

  Widget _buildModernRatingBar(int stars, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('$stars', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _darkBlue)),
          ),
          Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: _lightBlue,
                valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${(value * 100).round()}%',
            style: TextStyle(fontSize: 12, color: _darkPurple, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Helper methods for actions
  void _shareRestaurant() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité de partage à implémenter'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primaryBlue,
      ),
    );
  }

  void _callRestaurant() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel du restaurant: $_restaurantPhone'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primaryBlue,
      ),
    );
  }

  void _openMaps() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture de la carte pour: $_restaurantAddress'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primaryBlue,
      ),
    );
  }
}