import 'package:mobile_app_project/database/LocalDb.dart';
import 'package:sqflite/sqflite.dart';

class LikeService {
  LikeService._();
  static final LikeService instance = LikeService._();

  Future<void> initialize() async {
    final db = await LocalDb.instance.init();
    await _createLikesTable(db);
  }

  Future<void> _createLikesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        review_id INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (review_id) REFERENCES reviews (id) ON DELETE CASCADE,
        UNIQUE(user_id, review_id)
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_likes_review_id ON likes(review_id)');
  }

  // Ajouter un like
  Future<bool> addLike(int userId, int reviewId) async {
    try {
      final db = await LocalDb.instance.init();

      // Vérifier si l'utilisateur a déjà liké cette review
      final existingLike = await db.query(
        'likes',
        where: 'user_id = ? AND review_id = ?',
        whereArgs: [userId, reviewId],
      );

      if (existingLike.isEmpty) {
        await db.insert('likes', {
          'user_id': userId,
          'review_id': reviewId,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding like: $e');
      return false;
    }
  }

  // Retirer un like
  Future<bool> removeLike(int userId, int reviewId) async {
    try {
      final db = await LocalDb.instance.init();
      final count = await db.delete(
        'likes',
        where: 'user_id = ? AND review_id = ?',
        whereArgs: [userId, reviewId],
      );
      return count > 0;
    } catch (e) {
      print('Error removing like: $e');
      return false;
    }
  }

  // Vérifier si l'utilisateur a liké une review
  Future<bool> hasUserLikedReview(int userId, int reviewId) async {
    try {
      final db = await LocalDb.instance.init();
      final result = await db.query(
        'likes',
        where: 'user_id = ? AND review_id = ?',
        whereArgs: [userId, reviewId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking like: $e');
      return false;
    }
  }

  // Compter le nombre de likes pour une review
  Future<int> getLikeCount(int reviewId) async {
    try {
      final db = await LocalDb.instance.init();
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM likes WHERE review_id = ?',
        [reviewId],
      );
      return result.first['count'] as int;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }

  // Récupérer tous les likes d'un utilisateur
  Future<List<int>> getUserLikedReviews(int userId) async {
    try {
      final db = await LocalDb.instance.init();
      final result = await db.query(
        'likes',
        where: 'user_id = ?',
        whereArgs: [userId],
        columns: ['review_id'],
      );
      return result.map((map) => map['review_id'] as int).toList();
    } catch (e) {
      print('Error getting user likes: $e');
      return [];
    }
  }

  // Supprimer tous les likes d'une review (utile quand on supprime une review)
  Future<void> deleteLikesForReview(int reviewId) async {
    try {
      final db = await LocalDb.instance.init();
      await db.delete(
        'likes',
        where: 'review_id = ?',
        whereArgs: [reviewId],
      );
    } catch (e) {
      print('Error deleting likes for review: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsersWhoLikedReview(int reviewId) async {
    try {
      final db = await LocalDb.instance.init();
      final result = await db.rawQuery('''
        SELECT 
          u.id as user_id,
          u.name as user_name,
          u.email as user_email,
          l.created_at as liked_at
        FROM likes l
        JOIN users u ON l.user_id = u.id
        WHERE l.review_id = ?
        ORDER BY l.created_at DESC
      ''', [reviewId]);

      return result;
    } catch (e) {
      print('Error getting users who liked review: $e');
      return [];
    }
  }

  // Récupérer les informations d'un utilisateur
  Future<Map<String, dynamic>?> getUserInfo(int userId) async {
    try {
      final db = await LocalDb.instance.init();
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  Future<void> removeAllLikesForReview(int reviewId) async {
    final db = await LocalDb.instance.init();
    await db.delete(
      'likes',
      where: 'review_id = ?',
      whereArgs: [reviewId],
    );
  }
}

