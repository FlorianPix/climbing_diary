from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List, Optional

from app.models.py_object_id import PyObjectId


class CreateRouteModel(BaseModel):
    comment: Optional[str]
    location: str = Field(...)
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)

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
            }
        }
