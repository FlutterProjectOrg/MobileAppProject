import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

enum UserRole { user, admin, owner, delivery }

class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();
  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'FoodFinder.db');

    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            name TEXT,
            role TEXT DEFAULT 'user'
          )
        """);
        await db.execute("""
          CREATE TABLE user_profiles (
            user_id INTEGER PRIMARY KEY,
            location TEXT DEFAULT '',
            cuisine_preferences TEXT DEFAULT '',
            budget REAL DEFAULT 25.0,
            dietary_restrictions INTEGER DEFAULT 0,
            notifications_enabled INTEGER DEFAULT 1,
            dark_mode_enabled INTEGER DEFAULT 0,
            avatar_url TEXT DEFAULT '',
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
          CREATE TABLE owner_profiles (
            user_id INTEGER PRIMARY KEY,
            restaurant_name TEXT DEFAULT '',
            restaurant_address TEXT DEFAULT '',
            cuisine_types TEXT DEFAULT '',
            avatar_url TEXT DEFAULT '',
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
          CREATE TABLE delivery_profiles (
            user_id INTEGER PRIMARY KEY,
            phone_number TEXT DEFAULT '',
            vehicle_type TEXT DEFAULT '',
            avatar_url TEXT DEFAULT '',
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
          CREATE TABLE restaurants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            adresse TEXT NOT NULL,
            pictures TEXT DEFAULT '[]',
            work_time TEXT DEFAULT '[]',
            owner_id INTEGER NOT NULL,
            FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
          CREATE TABLE dishes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            pictures TEXT DEFAULT '[]',
            restaurant_id INTEGER NOT NULL,
            FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
            CREATE TABLE password_reset_codes (
            email TEXT PRIMARY KEY,
            code TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        """);
      },
      onUpgrade: (db, oldV, newV) async {
        // Exemple migration légère (ajouts futurs)
        final cols = await db.rawQuery("PRAGMA table_info(user_profiles)");
        final names = cols.map((e) => e['name']).toSet();
        if (!names.contains('avatar_url')) {
          await db.execute(
            "ALTER TABLE user_profiles ADD COLUMN avatar_url TEXT DEFAULT ''",
          );
        }
      },
    );
  }

  Database get db {
    if (_db == null) {
      throw StateError('DB non initialisée. Appeler init() avant.');
    }
    return _db!;
  }
}
