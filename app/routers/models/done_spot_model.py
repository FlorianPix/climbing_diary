from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from .py_object_id import PyObjectId
from .route_model import RouteModel


class DoneSpotModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    spot_id: str = Field(...)
    spot_name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)
    comment: str = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein",
                "rating": 4,
                "comment": "Great spot close to a lake with solid holds but kindof hard to reach.",
            }
        }