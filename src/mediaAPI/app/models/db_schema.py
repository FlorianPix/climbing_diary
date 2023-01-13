from sqlalchemy import Column, DateTime, String
from sqlalchemy.dialects.postgresql import UUID
from app.core.db import Base
import uuid

class DbExternalStorageMedia(Base):
    __tablename__ = "external_storage_media"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(String)
    title = Column(String)
    created_at = Column(DateTime)
