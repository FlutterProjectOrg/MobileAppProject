import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/StarRating.dart';
import 'package:mobile_app_project/Pages/UI/ReviewCard.dart';
import 'package:mobile_app_project/Pages/AddReviewModal.dart';
import 'package:mobile_app_project/services/Review/ReviewService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class RestaurantReviewsSection extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;
  final bool showAddReviewButton;

  const RestaurantReviewsSection({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
    this.showAddReviewButton = true,
  }) : super(key: key);

  @override
  State<RestaurantReviewsSection> createState() =>
      _RestaurantReviewsSectionState();
}

class _RestaurantReviewsSectionState extends State<RestaurantReviewsSection> {
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _ratingData;
  Map<String, dynamic>? _userReview;
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getInt('userId');

      // Load rating summary
      final rating = await ReviewService.instance.getRestaurantRating(
        widget.restaurantId,
      );

      // Load all reviews
      final reviews = await ReviewService.instance.getRestaurantReviews(
        widget.restaurantId,
      );

      // Check if current user has reviewed
      Map<String, dynamic>? userReview;
      if (_currentUserId != null) {
        userReview = await ReviewService.instance.getUserReviewForRestaurant(
          restaurantId: widget.restaurantId,
          userId: _currentUserId!,
        );
      }

      if (mounted) {
        setState(() {
          _ratingData = rating;
          _reviews = reviews;
          _userReview = userReview;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddReviewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddReviewModal(
          restaurantId: widget.restaurantId,
          restaurantName: widget.restaurantName,
          existingReview: _userReview,
          onReviewSubmitted: _loadData,
        ),
      ),
    );
  }

  Future<void> _deleteReview() async {
    if (_userReview == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer l\'avis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre avis ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ReviewService.instance.deleteReview(_userReview!['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Avis supprimé'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(40),
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
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    final averageRating =
        (_ratingData?['average_rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (_ratingData?['total_reviews'] as int?) ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Avis clients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating Summary
          if (totalReviews > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      StarRating(rating: averageRating, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        '$totalReviews avis',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRatingBars()),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Add/Edit Review Button
          if (widget.showAddReviewButton) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddReviewModal,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(_userReview != null ? Icons.edit : Icons.add),
                label: Text(
                  _userReview != null ? 'Modifier mon avis' : 'Laisser un avis',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          // Reviews List
          if (_reviews.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                final isUserReview =
                    _currentUserId != null &&
                    review['user_id'] == _currentUserId;

                return ReviewCard(
                  review: review,
                  canEdit: isUserReview,
                  onEdit: isUserReview ? _showAddReviewModal : null,
                  onDelete: isUserReview ? _deleteReview : null,
                );
              },
            ),
          ] else if (totalReviews == 0) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun avis pour le moment',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Soyez le premier à laisser un avis !',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBars() {
    // This would ideally fetch actual distribution data
    // For now, showing a simplified version
    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$stars',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 12, color: AppColors.primaryYellow),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:
                        0.3, // Placeholder - should calculate from actual data
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryYellow,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
