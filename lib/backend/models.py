from typing import List, Optional
from pydantic import BaseModel, Field
class User(BaseModel):
    email: str
    password: str
    name: Optional[str] = None

    
class UserProfile(BaseModel):
    id: int
    email: str
    name: str
    location: str = ""
    cuisine_preferences: List[str] = Field(default_factory=list)
    budget: float = 25.0
    dietary_restrictions: bool = False
    notifications_enabled: bool = True
    dark_mode_enabled: bool = False