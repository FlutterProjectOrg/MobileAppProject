import os
from fastapi import FastAPI
from contextlib import asynccontextmanager

from fastapi.staticfiles import StaticFiles
from db import init_db
from routes import auth,profile

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
