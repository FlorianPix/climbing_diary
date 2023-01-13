from datetime import date
from uuid import UUID
from pydantic import BaseModel

class ExternalStorageMedia(BaseModel):
    id: UUID
    user_id: str
    title: str
    created_at: date

    class Config:
        orm_mode = True

