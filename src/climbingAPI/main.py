import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.db import connect_db, close_db
from app.routers import pitches, spots, routes


def get_application():
    _app = FastAPI(title=settings.PROJECT_NAME)

    _app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    _app.include_router(spots.router, prefix="/spot", tags=["spot"])
    _app.include_router(routes.router, prefix="/route", tags=["route"])
    _app.include_router(pitches.router, prefix="/pitch", tags=["pitch"])

    _app.add_event_handler("startup", connect_db)
    _app.add_event_handler("shutdown", close_db)

    return _app


app = get_application()

if __name__ == "__main__":
    uvicorn.run(app, host=settings.SERVER_IP, port=settings.SERVER_PORT)
