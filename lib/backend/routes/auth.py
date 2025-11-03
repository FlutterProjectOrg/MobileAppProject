from fastapi import APIRouter, HTTPException, status
from models import User
from db import get_db
import sqlite3
import traceback


router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user: User):
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (email, password, name) VALUES (?, ?, ?)",
            (user.email, user.password, user.name)
        )
        conn.commit()
        user_id = cursor.lastrowid
        return {"message": "User registered successfully", "user_id": user_id}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Email already registered")
    except Exception:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Internal Server Error")
    finally:
        conn.close()

@router.post("/login")
async def login(user: User):
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "SELECT id FROM users WHERE email = ? AND password = ?",
            (user.email, user.password)
        )
        result = cursor.fetchone()
        if result:
            return {"message": "Login successful", "user_id": result[0]}
        raise HTTPException(status_code=401, detail="Invalid credentials")
    except Exception:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Internal Server Error")
    finally:
        conn.close()
