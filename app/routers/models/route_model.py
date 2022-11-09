from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId

from .py_object_id import PyObjectId


class RouteModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    name: str = Field(...)
    spot_id: str = Field(...)
    spot_name: str = Field(...)
    location: tuple = Field(...)
    grade: str = Field(...)
    rating: int = Field(..., ge=0, le=5)
    length: int = Field(...)  # m
    rappel_length: int = Field(...)  # m
    pitches: tuple = Field(...)
    description: str = Field(...)
    ascend: str = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein Riss",
                "spot_id": "636ac9838092b920ab9c710f",
                "spot_name": "Falkenstein",
                "location": ["Sektor Falkensteiner Riss"],
                "grade": "5a",
                "rating": 5,
                "length": 80,
                "rappel_length": 27,
                "pitches": ['1', '2', '3'],
                "description": "good holds, first clip pretty high, nice rest in corner before crux, book is 3m below to the left of the mid-wall anchor",
                "ascend": "flash",
            }
        }