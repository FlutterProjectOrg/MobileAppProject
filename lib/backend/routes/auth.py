from fastapi import APIRouter, HTTPException, status
import sqlite3
from models import User
from db import get_db
import traceback

router = APIRouter(prefix="/auth", tags=["auth"])



# @router.post("/register", status_code=status.HTTP_201_CREATED)
# async def register(user: User):
#     conn = get_db()
#     cursor = conn.cursor()
#     try:
#         cursor.execute(
#             "INSERT INTO users (email, password, name) VALUES (?, ?, ?)",
#             (user.email, user.password, user.name)
#         )
#         conn.commit()
#         user_id = cursor.lastrowid
#         return {"message": "User registered successfully", "user_id": user_id}
#     except sqlite3.IntegrityError:
#         raise HTTPException(status_code=400, detail="Email already registered")
#     except Exception:
#         traceback.print_exc()
#         raise HTTPException(status_code=500, detail="Internal Server Error")
#     finally:
#         conn.close()
# @router.post("/login")
# async def login(user: User):
#     conn = get_db()
#     cursor = conn.cursor()
#     try:
#         cursor.execute(
#             "SELECT id FROM users WHERE email = ? AND password = ?",
#             (user.email, user.password)
#         )
#         result = cursor.fetchone()
#         if result:
#             return {"message": "Login successful", "user_id": result[0]}
#         raise HTTPException(status_code=401, detail="Invalid credentials")
#     except Exception:
#         traceback.print_exc()
#         raise HTTPException(status_code=500, detail="Internal Server Error")
#     finally:
#         conn.close()




@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user: User):
    """Enregistrer un nouvel utilisateur"""
    conn = None
    try:
        conn = get_db()
        cursor = conn.cursor()
        
        print(f"🔍 Attempting to register: {user.email} with role: {user.role}")
        
        # ✅ Vérifier si l'email existe déjà
        cursor.execute("SELECT id FROM users WHERE email = ?", (user.email,))
        if cursor.fetchone():
            raise HTTPException(
                status_code=400, 
                detail="Email already registered"
            )
        
        # ✅ Insérer l'utilisateur
        cursor.execute(
            "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)",
            (user.email, user.password or "", user.name, user.role.value)
        )
        conn.commit()
        
        # ✅ Récupérer l'ID inséré
        cursor.execute("SELECT id FROM users WHERE email = ?", (user.email,))
        result = cursor.fetchone()
        
        if not result:
            raise HTTPException(status_code=500, detail="Failed to retrieve user ID")
        
        user_id = result[0]
        print(f"✅ User registered successfully: {user_id}")
        
        # ✅ Créer le profil approprié selon le rôle
        if user.role.value == "delivery":
            cursor.execute(
                "INSERT INTO delivery_profiles (user_id) VALUES (?)",
                (user_id,)
            )
            print(f"✅ Delivery profile created for user {user_id}")
            
        elif user.role.value == "owner":
            cursor.execute(
                "INSERT INTO owner_profiles (user_id) VALUES (?)",
                (user_id,)
            )
            print(f"✅ Owner profile created for user {user_id}")
            
        else:  # user
            cursor.execute(
                "INSERT INTO user_profiles (user_id) VALUES (?)",
                (user_id,)
            )
            print(f"✅ User profile created for user {user_id}")
        
        conn.commit()
        
        return {
            "id": user_id,
            "email": user.email,
            "name": user.name,
            "role": user.role.value
        }
        
    except HTTPException:
        raise
    except sqlite3.IntegrityError as e:
        print(f"❌ Integrity error: {e}")
        raise HTTPException(status_code=400, detail="Email already registered")
    except sqlite3.OperationalError as e:
        print(f"❌ Database locked: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=503, detail="Database temporarily unavailable")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Internal Server Error")
    finally:
        if conn:
            conn.close()

@router.post("/login")
async def login(user: User):
    """Connecter un utilisateur"""
    conn = None
    try:
        conn = get_db()
        cursor = conn.cursor()
        
        print(f"🔍 Login attempt: {user.email}")
        
        cursor.execute(
            "SELECT id, name, role FROM users WHERE email = ? AND password = ?",
            (user.email, user.password)
        )
        result = cursor.fetchone()
        
        if result:
            print(f"✅ Login successful for user: {result[0]}")
            return {
                "id": result[0],
                "email": user.email,
                "name": result[1],
                "role": result[2]
            }
        
        print(f"❌ Invalid credentials for: {user.email}")
        raise HTTPException(status_code=401, detail="Invalid credentials")
        
    except HTTPException:
        raise
    except sqlite3.OperationalError as e:
        print(f"❌ Database locked: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=503, detail="Database temporarily unavailable")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Internal Server Error")
    finally:
        if conn:
            conn.close()

@router.get("/user/{user_id}")
async def get_user_by_id(user_id: int):
    """Récupérer un utilisateur par ID"""
    conn = None
    try:
        conn = get_db()
        cursor = conn.cursor()
        
        print(f"🔍 Fetching user: {user_id}")
        
        cursor.execute(
            "SELECT id, email, name, role FROM users WHERE id = ?",
            (user_id,)
        )
        result = cursor.fetchone()
        
        if result:
            print(f"✅ User found: {user_id}")
            return {
                "id": result[0],
                "email": result[1],
                "name": result[2],
                "role": result[3]
            }
        
        print(f"❌ User not found: {user_id}")
        raise HTTPException(status_code=404, detail="User not found")
        
    except HTTPException:
        raise
    except sqlite3.OperationalError as e:
        print(f"❌ Database locked: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=503, detail="Database temporarily unavailable")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Internal Server Error")
    finally:
        if conn:
            conn.close()