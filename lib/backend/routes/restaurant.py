import json
from fastapi import APIRouter, HTTPException
from typing import List
from models import Restaurant, RestaurantResponse, WorkTime
from db import get_db

router = APIRouter(prefix="/restaurants", tags=["restaurants"])


@router.post("/", response_model=RestaurantResponse, status_code=201)
def create_restaurant(restaurant: Restaurant):
    """Create a new restaurant (owner only)"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        # Verify that the owner exists and has 'owner' role
        cursor.execute("SELECT role FROM users WHERE id = ?", (restaurant.owner_id,))
        user = cursor.fetchone()
        
        if not user:
            raise HTTPException(status_code=404, detail="Owner user not found")
        
        if user["role"] != "owner":
            raise HTTPException(status_code=403, detail="User must have 'owner' role to create a restaurant")
        
        # Convert lists to JSON strings for storage
        pictures_json = json.dumps(restaurant.pictures)
        work_time_json = json.dumps([wt.dict() for wt in restaurant.work_time])
        
        cursor.execute("""
            INSERT INTO restaurants (name, phone, adresse, pictures, work_time, owner_id)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            restaurant.name,
            restaurant.phone,
            restaurant.adresse,
            pictures_json,
            work_time_json,
            restaurant.owner_id
        ))
        
        conn.commit()
        restaurant_id = cursor.lastrowid
        
        # Return the created restaurant
        return RestaurantResponse(
            id=restaurant_id,
            name=restaurant.name,
            phone=restaurant.phone,
            adresse=restaurant.adresse,
            pictures=restaurant.pictures,
            work_time=restaurant.work_time,
            owner_id=restaurant.owner_id
        )
    
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create restaurant: {str(e)}")
    finally:
        conn.close()


@router.get("/", response_model=List[RestaurantResponse])
def get_all_restaurants():
    """Get all restaurants"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM restaurants")
        rows = cursor.fetchall()
        
        restaurants = []
        for row in rows:
            pictures = json.loads(row["pictures"]) if row["pictures"] else []
            work_time_data = json.loads(row["work_time"]) if row["work_time"] else []
            work_time = [WorkTime(**wt) for wt in work_time_data]
            
            restaurants.append(RestaurantResponse(
                id=row["id"],
                name=row["name"],
                phone=row["phone"],
                adresse=row["adresse"],
                pictures=pictures,
                work_time=work_time,
                owner_id=row["owner_id"]
            ))
        
        return restaurants
    
    finally:
        conn.close()


@router.get("/{restaurant_id}", response_model=RestaurantResponse)
def get_restaurant(restaurant_id: int):
    """Get a specific restaurant by ID"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM restaurants WHERE id = ?", (restaurant_id,))
        row = cursor.fetchone()
        
        if not row:
            raise HTTPException(status_code=404, detail="Restaurant not found")
        
        pictures = json.loads(row["pictures"]) if row["pictures"] else []
        work_time_data = json.loads(row["work_time"]) if row["work_time"] else []
        work_time = [WorkTime(**wt) for wt in work_time_data]
        
        return RestaurantResponse(
            id=row["id"],
            name=row["name"],
            phone=row["phone"],
            adresse=row["adresse"],
            pictures=pictures,
            work_time=work_time,
            owner_id=row["owner_id"]
        )
    
    finally:
        conn.close()


@router.get("/owner/{owner_id}", response_model=List[RestaurantResponse])
def get_restaurants_by_owner(owner_id: int):
    """Get all restaurants owned by a specific owner"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM restaurants WHERE owner_id = ?", (owner_id,))
        rows = cursor.fetchall()
        
        restaurants = []
        for row in rows:
            pictures = json.loads(row["pictures"]) if row["pictures"] else []
            work_time_data = json.loads(row["work_time"]) if row["work_time"] else []
            work_time = [WorkTime(**wt) for wt in work_time_data]
            
            restaurants.append(RestaurantResponse(
                id=row["id"],
                name=row["name"],
                phone=row["phone"],
                adresse=row["adresse"],
                pictures=pictures,
                work_time=work_time,
                owner_id=row["owner_id"]
            ))
        
        return restaurants
    
    finally:
        conn.close()


@router.put("/{restaurant_id}", response_model=RestaurantResponse)
def update_restaurant(restaurant_id: int, restaurant: Restaurant):
    """Update a restaurant (owner only, must own the restaurant)"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        # Check if restaurant exists
        cursor.execute("SELECT owner_id FROM restaurants WHERE id = ?", (restaurant_id,))
        row = cursor.fetchone()
        
        if not row:
            raise HTTPException(status_code=404, detail="Restaurant not found")
        
        # Verify ownership
        if row["owner_id"] != restaurant.owner_id:
            raise HTTPException(status_code=403, detail="You can only update your own restaurants")
        
        # Convert lists to JSON strings
        pictures_json = json.dumps(restaurant.pictures)
        work_time_json = json.dumps([wt.dict() for wt in restaurant.work_time])
        
        cursor.execute("""
            UPDATE restaurants 
            SET name = ?, phone = ?, adresse = ?, pictures = ?, work_time = ?
            WHERE id = ?
        """, (
            restaurant.name,
            restaurant.phone,
            restaurant.adresse,
            pictures_json,
            work_time_json,
            restaurant_id
        ))
        
        conn.commit()
        
        return RestaurantResponse(
            id=restaurant_id,
            name=restaurant.name,
            phone=restaurant.phone,
            adresse=restaurant.adresse,
            pictures=restaurant.pictures,
            work_time=restaurant.work_time,
            owner_id=restaurant.owner_id
        )
    
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to update restaurant: {str(e)}")
    finally:
        conn.close()


@router.delete("/{restaurant_id}", status_code=204)
def delete_restaurant(restaurant_id: int, owner_id: int):
    """Delete a restaurant (owner only, must own the restaurant)"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        # Check if restaurant exists and verify ownership
        cursor.execute("SELECT owner_id FROM restaurants WHERE id = ?", (restaurant_id,))
        row = cursor.fetchone()
        
        if not row:
            raise HTTPException(status_code=404, detail="Restaurant not found")
        
        if row["owner_id"] != owner_id:
            raise HTTPException(status_code=403, detail="You can only delete your own restaurants")
        
        cursor.execute("DELETE FROM restaurants WHERE id = ?", (restaurant_id,))
        conn.commit()
        
        return {"detail": "Restaurant deleted successfully"}
    
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to delete restaurant: {str(e)}")
    finally:
        conn.close()
