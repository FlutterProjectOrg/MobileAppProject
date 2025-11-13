from fastapi import APIRouter, HTTPException, status
import sqlite3
from models import User
from db import get_db
import traceback
from utils.security import hash_password,verify_password
import random
import smtplib
from email.mime.text import MIMEText
router = APIRouter(prefix="/auth", tags=["auth"])


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
        

        hashed_pwd = hash_password(user.password)

        # ✅ Insérer l'utilisateur
        cursor.execute(
            "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)",
            (user.email, hashed_pwd or "", user.name, user.role.value)
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

        # ✅ 1. Récupérer l’utilisateur par email
        cursor.execute(
            "SELECT id, email, password, name, role FROM users WHERE email = ?",
            (user.email,)
        )
        db_user = cursor.fetchone()

        if not db_user:
            print("❌ User not found")
            raise HTTPException(status_code=401, detail="Invalid credentials")

        user_id, email, hashed_password, name, role = db_user

        # ✅ 2. Vérifier le mot de passe hashé
        if not verify_password(user.password, hashed_password):
            print("❌ Wrong password")
            raise HTTPException(status_code=401, detail="Invalid credentials")

        print(f"✅ Login successful for user: {user_id}")

        # ✅ 3. Retourner la réponse
        return {
            "id": user_id,
            "email": email,
            "name": name,
            "role": role
        }

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


@router.post("/forgot-password/request")
async def forgot_password_request(data: dict):
    """Étape 1 : envoi du code de vérification"""
    email = data.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email requis")

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()
    if not user:
        raise HTTPException(status_code=404, detail="Aucun compte associé à cet email")

    # Générer un code aléatoire à 6 chiffres
    code = f"{random.randint(1000, 9999)}"

    # Enregistrer le code dans une table temporaire
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS password_reset_codes (
            email TEXT PRIMARY KEY,
            code TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    cursor.execute("""
        INSERT OR REPLACE INTO password_reset_codes (email, code)
        VALUES (?, ?)
    """, (email, code))
    conn.commit()
    conn.close()

    # (Optionnel) envoi par email — ici, exemple via SMTP local
    try:
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        smtp_user = "firasbenkraiem1@gmail.com"
        smtp_password = "gdba sbff fbap hopf"
        msg = MIMEText(f"Votre code de vérification est : {code}")
        msg["Subject"] = "Réinitialisation de votre mot de passe"
        msg["From"] = "FoodFinder <firasbenkraiem8@gmail.com>"
        msg["To"] = email

        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()          # active TLS
            server.login(smtp_user, smtp_password)
            server.send_message(msg)
        print(f"Code généré pour {email} : {code}")
    except Exception as e:
        print(f"⚠️ Erreur d'envoi email: {e}")

    return {"message": "Code envoyé avec succès", "code": code}  # (Tu peux retirer `code` en prod)


@router.post("/forgot-password/verify")
async def verify_reset_code(data: dict):
    """Étape 2 : vérifier le code reçu par email"""
    email = data.get("email")
    code = data.get("code")

    if not email or not code:
        raise HTTPException(status_code=400, detail="Email et code requis")

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT code FROM password_reset_codes WHERE email = ?
    """, (email,))
    row = cursor.fetchone()
    conn.close()

    if not row or row["code"] != code:
        raise HTTPException(status_code=400, detail="Code invalide ou expiré")

    return {"message": "Code vérifié avec succès"}


@router.post("/forgot-password/reset")
async def reset_password(data: dict):
    """Étape 3 : définir un nouveau mot de passe"""
    email = data.get("email")
    new_password = data.get("new_password")

    if not email or not new_password:
        raise HTTPException(status_code=400, detail="Champs manquants")

    conn = get_db()
    cursor = conn.cursor()

    # Vérifier que l'utilisateur existe
    cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()
    if not user:
        conn.close()
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    hashed_pwd = hash_password(new_password)
    cursor.execute("UPDATE users SET password = ? WHERE email = ?", (hashed_pwd, email))
    cursor.execute("DELETE FROM password_reset_codes WHERE email = ?", (email,))
    conn.commit()
    conn.close()

    return {"message": "Mot de passe réinitialisé avec succès"}
