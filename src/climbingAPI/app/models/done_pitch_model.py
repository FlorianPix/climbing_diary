from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId

from .py_object_id import PyObjectId


class PitchModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    name: str = Field(...)
    total_pitch_number: int = Field(...)
    pitch_number: int = Field(...)
    grade: str = Field(...)
    length: int = Field(...)  # m
    description: str = Field(...)
    ascend: str = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Pitch 1",
                "total_pitch_number": 3,
                "pitch_number": 1,
                "grade": "3",
                "length": 10,
                "description": "very easy and can be combined with pitch two at the cost of rope drag",
                "ascend": "onsight",
            }
        }