from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from .py_object_id import PyObjectId


class SpotModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    name: str = Field(...)
    coordinates: List[float] = []
    country: str = Field(...)
    location: List[str] = []
    routes: List[str] = []
    rating: int = Field(..., ge=0, le=5)
    comments: List[str] = []
    family_friendly: int = Field(..., ge=0, le=5)
    distance_parking: int = Field(...)
    distance_public_transport: int = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein",
                "coordinates": [50.746036, 10.642666],
                "country": "Germany",
                "location": ["Thüringen", "Thüringer Wald"],
                "routes": [],
                "rating": 5,
                "comments": [],
                "family_friendly": 4,
                "distance_parking": 120,
                "distance_public_transport": 120
            }
        }
