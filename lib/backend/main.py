import o@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()  # Crée les tables si elles n'existent pas
    yield

# Create necessary directories
os.makedirs("data/avatars", exist_ok=True)
os.makedirs("data/restaurants", exist_ok=True)

app = FastAPI(lifespan=lifespan)m fastapi import FastAPI
from contextlib import asynccontextmanager

from fastapi.staticfiles import StaticFiles
from db import init_db
from routes import auth, profile, restaurant, dish

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()  # Crée les tables si elles n’existent pas
    yield
os.makedirs("data/avatars", exist_ok=True)
app = FastAPI(lifespan=lifespan)
app.mount("/static", StaticFiles(directory="data"), name="static")
# Inclure les routes
app.include_router(auth.router)
app.include_router(profile.router)
app.include_router(restaurant.router)
app.include_router(dish.router)
