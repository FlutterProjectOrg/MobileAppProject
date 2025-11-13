import 'package:flutter/material.dart';
import 'package:mobile_app_project/services/Review/review_service.dart';
import 'package:mobile_app_project/services/Auth/auth_service.dart';
import 'package:mobile_app_project/services/Review/review_filter_service.dart';

class AddReviewDialog extends StatefulWidget {
  final bool open;
  final VoidCallback onClose;
  final int restaurantId;
  final String restaurantName;
  final VoidCallback onReviewAdded;

  const AddReviewDialog({
    Key? key,
    required this.open,
    required this.onClose,
    required this.restaurantId,
    required this.restaurantName,
    required this.onReviewAdded,
  }) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  List<Review> _userPreviousReviews = [];
  bool _isLoadingPreviousReviews = false;

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
    _loadUserPreviousReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreviousReviews() async {
    final authService = AuthService();
    final currentUserId = authService.currentUserId;

    if (currentUserId != null) {
      setState(() {
        _isLoadingPreviousReviews = true;
      });

      try {
        final reviews = await ReviewService.instance.getUserReviewsForRestaurant(
            currentUserId,
            widget.restaurantId
        );

        setState(() {
          _userPreviousReviews = reviews;
          _isLoadingPreviousReviews = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingPreviousReviews = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    final authService = AuthService();
    final currentUserId = authService.currentUserId;
    final currentUserName = authService.currentUserName ?? 'Utilisateur';

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour ajouter un avis'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final comment = _commentController.text.trim();

    // Vérification du filtre
    final filterResult = ReviewFilterService.checkReview(comment);

    if (!filterResult.isValid) {
      _showFilterWarning(filterResult);
      return;
    }

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez écrire un commentaire'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (comment.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le commentaire ne peut pas dépasser 500 caractères'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Utiliser le texte filtré - CORRECTION ICI
      final filteredComment = ReviewFilterService.filterText(comment);

      final review = Review(
        id: 0,
        userId: currentUserId,
        restaurantId: widget.restaurantId,
        userName: currentUserName,
        rating: _selectedRating,
        comment: filteredComment,
        date: _formatDate(DateTime.now()),
        helpful: 0,
      );

      final reviewId = await ReviewService.instance.addReview(review);

      if (reviewId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Votre avis a été publié avec succès !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onReviewAdded();
        widget.onClose();
      } else {
        throw Exception('Erreur lors de l\'ajout de l\'avis');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showFilterWarning(FilterResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contenu inapproprié détecté'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Votre avis contient du contenu inapproprié :'),
            SizedBox(height: 8),
            Text(
              'Catégories détectées: ${result.bannedCategories.join(', ')}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 8),
            Text('Mots problématiques: ${result.foundWords.join(', ')}'),
            SizedBox(height: 12),
            Text('Veuillez modifier votre avis pour le rendre plus respectueux.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _resetForm() {
    setState(() {
      _selectedRating = 5;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox.shrink();

    return Dialog(
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85, // Increased height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, _lightBlue.withOpacity(0.1)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_darkBlue, _darkBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donner mon avis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.restaurantName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_userPreviousReviews.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            'Vous avez déjà ${_userPreviousReviews.length} avis sur ce restaurant',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: _isSubmitting ? null : widget.onClose,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Previous Reviews Info
                    if (_userPreviousReviews.isNotEmpty) ...[
                      _buildPreviousReviewsSection(),
                      SizedBox(height: 20),
                    ],

                    // Rating Section
                    _buildRatingSection(),
                    SizedBox(height: 24),

                    // Comment Section
                    _buildCommentSection(),
                    SizedBox(height: 24),

                    // Tips Section
                    _buildTipsSection(),
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _resetForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryBlue,
                        side: BorderSide(color: _primaryBlue),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Effacer'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Publier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousReviewsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: _primaryBlue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos avis précédents',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _darkBlue,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vous avez déjà publié ${_userPreviousReviews.length} avis sur ce restaurant. Chaque nouvelle visite mérite son propre avis !',
                  style: TextStyle(
                    fontSize: 12,
                    color: _darkBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryBlue, _primaryPurple],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star_rounded, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text(
              'Note globale',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _darkBlue,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _lightBlue),
          ),
          child: Column(
            children: [
              Text(
                '${_selectedRating}.0',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _darkBlue,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star_rounded,
                        size: 32,
                        color: index < _selectedRating ? Colors.amber : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 8),
              Text(
                _getRatingText(_selectedRating),
                style: TextStyle(
                  fontSize: 14,
                  color: _darkPurple,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryBlue, _primaryPurple],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.message_rounded, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text(
              'Votre commentaire',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _darkBlue,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _lightBlue),
            boxShadow: [
              BoxShadow(
                color: _lightBlue.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience au restaurant...\n\nEx: Service excellent, plats délicieux, ambiance agréable...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              counterText: '',
            ),
            style: TextStyle(
              color: _darkBlue,
              fontSize: 14,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${_commentController.text.length}/500 caractères',
          style: TextStyle(
            fontSize: 12,
            color: _commentController.text.length > 500 ? Colors.red : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_lightPurple, _lightBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryPurple.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primaryPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_rounded, size: 16, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseils pour un bon avis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _darkPurple,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• Soyez précis et honnête\n• Mentionnez les points forts et les améliorations\n• Partagez votre expérience globale\n• Évitez les commentaires offensants',
                  style: TextStyle(
                    fontSize: 12,
                    color: _darkPurple,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Médiocre - Très déçu';
      case 2:
        return 'Passable - Peu satisfait';
      case 3:
        return 'Bien - Satisfait';
      case 4:
        return 'Très bien - Très satisfait';
      case 5:
        return 'Excellent - Exceptionnel';
      default:
        return 'Sélectionnez une note';
    }
  }
}