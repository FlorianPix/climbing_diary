from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List

from app.models.py_object_id import PyObjectId


class RouteModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    name: str = Field(...)
    location: tuple = Field(...)
    grade: str = Field(...)
    rating: int = Field(..., ge=0, le=5)
    length: int = Field(...)  # m
    rappel_length: int = Field(...)  # m
    pitches: List[str] = []
    comments: List[str] = []

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein Riss",
                "location": ["Sektor Falkensteiner Riss"],
                "grade": "5a",
                "rating": 0,
                "length": 80,
                "rappel_length": 27,
                "pitches": [],
                "comments": [],
            }
        }
