from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from app.models.py_object_id import PyObjectId


class SpotModel(BaseModel):
    spot_id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    name: str = Field(...)
    coordinates: List[float] = []
    location: List[str] = []
    routes: List[str] = []
    rating: int = Field(..., ge=0, le=5)
    comment: str = Field(...)
    distance_parking: int = Field(...)
    distance_public_transport: int = Field(...)
    media_ids: List[str] = []

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "spot_id": "6381f5cd63407a7f6e6fa820",
                "date": "2022-10-08",
                "name": "Falkenstein",
                "coordinates": [50.746036, 10.642666],
                "location": ["Deutschland", "Thüringen", "Thüringer Wald"],
                "routes": [],
                "rating": 5,
                "comment": "Great spot close to a lake with solid holds but kinda hard to reach.",
                "distance_parking": 120,
                "distance_public_transport": 120,
                "media_ids": []
            }
        }
