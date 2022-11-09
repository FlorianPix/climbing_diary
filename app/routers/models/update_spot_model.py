from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional


class UpdateSpotModel(BaseModel):
    date: Optional[date]
    name: Optional[str]
    coordinates: Optional[tuple]
    country: Optional[str]
    location: Optional[tuple]
    routes: Optional[tuple]
    rating: Optional[int]
    description: Optional[str]
    children_friendly: Optional[bool]
    close_parking: Optional[bool]
    camping_nearby: Optional[bool]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein",
                "coordinates": [-73.856077, 40.848447],
                "country": "Germany",
                "location": ["Thüringen", "Thüringer_Wald"],
                "routes": ["Falkensteiner_Riss-Germany-Thüringen-Thüringer_Wald"],
                "rating": 4,
                "description": "Great spot close to a lake with solid holds but kindof hard to reach.",
                "children_friendly": True,
                "close_parking": False,
                "camping_nearby": True,
            }
        }