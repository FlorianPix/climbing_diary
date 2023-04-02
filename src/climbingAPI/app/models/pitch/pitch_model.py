from bson import ObjectId
from datetime import date
from pydantic import BaseModel, Field
from typing import List

from app.models.py_object_id import PyObjectId


class PitchModel(BaseModel):
    ascent_ids: List[str] = []
    media_ids: List[str] = []
    pitch_id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
    grade: str = Field(...)
    length: int = Field(...)
    name: str = Field(...)
    num: int = Field(..., ge=1)
    rating: int = Field(..., ge=0, le=5)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "_id": "",
                "ascent_ids": [],
                "media_ids": [],
                "user_id": "",
                "comment": "Top Route",
                "grade": "6a",
                "length": 35,
                "name": "Pitch 1 vom Falkensteiner Riss",
                "num": 1,
                "rating": 5,
            }
        }