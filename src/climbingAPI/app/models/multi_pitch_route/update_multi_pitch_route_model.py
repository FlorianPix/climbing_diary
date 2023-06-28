from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List

from app.models.route.update_route_model import UpdateRouteModel


class UpdateMultiPitchRouteModel(UpdateRouteModel):
    pitch_ids: Optional[tuple]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "media_ids": [],
                "pitch_ids": [],
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
            }
        }
