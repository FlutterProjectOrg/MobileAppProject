from fastapi import APIRouter, Depends, HTTPException, status
from functools import wraps

from fastapi.params import Header

from db import get_db

router = APIRouter()
async def get_current_user(x_user_id: int = Header(...)):  # ← FastAPI lira X-User-Id
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, email, name, role FROM users WHERE id = ?", (x_user_id,))
    row = cursor.fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="User not found")
    return {"id": row[0], "email": row[1], "name": row[2], "role": row[3]}

def require_role(allowed_roles: list):
    def decorator(func):
        async def wrapper(user: dict = Depends(get_current_user), *args, **kwargs):
            if user['role'] not in allowed_roles:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Forbidden: insufficient permissions"
                )
            return await func(user, *args, **kwargs)
        return wrapper
    return decorator

@router.get("/admin-only")
@require_role(["admin"])
async def admin_only(user):
    return {"message": f"Hello {user['name']}, you are admin!"}
