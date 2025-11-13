import 'package:mobile_app_project/database/LocalDb.dart';
import 'package:sqflite/sqflite.dart';

import '../Like/like_service.dart';

class Review {
  final int id;
  final int userId;
  final int restaurantId;
  final String userName;
  final int rating;
  final String comment;
  final String date;
  final int helpful;
  final String? createdAt;
  bool isLikedByUser;

  Review({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.helpful,
    this.createdAt,
    this.isLikedByUser = false,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      restaurantId: map['restaurant_id'] as int,
      userName: map['user_name'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      date: map['date'] as String,
      helpful: map['helpful'] as int,
      createdAt: map['created_at'] as String?,
      isLikedByUser: false, // Sera mis à jour séparément
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'date': date,
      'helpful': helpful,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'restaurant_id': restaurantId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'date': date,
      'helpful': helpful,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Review copyWith({
    int? id,
    int? userId,
    int? restaurantId,
    String? userName,
    int? rating,
    String? comment,
    String? date,
    int? helpful,
    String? createdAt,
    bool? isLikedByUser,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      helpful: helpful ?? this.helpful,
      createdAt: createdAt ?? this.createdAt,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
    );
  }
}

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  Future<void> initialize() async {
    final db = await LocalDb.instance.init();
    await _createReviewsTable(db);
  }

  Future<void> _createReviewsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        restaurant_id INTEGER NOT NULL,
        user_name TEXT NOT NULL,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT NOT NULL,
        date TEXT NOT NULL,
        helpful INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reviews_restaurant_id ON reviews(restaurant_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at)');
  }

  // Récupérer tous les avis d'un restaurant
  Future<List<Review>> getReviewsByRestaurant(int restaurantId) async {
    final db = await LocalDb.instance.init();
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Review.fromMap(maps[i]);
    });
  }


  Future<List<Review>> getUserReviewsForRestaurant(int userId, int restaurantId) async {
    final db = await LocalDb.instance.init();
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'user_id = ? AND restaurant_id = ?',
      whereArgs: [userId, restaurantId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Review.fromMap(maps[i]);
    });
  }

  // Ajouter un nouvel avis - FIXED VERSION


  // Ajouter un nouvel avis - MODIFIED TO ALLOW MULTIPLE REVIEWS
  Future<int> addReview(Review review) async {
    final db = await LocalDb.instance.init();

    // Use toInsertMap() which excludes the id field
    final reviewMap = review.toInsertMap();

    return await db.insert('reviews', reviewMap);
  }

  // Récupérer les statistiques des avis
  Future<Map<String, dynamic>> getReviewStats(int restaurantId) async {
    final db = await LocalDb.instance.init();

    // Nombre total d'avis
    final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM reviews WHERE restaurant_id = ?',
        [restaurantId]
    );
    final totalReviews = countResult.first['count'] as int;

    // Note moyenne
    final avgResult = await db.rawQuery(
        'SELECT AVG(rating) as average FROM reviews WHERE restaurant_id = ?',
        [restaurantId]
    );
    final averageRating = avgResult.first['average'] as double? ?? 0.0;

    // Distribution des notes
    final distributionResult = await db.rawQuery('''
      SELECT rating, COUNT(*) as count 
      FROM reviews 
      WHERE restaurant_id = ? 
      GROUP BY rating 
      ORDER BY rating DESC
    ''', [restaurantId]);

    final distribution = Map<int, double>.fromIterable(
      List.generate(5, (i) => i + 1),
      key: (star) => star,
      value: (star) {
        final match = distributionResult.firstWhere(
              (item) => item['rating'] == star,
          orElse: () => {'count': 0},
        );
        return totalReviews > 0 ? (match['count'] as int) / totalReviews : 0.0;
      },
    );

    return {
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'distribution': distribution,
    };
  }

  // Marquer un avis comme utile
  Future<void> markHelpful(int reviewId) async {
    final db = await LocalDb.instance.init();
    await db.rawUpdate(
        'UPDATE reviews SET helpful = helpful + 1 WHERE id = ?',
        [reviewId]
    );
  }

  // Vérifier si l'utilisateur a déjà posté un avis pour ce restaurant
  // KEEP THIS METHOD but don't use it to block reviews
  Future<bool> hasUserReviewedRestaurant(int userId, int restaurantId) async {
    final db = await LocalDb.instance.init();
    final result = await db.query(
      'reviews',
      where: 'user_id = ? AND restaurant_id = ?',
      whereArgs: [userId, restaurantId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Récupérer le dernier avis de l'utilisateur pour ce restaurant
  Future<Review?> getLatestUserReview(int userId, int restaurantId) async {
    final db = await LocalDb.instance.init();
    final result = await db.query(
      'reviews',
      where: 'user_id = ? AND restaurant_id = ?',
      whereArgs: [userId, restaurantId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return result.isNotEmpty ? Review.fromMap(result.first) : null;
  }

  // Supprimer un avis
  Future<int> deleteReview(int reviewId) async {
    final db = await LocalDb.instance.init();
    return await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [reviewId],
    );
  }

  // Récupérer un avis par son ID
  Future<Review?> getReviewById(int reviewId) async {
    final db = await LocalDb.instance.init();
    final result = await db.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [reviewId],
      limit: 1,
    );
    return result.isNotEmpty ? Review.fromMap(result.first) : null;
  }


  Future<void> updateReviewLikeCount(int reviewId, int newCount) async {
    final db = await LocalDb.instance.init();
    await db.update(
      'reviews',
      {'helpful': newCount},
      where: 'id = ?',
      whereArgs: [reviewId],
    );
  }

  // Récupérer une review avec son compteur de likes actualisé
  Future<Review?> getReviewWithLikes(int reviewId) async {
    final db = await LocalDb.instance.init();
    final result = await db.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [reviewId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final review = Review.fromMap(result.first);
      // Mettre à jour le compteur de likes
      final likeCount = await LikeService.instance.getLikeCount(reviewId);
      return review.copyWith(helpful: likeCount);
    }
    return null;
  }

  // Récupérer toutes les reviews avec leurs compteurs de likes actualisés
  Future<List<Review>> getReviewsByRestaurantWithLikes(int restaurantId) async {
    final db = await LocalDb.instance.init();
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
      orderBy: 'created_at DESC',
    );

    final reviews = List.generate(maps.length, (i) {
      return Review.fromMap(maps[i]);
    });

    // Mettre à jour les compteurs de likes pour chaque review
    for (int i = 0; i < reviews.length; i++) {
      final likeCount = await LikeService.instance.getLikeCount(reviews[i].id);
      reviews[i] = reviews[i].copyWith(helpful: likeCount);
    }

    return reviews;
  }


  Future<bool> isUserReviewAuthor(int reviewId, int userId) async {
    final db = await LocalDb.instance.init();
    final result = await db.query(
      'reviews',
      where: 'id = ? AND user_id = ?',
      whereArgs: [reviewId, userId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
