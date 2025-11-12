import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/StarRating.dart';
import 'package:mobile_app_project/services/Review/ReviewService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReviewModal extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;
  final Map<String, dynamic>? existingReview;
  final VoidCallback onReviewSubmitted;

  const AddReviewModal({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
    this.existingReview,
    required this.onReviewSubmitted,
  }) : super(key: key);

  @override
  State<AddReviewModal> createState() => _AddReviewModalState();
}

class _AddReviewModalState extends State<AddReviewModal> {
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = (widget.existingReview!['rating'] as num?)?.toDouble() ?? 0.0;
      _commentController.text = widget.existingReview!['comment'] ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Veuillez sélectionner une note'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      await ReviewService.instance.addReview(
        restaurantId: widget.restaurantId,
        userId: userId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Avis publié avec succès'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        widget.onReviewSubmitted();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Erreur: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rate_review,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Modifier votre avis' : 'Laisser un avis',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.restaurantName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Rating selector
              Center(
                child: Column(
                  children: [
                    Text(
                      'Votre note',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    InteractiveStarRating(
                      initialRating: _rating,
                      onRatingChanged: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    if (_rating > 0)
                      Text(
                        _getRatingText(_rating),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Comment input
              Text(
                'Votre commentaire (optionnel)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Mettre à jour' : 'Publier l\'avis',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent !';
    if (rating >= 3.5) return 'Très bien';
    if (rating >= 2.5) return 'Bien';
    if (rating >= 1.5) return 'Moyen';
    return 'Décevant';
  }
}
