import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

enum UserRole { user, admin, owner, delivery }

class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();
  Database? _db;

  Future<Database> init() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'FoodFinder.db');

    _db = await openDatabase(
      path,
      version: 4, // Incremented version to force upgrade
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database migrations
        if (oldVersion < 2) {
          await _createAllTables(db);
        }
        if (oldVersion < 3) {
          // Add any new columns or tables for version 3
          await _migrateToV3(db);
        }
        if (oldVersion < 4) {
          // Ensure reservations table exists
          await _createReservationsTable(db);
        }
      },
    );
    return _db!;
  }

  // Helper method to create all tables
  Future<void> _createAllTables(Database db) async {
    await db.execute("""
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        role TEXT DEFAULT 'user',
        created_at TEXT,
        updated_at TEXT
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
        created_at TEXT,
        updated_at TEXT,
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
        created_at TEXT,
        updated_at TEXT,
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
    await db.execute("""
  CREATE TABLE reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,
    user_name TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    date TEXT NOT NULL,
    helpful INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
  )
""");


    await db.execute('CREATE INDEX idx_reviews_restaurant_id ON reviews(restaurant_id)');
    await db.execute('CREATE INDEX idx_reviews_user_id ON reviews(user_id)');
    await db.execute('CREATE INDEX idx_reviews_created_at ON reviews(created_at)');
    // Create reservations table
    await _createReservationsTable(db);
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

    // Créer des index pour de meilleures performances
    await db.execute('CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_likes_review_id ON likes(review_id)');
  }

  // Helper method to create reservations table
  Future<void> _createReservationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        restaurant_id INTEGER NOT NULL,
        reservation_date TEXT NOT NULL,
        reservation_time TEXT NOT NULL,
        number_of_guests INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'pending',
        special_requests TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (restaurant_id) REFERENCES restaurants (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reservations_user_id ON reservations(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reservations_restaurant_id ON reservations(restaurant_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations(reservation_date)');
  }

  // Migration to version 3
  Future<void> _migrateToV3(Database db) async {
    // Check if user_profiles has avatar_url column
    final cols = await db.rawQuery("PRAGMA table_info(user_profiles)");
    final names = cols.map((e) => e['name'] as String).toSet();

    if (!names.contains('avatar_url')) {
      await db.execute(
        "ALTER TABLE user_profiles ADD COLUMN avatar_url TEXT DEFAULT ''",
      );
    }

    // Ensure reservations table exists
    await _createReservationsTable(db);
  }

  Database get db {
    if (_db == null) {
      throw StateError('DB non initialisée. Appeler init() avant.');
    }
    return _db!;
  }

  // Close database
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  // Debug method to check all tables
  Future<void> debugDatabase() async {
    final db = await init();
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
    );

    debugPrint('=== DATABASE TABLES ===');
    for (final table in tables) {
      final tableName = table['name'] as String;
      debugPrint('Table: $tableName');

      final columns = await db.rawQuery("PRAGMA table_info($tableName)");
      for (final column in columns) {
        debugPrint('  ${column['name']} - ${column['type']}');
      }

      final count = await db.rawQuery("SELECT COUNT(*) as count FROM $tableName");
      debugPrint('  Count: ${count.first['count']}');
    }
  }
}