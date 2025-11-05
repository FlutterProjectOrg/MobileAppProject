from passlib.context import CryptContext

# Création du contexte de hachage (bcrypt)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash le mot de passe avant de le stocker en base"""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie si un mot de passe correspond au hash stocké"""
    return pwd_context.verify(plain_password, hashed_password)
