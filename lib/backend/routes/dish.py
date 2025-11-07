import json
from fastapi import APIRouter, HTTPException
from typing import List
from models import Dish, DishResponse
from db import get_db

router = APIRouter(prefix="/dishes", tags=["dishes"])


@router.post("/", response_model=DishResponse, status_code=201)
def create_dish(dish: Dish):
    """Create a new dish for a restaurant"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        # Verify that the restaurant exists
        cursor.execute("SELECT id FROM restaurants WHERE id = ?", (dish.restaurant_id,))
        restaurant = cursor.fetchone()
        
        if not restaurant:
            raise HTTPException(status_code=404, detail="Restaurant not found")
        
        # Convert pictures list to JSON string
        pictures_json = json.dumps(dish.pictures)
        
        cursor.execute("""
            INSERT INTO dishes (name, category, pictures, restaurant_id)
            VALUES (?, ?, ?, ?)
        """, (
            dish.name,
            dish.category,
            pictures_json,
            dish.restaurant_id
        ))
        
        conn.commit()
        dish_id = cursor.lastrowid
        
        # Return the created dish
        return DishResponse(
            id=dish_id,
            name=dish.name,
            category=dish.category,
            pictures=dish.pictures,
            restaurant_id=dish.restaurant_id
        )
    
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create dish: {str(e)}")
    finally:
        conn.close()


@router.get("/", response_model=List[DishResponse])
def get_all_dishes():
    """Get all dishes"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM dishes")
        rows = cursor.fetchall()
        
        dishes = []
        for row in rows:
            pictures = json.loads(row["pictures"]) if row["pictures"] else []
            
            dishes.append(DishResponse(
                id=row["id"],
                name=row["name"],
                category=row["category"],
                pictures=pictures,
                restaurant_id=row["restaurant_id"]
            ))
        
        return dishes
    
    finally:
        conn.close()


@router.get("/{dish_id}", response_model=DishResponse)
def get_dish(dish_id: int):
    """Get a specific dish by ID"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM dishes WHERE id = ?", (dish_id,))
        row = cursor.fetchone()
        
        if not row:
            raise HTTPException(status_code=404, detail="Dish not found")
        
        pictures = json.loads(row["pictures"]) if row["pictures"] else []
        
        return DishResponse(
            id=row["id"],
            name=row["name"],
            category=row["category"],
            pictures=pictures,
            restaurant_id=row["restaurant_id"]
        )
    
    finally:
        conn.close()


@router.get("/restaurant/{restaurant_id}", response_model=List[DishResponse])
def get_dishes_by_restaurant(restaurant_id: int):
    """Get all dishes for a specific restaurant"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        # Verify restaurant exists
        cursor.execute("SELECT id FROM restaurants WHERE id = ?", (restaurant_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Restaurant not found")
        
        cursor.execute("SELECT * FROM dishes WHERE restaurant_id = ?", (restaurant_id,))
        rows = cursor.fetchall()
        
        dishes = []
        for row in rows:
            pictures = json.loads(row["pictures"]) if row["pictures"] else []
            
            dishes.append(DishResponse(
                id=row["id"],
                name=row["name"],
                category=row["category"],
                pictures=pictures,
                restaurant_id=row["restaurant_id"]
            ))
        
        return dishes
    
    finally:
        conn.close()


@router.get("/category/{category}", response_model=List[DishResponse])
def get_dishes_by_category(category: str):
    """Get all dishes by category"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM dishes WHERE category = ?", (category,))
        rows = cursor.fetchall()
        
        dishes = []
        for row in rows:
            pictures = json.loads(row["pictures"]) if row["pictures"] else []
            
            dishes.append(DishResponse(
                id=row["id"],
                name=row["name"],
                category=row["category"],
                pictures=pictures,
                restaurant_id=row["restaurant_id"]
            ))
        
        return dishes
    
    finally:
        conn.close()


@router.put("/{dish_id}", response_model=DishResponse)
def update_dish(dish_id: int, dish: Dish):
    """Update a dish"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        # Check if dish exists
        cursor.execute("SELECT id FROM dishes WHERE id = ?", (dish_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Dish not found")
        
        # Verify restaurant exists
        cursor.execute("SELECT id FROM restaurants WHERE id = ?", (dish.restaurant_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Restaurant not found")
        
        # Convert pictures list to JSON string
        pictures_json = json.dumps(dish.pictures)
        
        cursor.execute("""
            UPDATE dishes 
            SET name = ?, category = ?, pictures = ?, restaurant_id = ?
            WHERE id = ?
        """, (
            dish.name,
            dish.category,
            pictures_json,
            dish.restaurant_id,
            dish_id
        ))
        
        conn.commit()
        
        return DishResponse(
            id=dish_id,
            name=dish.name,
            category=dish.category,
            pictures=dish.pictures,
            restaurant_id=dish.restaurant_id
        )
    
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to update dish: {str(e)}")
    finally:
        conn.close()


@router.delete("/{dish_id}", status_code=204)
def delete_dish(dish_id: int):
    """Delete a dish"""
    conn = get_db()
    cursor = conn.cursor()
    
    try:
        # Check if dish exists
        cursor.execute("SELECT id FROM dishes WHERE id = ?", (dish_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Dish not found")
        
        cursor.execute("DELETE FROM dishes WHERE id = ?", (dish_id,))
        conn.commit()
        
        return {"detail": "Dish deleted successfully"}
    
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to delete dish: {str(e)}")
    finally:
        conn.close()
