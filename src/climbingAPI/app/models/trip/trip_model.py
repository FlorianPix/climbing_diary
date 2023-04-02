from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from app.models.py_object_id import PyObjectId


class SpotModel(BaseModel):
    comment: str = Field(...)
    coordinates: List[float] = []
    date: date
    distance_parking: int = Field(...)
    distance_public_transport: int = Field(...)
    location: List[str] = []
    media_ids: List[str] = []
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)
    routes: List[str] = []
    spot_id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "comment": "Great spot close to a lake with solid holds but kinda hard to reach.",
                "coordinates": [50.746036, 10.642666],
                "date": "2022-10-08",
                "distance_parking": 120,
                "distance_public_transport": 120,
                "location": ["Deutschland", "Thüringen", "Thüringer Wald"],
                "media_ids": [],
                "name": "Falkenstein",
                "rating": 5,
                "routes": [],
                "spot_id": "6381f5cd63407a7f6e6fa820",
                "user_id": "6381f5cd63407a7f6e6fa821",
            }
        }
