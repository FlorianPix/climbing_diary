from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from app.models.py_object_id import PyObjectId


class AscentModel(BaseModel):
    media_ids: List[str] = []
    ascent_id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
    date: date
    style: int = Field(..., ge=0, le=5)
    type: int = Field(..., ge=0, le=4)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "_id": "",
                "media_ids": [],
                "user_id": "",
                "comment": "Great ascent",
                "date": "2022-10-06",
                "style": 0
                "type": 3
            }
        }
