from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field

class UserRole(str, Enum):
    user = "user"
    admin = "admin"
    owner = "owner"
    delivery = "delivery"
    
class User(BaseModel):
    email: str
    password: str
    name: Optional[str] = None
    role: Optional[UserRole] = UserRole.user

    
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
    avatar_url: str = "" 

class OwnerProfile(BaseModel):
    id: int
    email: str
    name: str
    restaurant_name: str
    restaurant_address: str
    cuisine_types: List[str] = Field(default_factory=list)
    avatar_url: str = ""

class DeliveryProfile(BaseModel):
    id: int
    email: str
    name: str
    phone_number: str
    vehicle_type: str
    avatar_url: str = ""

class WorkTime(BaseModel):
    day: str  # "Monday", "Tuesday", etc.
    open_time: str  # "09:00"
    close_time: str  # "22:00"
    is_closed: bool = False

class Restaurant(BaseModel):
    name: str
    phone: str
    adresse: str
    pictures: List[str] = Field(default_factory=list)
    work_time: List[WorkTime] = Field(default_factory=list)
    owner_id: int  # Foreign key to User

class RestaurantResponse(BaseModel):
    id: int
    name: str
    phone: str
    adresse: str
    pictures: List[str]
    work_time: List[WorkTime]
    owner_id: int

class Dish(BaseModel):
    name: str
    category: str
    pictures: List[str] = Field(default_factory=list)
    restaurant_id: int  # Foreign key to Restaurant

class DishResponse(BaseModel):
    id: int
    name: str
    category: str
    pictures: List[str]
    restaurant_id: int
