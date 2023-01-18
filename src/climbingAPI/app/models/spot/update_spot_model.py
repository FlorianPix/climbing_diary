from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List


class UpdateSpotModel(BaseModel):
    date: Optional[str]
    name: Optional[str]
    coordinates: Optional[tuple]
    location: Optional[tuple]
    routes: Optional[tuple]
    rating: Optional[int]
    comment: Optional[str]
    distance_parking: Optional[int]
    distance_public_transport: Optional[int]
    media_ids: Optional[tuple]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
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
