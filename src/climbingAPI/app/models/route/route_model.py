from datetime import datetime
from pydantic import BaseModel, Field
from typing import List


class RouteModel(BaseModel):
    updated: datetime
    media_ids: List[str] = []
    route_id: str = Field(default_factory=str, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
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
                "user_id": "",
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
            }
        }
