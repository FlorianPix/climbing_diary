from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import Optional

from app.models.py_object_id import PyObjectId


class CreateTripModel(BaseModel):
    comment: Optional[str]
    end_date: date
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)
    start_date: date

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "comment": "Great trip",
                "end_date": "2022-10-08",
                "name": "Ausflug zum Falkenstein",
                "start_date": "2022-10-06",
                "rating": 5,
            }
        }
