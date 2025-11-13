import 'dart:convert';
import 'package:mobile_app_project/database/LocalDb.dart';

class DishService {
  DishService._();
  static final DishService instance = DishService._();

  Future<int> createDish(Map<String, dynamic> data) async {
    final db = LocalDb.instance.db;
    final name = data['name'] as String;
    final category = data['category'] as String;
    final restaurantId = data['restaurant_id'] as int;
    final pictures = (data['pictures'] as List?)?.cast<String>() ?? [];
    final picsJson = jsonEncode(pictures);

    final id = await db.insert('dishes', {
      'name': name,
      'category': category,
      'pictures': picsJson,
      'restaurant_id': restaurantId,
    });
    return id;
  }

  Future<Map<String, dynamic>?> getDish(int id) async {
    final db = LocalDb.instance.db;
    final rows = await db.query(
      'dishes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapDishRow(rows.first);
  }

  Future<List<Map<String, dynamic>>> getAllDishes() async {
    final db = LocalDb.instance.db;
    final rows = await db.query('dishes');
    return rows.map(_mapDishRow).toList();
  }

  Future<List<Map<String, dynamic>>> getDishesByRestaurant(
    int restaurantId,
  ) async {
    final db = LocalDb.instance.db;
    final rows = await db.query(
      'dishes',
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
    );
    return rows.map(_mapDishRow).toList();
  }

  Future<List<Map<String, dynamic>>> getDishesByCategory(
    String category,
  ) async {
    final db = LocalDb.instance.db;
    final rows = await db.query(
      'dishes',
      where: 'category = ?',
      whereArgs: [category],
    );
    return rows.map(_mapDishRow).toList();
  }

  Future<bool> updateDish(int id, Map<String, dynamic> data) async {
    final db = LocalDb.instance.db;
    final picsJson = jsonEncode(
      (data['pictures'] as List?)?.cast<String>() ?? [],
    );
    final count = await db.update(
      'dishes',
      {
        'name': data['name'],
        'category': data['category'],
        'pictures': picsJson,
        'restaurant_id': data['restaurant_id'],
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return count == 1;
  }

  Future<bool> deleteDish(int id) async {
    final db = LocalDb.instance.db;
    final c = await db.delete('dishes', where: 'id = ?', whereArgs: [id]);
    return c == 1;
  }

  Map<String, dynamic> _mapDishRow(Map<String, Object?> row) {
    final picsStr = (row['pictures'] as String?) ?? '[]';
    return {
      'id': row['id'],
      'name': row['name'],
      'category': row['category'],
      'pictures': List<String>.from(jsonDecode(picsStr)),
      'restaurant_id': row['restaurant_id'],
    };
  }
}
