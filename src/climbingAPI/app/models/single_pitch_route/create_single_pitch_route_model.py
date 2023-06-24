from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List, Optional

from app.models.py_object_id import PyObjectId
from app.models.route.create_route_model import CreateRouteModel

from app.models.grade import Grade


class CreateSinglePitchRouteModel(CreateRouteModel):
    grade: Grade = Field(...)
    length: int = Field(..., ge=0)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
                "grade": "5",
                "length": 40,
            }
        }
