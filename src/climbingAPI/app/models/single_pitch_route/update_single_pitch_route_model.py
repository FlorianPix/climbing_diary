from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List

from app.models.route.update_route_model import UpdateRouteModel

from app.models.grade import Grade


class UpdateSinglePitchRouteModel(UpdateRouteModel):
    ascent_ids: Optional[tuple]

    grade: Optional[Grade]
    length: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "media_ids": [],
                "ascent_ids": [],
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
                "grade": "5",
                "length": 40,
            }
        }
