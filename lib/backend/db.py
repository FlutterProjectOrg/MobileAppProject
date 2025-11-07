import os
import sqlite3
import threading
_db_lock = threading.Lock()
DB_PATH = "data/FoodFinder.db"
def get_db():
    conn = sqlite3.connect(DB_PATH, timeout=30.0, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA busy_timeout = 30000;")
    return conn

def init_db():
    """Initialise la base de données et crée les tables si nécessaire."""
    os.makedirs("data/avatars", exist_ok=True)

    # On verrouille pour éviter les accès concurrents au démarrage
    with _db_lock:
        conn = sqlite3.connect(DB_PATH, timeout=30.0, check_same_thread=False)
        conn.row_factory = sqlite3.Row

        # Active le mode WAL une seule fois (plus besoin dans get_db)
        conn.execute("PRAGMA journal_mode=WAL;")

        cursor = conn.cursor()

        # Table des utilisateurs
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY,
                email TEXT UNIQUE NOT NULL,
                password TEXT,
                name TEXT,
                role TEXT DEFAULT 'user'  -- 'user', 'admin', 'owner', 'delivery'
            )
        """)

        # Table user_profiles
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS user_profiles (
                user_id INTEGER PRIMARY KEY,
                location TEXT DEFAULT '',
                cuisine_preferences TEXT DEFAULT '',
                budget REAL DEFAULT 25.0,
                dietary_restrictions INTEGER DEFAULT 0,
                notifications_enabled INTEGER DEFAULT 1,
                dark_mode_enabled INTEGER DEFAULT 0,
                avatar_url TEXT DEFAULT '',
                FOREIGN KEY (user_id) REFERENCES users (id)
            )
        """)

        # Table owner_profiles
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS owner_profiles (
                user_id INTEGER PRIMARY KEY,
                restaurant_name TEXT DEFAULT '',
                restaurant_address TEXT DEFAULT '',
                cuisine_types TEXT DEFAULT '',
                avatar_url TEXT DEFAULT '',
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        """)

        # Table delivery_profiles
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS delivery_profiles (
                user_id INTEGER PRIMARY KEY,
                phone_number TEXT DEFAULT '',
                vehicle_type TEXT DEFAULT '',
                avatar_url TEXT DEFAULT '',
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        """)

        # Table restaurants
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS restaurants (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                phone TEXT NOT NULL,
                adresse TEXT NOT NULL,
                pictures TEXT DEFAULT '',
                work_time TEXT DEFAULT '',
                owner_id INTEGER NOT NULL,
                FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
            )
        """)

        # Table dishes
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS dishes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category TEXT NOT NULL,
                pictures TEXT DEFAULT '',
                restaurant_id INTEGER NOT NULL,
                FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
            )
        """)

        conn.commit()
        conn.close()
