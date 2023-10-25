from pydantic import BaseModel
from typing import Optional


class UpdateRouteModel(BaseModel):
    media_ids: Optional[tuple]
    comment: Optional[str]
    location: Optional[str]
    name: Optional[str]
    rating: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "media_ids": [],
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
            }
        }
