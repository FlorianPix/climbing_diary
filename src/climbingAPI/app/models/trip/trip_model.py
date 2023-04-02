from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from app.models.py_object_id import PyObjectId


class TripModel(BaseModel):
    media_ids: List[str] = []
    spot_ids: List[str] = []
    trip_id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
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
                "media_ids": [],
                "spot_ids": [],
                "_id": "",
                "user_id": "",
                "comment": "Great trip",
                "end_date": "2022-10-08",
                "name": "Ausflug zum Falkenstein",
                "start_date": "2022-10-06",
                "rating": 5,
            }
        }
