from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List


class UpdateSpotModel(BaseModel):
    date: Optional[str]
    name: Optional[str]
    coordinates: Optional[tuple]
    country: Optional[str]
    location: Optional[tuple]
    routes: Optional[tuple]
    rating: Optional[int]
    comments: Optional[List[str]]
    family_friendly: Optional[int]
    distance_parking: Optional[int]
    distance_public_transport: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein",
                "coordinates": [50.746036, 10.642666],
                "country": "Germany",
                "location": ["Thüringen", "Thüringer_Wald"],
                "routes": [],
                "rating": 0,
                "comments": [],
                "family_friendly": 4,
                "distance_parking": 120,
                "distance_public_transport": 120
            }
        }
