import sqlite3

def get_db():
    conn = sqlite3.connect("data/FoodFinder.db")
    return conn

def init_db():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            name TEXT
        )
    """)
     # Create user_profiles table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_profiles (
            user_id INTEGER PRIMARY KEY,
            location TEXT DEFAULT '',
            cuisine_preferences TEXT DEFAULT '',
            budget REAL DEFAULT 25.0,
            dietary_restrictions INTEGER DEFAULT 0,
            notifications_enabled INTEGER DEFAULT 1,
            dark_mode_enabled INTEGER DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    """)
    conn.commit()
    conn.close()
