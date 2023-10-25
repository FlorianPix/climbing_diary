from datetime import datetime
from pydantic import BaseModel, Field
from typing import List


class SpotModel(BaseModel):
    updated: datetime
    media_ids: List[str] = []
    single_pitch_route_ids: List[str] = []
    multi_pitch_route_ids: List[str] = []
    spot_id: str = Field(default_factory=str, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
    coordinates: List[float] = []
    distance_parking: int = Field(...)
    distance_public_transport: int = Field(...)
    location: str = Field(...)
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "updated": "2022-10-06T20:13:16.816000",
                "_id": "",
                "media_ids": [],
                "single_pitch_route_ids": [],
                "multi_pitch_route_ids": [],
                "user_id": "",
                "comment": "Great spot close to a lake with solid holds but kinda hard to reach.",
                "coordinates": [50.746036, 10.642666],
                "distance_parking": 120,
                "distance_public": 120,
                "location": "Deutschland, Thüringen, Thüringer Wald",
                "name": "Falkenstein",
                "rating": 5,
            }
        }
