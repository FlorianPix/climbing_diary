import motor.motor_asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings

db_client: AsyncIOMotorClient = None


async def get_db_client() -> AsyncIOMotorClient:
    """Return database client instance."""
    return db_client


async def connect_db():
    """Create database connection."""
    global db_client
    db_client = AsyncIOMotorClient(settings.DATABASE_URI)


async def close_db():
    """Close database connection."""
    db_client.close()


async def get_db():
    client = await get_db_client()
    return client.calendar
