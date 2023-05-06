from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from app.models.py_object_id import PyObjectId


class RouteModel(BaseModel):
    media_ids: List[str] = []
    pitch_ids: List[PyObjectId] = []
    route_id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
    location: str = Field(...)
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "_id": "",
                "media_ids": [],
                "pitch_ids": [],
                "user_id": "",
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
            }
        }
