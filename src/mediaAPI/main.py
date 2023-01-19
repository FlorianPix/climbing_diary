import uvicorn

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.models import db_schema
from app.core.db import engine
from app.routers import media

db_schema.Base.metadata.create_all(bind=engine)


def get_application():
    _app = FastAPI(title=settings.PROJECT_NAME)

    _app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    _app.include_router(media.router, prefix="/media", tags=["media"])

    return _app


app = get_application()


if __name__ == "__main__":
    uvicorn.run(app, host=settings.SERVER_IP, port=settings.SERVER_PORT)
