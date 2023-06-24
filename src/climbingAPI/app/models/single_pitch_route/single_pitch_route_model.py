from pydantic import Field
from bson import ObjectId
from typing import List

from app.models.py_object_id import PyObjectId
from app.models.route.route_model import RouteModel


class SinglePitchRouteModel(RouteModel):
    ascent_ids: List[str] = []

    grade: str = Field(...)
    length: int = Field(..., ge=0)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "_id": "",
                "media_ids": [],
                "ascent_ids": [],
                "user_id": "",
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
                "grade": "5",
                "length": 40,
            }
        }
