from pydantic import BaseModel
from typing import Optional, List


class UpdateSpotModel(BaseModel):
    media_ids: Optional[tuple]
    single_pitch_route_ids: Optional[tuple]
    multi_pitch_route_ids: Optional[tuple]

    comment: Optional[str]
    coordinates: Optional[tuple]
    distance_parking: Optional[int]
    distance_public_transport: Optional[int]
    location: Optional[str]
    name: Optional[str]
    rating: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "media_ids": [],
                "single_pitch_route_ids": [],
                "multi_pitch_route_ids": [],
                "comment": "Great spot close to a lake with solid holds but kinda hard to reach.",
                "coordinates": [50.746036, 10.642666],
                "distance_parking": 120,
                "distance_public": 120,
                "name": "Falkenstein",
                "location": "Deutschland, Thüringen, Thüringer Wald",
                "rating": 5,
            }
        }
