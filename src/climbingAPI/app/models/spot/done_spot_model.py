from datetime import date
from typing import List

from pydantic import BaseModel, Field
from bson import ObjectId

from app.models.py_object_id import PyObjectId


class DoneSpotModel(BaseModel):
    _id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    spot_id: str = Field(...)
    spot_name: str = Field(...)
    done_routes: List[str] = []
    rating: int = Field(..., ge=0, le=5)
    comment: str = Field(...)
    media_ids: List[str] = []

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein",
                "done_routes": [],
                "rating": 5,
                "comment": "We had very good conditions that day.",
                "media_ids": []
            }
        }