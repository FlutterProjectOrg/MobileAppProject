import base64
import os
import sqlite3
import traceback
from fastapi import APIRouter, Body, HTTPException
from models import  UserProfile
from db import get_db


router = APIRouter(prefix="/auth", tags=["auth"])
@router.get("/profile/{user_id}", response_model=UserProfile)
async def get_profile(user_id: int):
    conn = get_db()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT u.id, u.email, u.name,
                   up.location, up.cuisine_preferences, up.budget,
                   up.dietary_restrictions, up.notifications_enabled, up.dark_mode_enabled,
                   up.avatar_url
            FROM users u
            LEFT JOIN user_profiles up ON u.id = up.user_id
            WHERE u.id = ?
        """, (user_id,))
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="User not found")

        cuisine_raw = row[4] or ""
        cuisines = [c for c in cuisine_raw.split(",") if c] if cuisine_raw else []

        return UserProfile(
            id=row[0],
            email=row[1] or "",
            name=row[2] or "",
            location=row[3] or "",
            cuisine_preferences=cuisines,
            budget=float(row[5]) if row[5] is not None else 25.0,
            dietary_restrictions=bool(row[6]) if row[6] is not None else False,
            notifications_enabled=bool(row[7]) if row[7] is not None else True,
            dark_mode_enabled=bool(row[8]) if row[8] is not None else False,
            avatar_url=(row[9] or "")
        )
    finally:
        conn.close()

@router.put("/profile/{user_id}", response_model=UserProfile)
async def update_profile(user_id: int, profile: UserProfile):
    if profile.id != user_id:
        raise HTTPException(status_code=400, detail="Profile id mismatch")

    conn = get_db()
    try:
        cursor = conn.cursor()

        # Ensure user exists
        cursor.execute("SELECT email, name FROM users WHERE id = ?", (user_id,))
        user_row = cursor.fetchone()
        if not user_row:
            raise HTTPException(status_code=404, detail="User not found")

        current_email, current_name = user_row[0], user_row[1]
        if (profile.email != current_email) or (profile.name != current_name):
            try:
                cursor.execute(
                    "UPDATE users SET email = ?, name = ? WHERE id = ?",
                    (profile.email, profile.name, user_id)
                )
            except sqlite3.IntegrityError:
                raise HTTPException(status_code=400, detail="Email already registered")

        cuisine_str = ",".join(profile.cuisine_preferences) if profile.cuisine_preferences else ""

        cursor.execute("SELECT 1 FROM user_profiles WHERE user_id = ?", (user_id,))
        exists = cursor.fetchone() is not None

        if exists:
            cursor.execute("""
                UPDATE user_profiles SET
                    location = ?,
                    cuisine_preferences = ?,
                    budget = ?,
                    dietary_restrictions = ?,
                    notifications_enabled = ?,
                    dark_mode_enabled = ?
                WHERE user_id = ?
            """, (
                profile.location,
                cuisine_str,
                profile.budget,
                int(profile.dietary_restrictions),
                int(profile.notifications_enabled),
                int(profile.dark_mode_enabled),
                user_id
            ))
        else:
            cursor.execute("""
                INSERT INTO user_profiles (
                    user_id, location, cuisine_preferences, budget,
                    dietary_restrictions, notifications_enabled, dark_mode_enabled
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                user_id,
                profile.location,
                cuisine_str,
                profile.budget,
                int(profile.dietary_restrictions),
                int(profile.notifications_enabled),
                int(profile.dark_mode_enabled),
            ))

        conn.commit()

        # re-read joined data
        cursor.execute("""
            SELECT u.id, u.email, u.name,
                   up.location, up.cuisine_preferences, up.budget,
                   up.dietary_restrictions, up.notifications_enabled, up.dark_mode_enabled,
                   up.avatar_url
            FROM users u
            LEFT JOIN user_profiles up ON u.id = up.user_id
            WHERE u.id = ?
        """, (user_id,))
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="User not found after update")

        cuisine_raw = row[4] or ""
        cuisines = [c for c in cuisine_raw.split(",") if c] if cuisine_raw else []

        return UserProfile(
            id=row[0],
            email=row[1] or "",
            name=row[2] or "",
            location=row[3] or "",
            cuisine_preferences=cuisines,
            budget=float(row[5]) if row[5] is not None else 25.0,
            dietary_restrictions=bool(row[6]) if row[6] is not None else False,
            notifications_enabled=bool(row[7]) if row[7] is not None else True,
            dark_mode_enabled=bool(row[8]) if row[8] is not None else False,
            avatar_url=(row[9] or "")
        )
    finally:
        conn.close()

@router.post("/profile/{user_id}/avatar")
async def upload_avatar(user_id: int, payload: dict = Body(...)):
    image_b64 = payload.get("image_base64")
    if not image_b64:
        raise HTTPException(status_code=400, detail="image_base64 required")

    try:
        avatar_dir = "data/avatars"
        os.makedirs(avatar_dir, exist_ok=True)

        # support data URI and raw base64
        try:
            b64data = image_b64.split(",")[-1]
            image_data = base64.b64decode(b64data)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid base64 image data")

        filename = f"{user_id}.png"
        path = os.path.join(avatar_dir, filename)
        with open(path, "wb") as f:
            f.write(image_data)

        avatar_url = f"/static/avatars/{filename}"

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT 1 FROM user_profiles WHERE user_id = ?", (user_id,))
        if cursor.fetchone():
            cursor.execute("UPDATE user_profiles SET avatar_url = ? WHERE user_id = ?", (avatar_url, user_id))
        else:
            cursor.execute("INSERT INTO user_profiles (user_id, avatar_url) VALUES (?, ?)", (user_id, avatar_url))
        conn.commit()
        conn.close()

        return {"avatar_url": str(avatar_url)}
    except HTTPException:
        raise
    except Exception:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Failed to save avatar")