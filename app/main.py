from fastapi import FastAPI

from routers import spots

app = FastAPI()

app.include_router(spots.router)
