import 'dart:convert';
import 'package:mobile_app_project/database/LocalDb.dart';

class RestaurantService {
  RestaurantService._();
  static final RestaurantService instance = RestaurantService._();

  Future<int> createRestaurant(Map<String, dynamic> data) async {
    final db = LocalDb.instance.db;
    final ownerId = data['owner_id'] as int;
    final name = data['name'] as String;
    final phone = data['phone'] as String;
    final adresse = data['adresse'] as String;
    final pictures = (data['pictures'] as List?)?.cast<String>() ?? [];
    final workTime = (data['work_time'] as List?) ?? [];

    final picsJson = jsonEncode(pictures);
    final wtJson = jsonEncode(workTime);

    final id = await db.insert('restaurants', {
      'name': name,
      'phone': phone,
      'adresse': adresse,
      'pictures': picsJson,
      'work_time': wtJson,
      'owner_id': ownerId,
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllRestaurants() async {
    final db = LocalDb.instance.db;
    final rows = await db.query('restaurants');
    return rows.map(_mapRestaurantRow).toList();
  }

  Future<Map<String, dynamic>?> getRestaurant(int id) async {
    final db = LocalDb.instance.db;
    final rows = await db.query(
      'restaurants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapRestaurantRow(rows.first);
  }

  Future<List<Map<String, dynamic>>> getRestaurantsByOwner(int ownerId) async {
    final db = LocalDb.instance.db;
    final rows = await db.query(
      'restaurants',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    return rows.map(_mapRestaurantRow).toList();
  }

  Future<bool> updateRestaurant(int id, Map<String, dynamic> data) async {
    final db = LocalDb.instance.db;
    final picsJson = jsonEncode(
      (data['pictures'] as List?)?.cast<String>() ?? [],
    );
    final wtJson = jsonEncode((data['work_time'] as List?) ?? []);
    final count = await db.update(
      'restaurants',
      {
        'name': data['name'],
        'phone': data['phone'],
        'adresse': data['adresse'],
        'pictures': picsJson,
        'work_time': wtJson,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return count == 1;
  }

  Future<bool> deleteRestaurant(int id) async {
    final db = LocalDb.instance.db;
    final c = await db.delete('restaurants', where: 'id = ?', whereArgs: [id]);
    return c == 1;
  }

  Map<String, dynamic> _mapRestaurantRow(Map<String, Object?> row) {
    final picsStr = (row['pictures'] as String?) ?? '[]';
    final wtStr = (row['work_time'] as String?) ?? '[]';
    return {
      'id': row['id'],
      'name': row['name'],
      'phone': row['phone'],
      'adresse': row['adresse'],
      'pictures': List<String>.from(jsonDecode(picsStr)),
      'work_time': List<Map<String, dynamic>>.from(jsonDecode(wtStr)),
      'owner_id': row['owner_id'],
    };
  }
}
