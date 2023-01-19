from uuid import UUID
from pydantic import BaseModel

class ExternalStorageMediaUrl(BaseModel):
    id: UUID
    url: str

    class Config:
        orm_mode = True
