from fastapi import FastAPI
from contextlib import asynccontextmanager
from db import init_db
from routes import auth,profile

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()  # Crée les tables si elles n’existent pas
    yield

app = FastAPI(lifespan=lifespan)

# Inclure les routes
app.include_router(auth.router)
app.include_router(profile.router)
