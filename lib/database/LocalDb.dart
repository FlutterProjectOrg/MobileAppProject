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
      version: 7,
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
            cuisine TEXT DEFAULT 'Autre',
            price_range TEXT DEFAULT '€€',
            FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
          CREATE TABLE dishes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL DEFAULT 0.0,
            preparation_time TEXT DEFAULT '',
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
        await db.execute("""
          CREATE TABLE reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            restaurant_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            rating REAL CHECK (rating >= 0 AND rating <= 5),
            comment TEXT DEFAULT '',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            UNIQUE(restaurant_id, user_id)
          )
        """);
        await db.execute("""
          CREATE TABLE restaurant_ratings (
            restaurant_id INTEGER PRIMARY KEY,
            average_rating REAL DEFAULT 0.0,
            total_reviews INTEGER DEFAULT 0,
            FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
          CREATE TABLE chat_conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT DEFAULT 'Nouvelle conversation',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        """);
        await db.execute("""
          CREATE TABLE chat_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER NOT NULL,
            sender TEXT NOT NULL CHECK (sender IN ('user', 'ai')),
            message TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE
          )
        """);
      },
      onUpgrade: (db, oldV, newV) async {
        // Migration for version 4: Add price and preparation_time to dishes
        if (oldV < 4) {
          final dishCols = await db.rawQuery("PRAGMA table_info(dishes)");
          final dishColNames = dishCols.map((e) => e['name']).toSet();
          
          if (!dishColNames.contains('price')) {
            await db.execute(
              "ALTER TABLE dishes ADD COLUMN price REAL NOT NULL DEFAULT 0.0",
            );
          }
          if (!dishColNames.contains('preparation_time')) {
            await db.execute(
              "ALTER TABLE dishes ADD COLUMN preparation_time TEXT DEFAULT ''",
            );
          }
        }
        
        // Migration for version 5: Add reviews and restaurant_ratings tables
        if (oldV < 5) {
          // Check if reviews table exists
          final tables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='reviews'",
          );
          
          if (tables.isEmpty) {
            await db.execute("""
              CREATE TABLE reviews (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                restaurant_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                rating REAL CHECK (rating >= 0 AND rating <= 5),
                comment TEXT DEFAULT '',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                UNIQUE(restaurant_id, user_id)
              )
            """);
          }
          
          // Check if restaurant_ratings table exists
          final ratingsTables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='restaurant_ratings'",
          );
          
          if (ratingsTables.isEmpty) {
            await db.execute("""
              CREATE TABLE restaurant_ratings (
                restaurant_id INTEGER PRIMARY KEY,
                average_rating REAL DEFAULT 0.0,
                total_reviews INTEGER DEFAULT 0,
                FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
              )
            """);
          }
        }
        
        // Migration for version 6: Add chat conversations and messages tables
        if (oldV < 6) {
          // Check if chat_conversations table exists
          final chatTables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='chat_conversations'",
          );
          
          if (chatTables.isEmpty) {
            await db.execute("""
              CREATE TABLE chat_conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                title TEXT DEFAULT 'Nouvelle conversation',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
              )
            """);
          }
          
          // Check if chat_messages table exists
          final messageTables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='chat_messages'",
          );
          
          if (messageTables.isEmpty) {
            await db.execute("""
              CREATE TABLE chat_messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                conversation_id INTEGER NOT NULL,
                sender TEXT NOT NULL CHECK (sender IN ('user', 'ai')),
                message TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE
              )
            """);
          }
        }
        
        // Migration for version 7: Add cuisine and price_range to restaurants
        if (oldV < 7) {
          final restaurantCols = await db.rawQuery("PRAGMA table_info(restaurants)");
          final restaurantColNames = restaurantCols.map((e) => e['name']).toSet();
          
          if (!restaurantColNames.contains('cuisine')) {
            await db.execute(
              "ALTER TABLE restaurants ADD COLUMN cuisine TEXT DEFAULT 'Autre'",
            );
          }
          if (!restaurantColNames.contains('price_range')) {
            await db.execute(
              "ALTER TABLE restaurants ADD COLUMN price_range TEXT DEFAULT '€€'",
            );
          }
        }
        
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
