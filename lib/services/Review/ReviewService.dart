import 'package:flutter/foundation.dart';
import 'package:mobile_app_project/database/LocalDb.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  /// Add a new review for a restaurant
  /// If the user has already reviewed this restaurant, it will update the existing review
  Future<int> addReview({
    required int restaurantId,
    required int userId,
    required double rating,
    String comment = '',
  }) async {
    try {
      // Validate rating
      if (rating < 0 || rating > 5) {
        throw ArgumentError('Rating must be between 0 and 5');
      }

      final db = LocalDb.instance.db;

      // Check if user already reviewed this restaurant
      final existing = await db.query(
        'reviews',
        where: 'restaurant_id = ? AND user_id = ?',
        whereArgs: [restaurantId, userId],
      );

      int reviewId;

      if (existing.isNotEmpty) {
        // Update existing review
        reviewId = existing.first['id'] as int;
        await db.update(
          'reviews',
          {
            'rating': rating,
            'comment': comment,
            'created_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [reviewId],
        );
        debugPrint('Updated existing review ID: $reviewId');
      } else {
        // Insert new review
        reviewId = await db.insert('reviews', {
          'restaurant_id': restaurantId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('Created new review ID: $reviewId');
      }

      // Recalculate and update restaurant ratings
      await _updateRestaurantRating(restaurantId);

      return reviewId;
    } catch (e) {
      debugPrint('Error adding/updating review: $e');
      rethrow;
    }
  }

  /// Update an existing review
  Future<bool> updateReview({
    required int reviewId,
    required double rating,
    String comment = '',
  }) async {
    try {
      // Validate rating
      if (rating < 0 || rating > 5) {
        throw ArgumentError('Rating must be between 0 and 5');
      }

      final db = LocalDb.instance.db;

      // Get restaurant_id before updating
      final review = await db.query(
        'reviews',
        where: 'id = ?',
        whereArgs: [reviewId],
      );

      if (review.isEmpty) {
        debugPrint('Review not found with ID: $reviewId');
        return false;
      }

      final restaurantId = review.first['restaurant_id'] as int;

      // Update the review
      final count = await db.update(
        'reviews',
        {
          'rating': rating,
          'comment': comment,
          'created_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [reviewId],
      );

      if (count > 0) {
        // Recalculate restaurant rating
        await _updateRestaurantRating(restaurantId);
        debugPrint('Updated review ID: $reviewId');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error updating review: $e');
      rethrow;
    }
  }

  /// Delete a review
  Future<bool> deleteReview(int reviewId) async {
    try {
      final db = LocalDb.instance.db;

      // Get restaurant_id before deleting
      final review = await db.query(
        'reviews',
        where: 'id = ?',
        whereArgs: [reviewId],
      );

      if (review.isEmpty) {
        debugPrint('Review not found with ID: $reviewId');
        return false;
      }

      final restaurantId = review.first['restaurant_id'] as int;

      // Delete the review
      final count = await db.delete(
        'reviews',
        where: 'id = ?',
        whereArgs: [reviewId],
      );

      if (count > 0) {
        // Recalculate restaurant rating
        await _updateRestaurantRating(restaurantId);
        debugPrint('Deleted review ID: $reviewId');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }

  /// Get all reviews for a specific restaurant
  Future<List<Map<String, dynamic>>> getRestaurantReviews(int restaurantId) async {
    try {
      final db = LocalDb.instance.db;

      // Get reviews with user information
      final reviews = await db.rawQuery('''
        SELECT 
          r.id,
          r.restaurant_id,
          r.user_id,
          r.rating,
          r.comment,
          r.created_at,
          u.name AS user_name,
          u.email AS user_email,
          up.avatar_url AS user_avatar
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        LEFT JOIN user_profiles up ON r.user_id = up.user_id
        WHERE r.restaurant_id = ?
        ORDER BY r.created_at DESC
      ''', [restaurantId]);

      debugPrint('Found ${reviews.length} reviews for restaurant $restaurantId');
      return reviews;
    } catch (e) {
      debugPrint('Error getting restaurant reviews: $e');
      rethrow;
    }
  }

  /// Get a specific review by user and restaurant
  Future<Map<String, dynamic>?> getUserReviewForRestaurant({
    required int restaurantId,
    required int userId,
  }) async {
    try {
      final db = LocalDb.instance.db;

      final reviews = await db.query(
        'reviews',
        where: 'restaurant_id = ? AND user_id = ?',
        whereArgs: [restaurantId, userId],
      );

      if (reviews.isNotEmpty) {
        return reviews.first;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user review: $e');
      rethrow;
    }
  }

  /// Get restaurant rating summary
  Future<Map<String, dynamic>?> getRestaurantRating(int restaurantId) async {
    try {
      final db = LocalDb.instance.db;

      final ratings = await db.query(
        'restaurant_ratings',
        where: 'restaurant_id = ?',
        whereArgs: [restaurantId],
      );

      if (ratings.isNotEmpty) {
        return ratings.first;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting restaurant rating: $e');
      rethrow;
    }
  }

  /// Get all restaurants with their rating summaries
  Future<List<Map<String, dynamic>>> getRestaurantsWithRatings() async {
    try {
      final db = LocalDb.instance.db;

      final restaurants = await db.rawQuery('''
        SELECT 
          r.*,
          COALESCE(rr.average_rating, 0.0) AS average_rating,
          COALESCE(rr.total_reviews, 0) AS total_reviews
        FROM restaurants r
        LEFT JOIN restaurant_ratings rr ON r.id = rr.restaurant_id
        ORDER BY r.name ASC
      ''');

      debugPrint('Found ${restaurants.length} restaurants with ratings');
      return restaurants;
    } catch (e) {
      debugPrint('Error getting restaurants with ratings: $e');
      rethrow;
    }
  }

  /// Get top-rated restaurants
  Future<List<Map<String, dynamic>>> getTopRatedRestaurants({int limit = 10}) async {
    try {
      final db = LocalDb.instance.db;

      final restaurants = await db.rawQuery('''
        SELECT 
          r.*,
          rr.average_rating,
          rr.total_reviews
        FROM restaurants r
        INNER JOIN restaurant_ratings rr ON r.id = rr.restaurant_id
        WHERE rr.total_reviews > 0
        ORDER BY rr.average_rating DESC, rr.total_reviews DESC
        LIMIT ?
      ''', [limit]);

      debugPrint('Found ${restaurants.length} top-rated restaurants');
      return restaurants;
    } catch (e) {
      debugPrint('Error getting top-rated restaurants: $e');
      rethrow;
    }
  }

  /// Private method to recalculate and update restaurant rating
  Future<void> _updateRestaurantRating(int restaurantId) async {
    try {
      final db = LocalDb.instance.db;

      // Calculate average rating and total reviews
      final result = await db.rawQuery('''
        SELECT 
          AVG(rating) AS avg,
          COUNT(*) AS total
        FROM reviews
        WHERE restaurant_id = ?
      ''', [restaurantId]);

      if (result.isNotEmpty) {
        final avg = (result.first['avg'] as num?)?.toDouble() ?? 0.0;
        final total = (result.first['total'] as int?) ?? 0;

        // Insert or replace in restaurant_ratings
        await db.rawInsert('''
          INSERT OR REPLACE INTO restaurant_ratings (restaurant_id, average_rating, total_reviews)
          VALUES (?, ?, ?)
        ''', [restaurantId, avg, total]);

        debugPrint(
          'Updated restaurant $restaurantId rating: $avg (${total} reviews)',
        );
      }
    } catch (e) {
      debugPrint('Error updating restaurant rating: $e');
      rethrow;
    }
  }

  /// Get reviews by user
  Future<List<Map<String, dynamic>>> getUserReviews(int userId) async {
    try {
      final db = LocalDb.instance.db;

      final reviews = await db.rawQuery('''
        SELECT 
          r.id,
          r.restaurant_id,
          r.user_id,
          r.rating,
          r.comment,
          r.created_at,
          res.name AS restaurant_name,
          res.adresse AS restaurant_address
        FROM reviews r
        LEFT JOIN restaurants res ON r.restaurant_id = res.id
        WHERE r.user_id = ?
        ORDER BY r.created_at DESC
      ''', [userId]);

      debugPrint('Found ${reviews.length} reviews by user $userId');
      return reviews;
    } catch (e) {
      debugPrint('Error getting user reviews: $e');
      rethrow;
    }
  }

  /// Check if user has reviewed a restaurant
  Future<bool> hasUserReviewedRestaurant({
    required int restaurantId,
    required int userId,
  }) async {
    try {
      final db = LocalDb.instance.db;

      final count = sqflite.Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM reviews WHERE restaurant_id = ? AND user_id = ?',
          [restaurantId, userId],
        ),
      );

      return (count ?? 0) > 0;
    } catch (e) {
      debugPrint('Error checking user review: $e');
      rethrow;
    }
  }

  /// Get rating distribution for a restaurant
  Future<Map<int, int>> getRatingDistribution(int restaurantId) async {
    try {
      final db = LocalDb.instance.db;

      final distribution = await db.rawQuery('''
        SELECT 
          CAST(rating AS INTEGER) AS rating_value,
          COUNT(*) AS count
        FROM reviews
        WHERE restaurant_id = ?
        GROUP BY rating_value
        ORDER BY rating_value DESC
      ''', [restaurantId]);

      final Map<int, int> result = {
        5: 0,
        4: 0,
        3: 0,
        2: 0,
        1: 0,
      };

      for (final row in distribution) {
        final rating = (row['rating_value'] as int?) ?? 0;
        final count = (row['count'] as int?) ?? 0;
        if (rating >= 1 && rating <= 5) {
          result[rating] = count;
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error getting rating distribution: $e');
      rethrow;
    }
  }

  /// Delete all reviews for a restaurant (used when deleting a restaurant)
  Future<bool> deleteRestaurantReviews(int restaurantId) async {
    try {
      final db = LocalDb.instance.db;

      // Delete all reviews
      await db.delete(
        'reviews',
        where: 'restaurant_id = ?',
        whereArgs: [restaurantId],
      );

      // Delete rating entry
      await db.delete(
        'restaurant_ratings',
        where: 'restaurant_id = ?',
        whereArgs: [restaurantId],
      );

      debugPrint('Deleted all reviews for restaurant $restaurantId');
      return true;
    } catch (e) {
      debugPrint('Error deleting restaurant reviews: $e');
      rethrow;
    }
  }
}
