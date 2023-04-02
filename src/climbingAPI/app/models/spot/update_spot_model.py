from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List


class UpdateSpotModel(BaseModel):
    media_ids: Optional[tuple]
    route_ids: Optional[tuple]

    comment: Optional[str]
    coordinates: Optional[tuple]
    distance_parking: Optional[int]
    distance_public_transport: Optional[int]
    location: Optional[str]
    name: Optional[str]
    rating: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "media_ids": [],
                "route_ids": [],
                "comment": "Great spot close to a lake with solid holds but kinda hard to reach.",
                "coordinates": [50.746036, 10.642666],
                "distance_parking": 120,
                "distance_public": 120
                "name": "Falkenstein",
                "location": "Deutschland, Thüringen, Thüringer Wald",
                "rating": 5,
            }
        }
