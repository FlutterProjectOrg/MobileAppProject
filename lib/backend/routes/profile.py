import base64
import os
import sqlite3
import time as pytime
import traceback
from fastapi import APIRouter, Body, HTTPException
from models import  DeliveryProfile, OwnerProfile, UserProfile
from db import get_db,_db_lock  


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

@router.put("/profile/owner/{user_id}", response_model=OwnerProfile)
async def update_owner_profile(user_id: int, profile: OwnerProfile):
    if profile.id != user_id:
        raise HTTPException(status_code=400, detail="Profile id mismatch")

    conn = get_db()
    try:
        cursor = conn.cursor()

        # Vérifie si l'utilisateur existe
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

        cuisine_str = ",".join(profile.cuisine_types) if profile.cuisine_types else ""

        # Vérifie si un profil existe déjà
        cursor.execute("SELECT 1 FROM owner_profiles WHERE user_id = ?", (user_id,))
        exists = cursor.fetchone() is not None

        if exists:
            cursor.execute("""
                UPDATE owner_profiles SET
                    restaurant_name = ?,
                    restaurant_address = ?,
                    cuisine_types = ?,
                    avatar_url = ?
                WHERE user_id = ?
            """, (
                profile.restaurant_name,
                profile.restaurant_address,
                cuisine_str,
                profile.avatar_url,
                user_id
            ))
        else:
            cursor.execute("""
                INSERT INTO owner_profiles (
                    user_id, restaurant_name, restaurant_address, cuisine_types, avatar_url
                ) VALUES (?, ?, ?, ?, ?)
            """, (
                user_id,
                profile.restaurant_name,
                profile.restaurant_address,
                cuisine_str,
                profile.avatar_url
            ))

        conn.commit()

        # Relecture du profil complet
        cursor.execute("""
            SELECT u.id, u.email, u.name,
                   op.restaurant_name, op.restaurant_address, op.cuisine_types, op.avatar_url
            FROM users u
            LEFT JOIN owner_profiles op ON u.id = op.user_id
            WHERE u.id = ?
        """, (user_id,))
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Owner profile not found after update")

        cuisine_raw = row[5] or ""
        cuisines = [c for c in cuisine_raw.split(",") if c] if cuisine_raw else []

        return OwnerProfile(
            id=row[0],
            email=row[1] or "",
            name=row[2] or "",
            restaurant_name=row[3] or "",
            restaurant_address=row[4] or "",
            cuisine_types=cuisines,
            avatar_url=row[6] or ""
        )
    finally:
        conn.close()

@router.put("/profile/delivery/{user_id}", response_model=DeliveryProfile)
async def update_delivery_profile(user_id: int, profile: DeliveryProfile):
    if profile.id != user_id:
        raise HTTPException(status_code=400, detail="Profile id mismatch")

    conn = get_db()
    try:
        cursor = conn.cursor()

        # Vérifie si l'utilisateur existe
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

        # Vérifie si un profil livreur existe déjà
        cursor.execute("SELECT 1 FROM delivery_profiles WHERE user_id = ?", (user_id,))
        exists = cursor.fetchone() is not None

        if exists:
            cursor.execute("""
                UPDATE delivery_profiles SET
                    phone_number = ?,
                    vehicle_type = ?,
                    avatar_url = ?
                WHERE user_id = ?
            """, (
                profile.phone_number,
                profile.vehicle_type,
                profile.avatar_url,
                user_id
            ))
        else:
            cursor.execute("""
                INSERT INTO delivery_profiles (
                    user_id, phone_number, vehicle_type, avatar_url
                ) VALUES (?, ?, ?, ?)
            """, (
                user_id,
                profile.phone_number,
                profile.vehicle_type,
                profile.avatar_url
            ))

        conn.commit()

        # Relecture du profil complet
        cursor.execute("""
            SELECT u.id, u.email, u.name,
                   dp.phone_number, dp.vehicle_type, dp.avatar_url
            FROM users u
            LEFT JOIN delivery_profiles dp ON u.id = dp.user_id
            WHERE u.id = ?
        """, (user_id,))
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Delivery profile not found after update")

        return DeliveryProfile(
            id=row[0],
            email=row[1] or "",
            name=row[2] or "",
            phone_number=row[3] or "",
            vehicle_type=row[4] or "",
            avatar_url=row[5] or ""
        )
    finally:
        conn.close()

# ----------------- OWNER -----------------
@router.get("/profile/owner/{user_id}", response_model=OwnerProfile)
async def get_owner_profile(user_id: int):
    conn = get_db()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT u.id, u.email, u.name,
                   op.restaurant_name, op.restaurant_address, op.cuisine_types, op.avatar_url
            FROM users u
            LEFT JOIN owner_profiles op ON u.id = op.user_id
            WHERE u.id = ? AND u.role='owner'
        """, (user_id,))
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="User not found")

        cuisine_list = row[5].split(",") if row[5] else []

        return OwnerProfile(
            id=row[0],
            email=row[1] or "",
            name=row[2] or "",
            restaurant_name=row[3] or "",
            restaurant_address=row[4] or "",
            cuisine_types=cuisine_list,
            avatar_url=row[6] or ""
        )
    finally:
        conn.close()
# ----------------- DELIVERY -----------------
@router.get("/profile/delivery/{user_id}", response_model=DeliveryProfile)
async def get_delivery_profile(user_id: int):
    conn = get_db()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT u.id, u.email, u.name,
                   dp.phone_number, dp.vehicle_type, dp.avatar_url
            FROM users u
            LEFT JOIN delivery_profiles dp ON u.id = dp.user_id
            WHERE u.id = ? AND u.role='delivery'
        """, (user_id,))
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="User not found")

        return DeliveryProfile(
            id=row[0],
            email=row[1] or "",
            name=row[2] or "",
            phone_number=row[3] or "",
            vehicle_type=row[4] or "",
            avatar_url=row[5] or ""
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

        # 🔒 On bloque l'accès à la base pendant l'écriture
        with _db_lock:
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


@router.post("/profile/owner/{user_id}/avatar")
async def upload_owner_avatar(user_id: int, payload: dict = Body(...)):
    image_b64 = payload.get("image_base64")
    if not image_b64:
        raise HTTPException(status_code=400, detail="image_base64 required")

    try:
        avatar_dir = "data/avatars"
        os.makedirs(avatar_dir, exist_ok=True)

        b64data = image_b64.split(",")[-1]
        image_data = base64.b64decode(b64data)

        filename = f"owner_{user_id}.png"
        path = os.path.join(avatar_dir, filename)
        with open(path, "wb") as f:
            f.write(image_data)

        avatar_url = f"/static/avatars/{filename}"

        # 🔒 utilisation du verrou ici aussi
        with _db_lock:
            conn = get_db()
            cursor = conn.cursor()
            cursor.execute("SELECT 1 FROM owner_profiles WHERE user_id = ?", (user_id,))
            if cursor.fetchone():
                cursor.execute("UPDATE owner_profiles SET avatar_url = ? WHERE user_id = ?", (avatar_url, user_id))
            else:
                cursor.execute("INSERT INTO owner_profiles (user_id, avatar_url) VALUES (?, ?)", (user_id, avatar_url))
            conn.commit()
            conn.close()

        return {"avatar_url": avatar_url}

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/profile/delivery/{user_id}/avatar")
async def upload_delivery_avatar(user_id: int, payload: dict = Body(...)):
    image_b64 = payload.get("image_base64")
    if not image_b64:
        raise HTTPException(status_code=400, detail="image_base64 required")

    try:
        avatar_dir = "data/avatars"
        os.makedirs(avatar_dir, exist_ok=True)

        b64data = image_b64.split(",")[-1]
        image_data = base64.b64decode(b64data)

        filename = f"delivery_{user_id}.png"
        path = os.path.join(avatar_dir, filename)
        with open(path, "wb") as f:
            f.write(image_data)

        avatar_url = f"/static/avatars/{filename}"

        # 🔒 verrou pour éviter le blocage SQLite
        with _db_lock:
            conn = get_db()
            cursor = conn.cursor()
            cursor.execute("SELECT 1 FROM delivery_profiles WHERE user_id = ?", (user_id,))
            if cursor.fetchone():
                cursor.execute("UPDATE delivery_profiles SET avatar_url = ? WHERE user_id = ?", (avatar_url, user_id))
            else:
                cursor.execute("INSERT INTO delivery_profiles (user_id, avatar_url) VALUES (?, ?)", (user_id, avatar_url))
            conn.commit()
            conn.close()

        return {"avatar_url": avatar_url}

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))