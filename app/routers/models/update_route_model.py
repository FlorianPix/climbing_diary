from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional


class UpdateRouteModel(BaseModel):
    date: Optional[date]
    name: Optional[str]
    spot_id: Optional[str]
    spot_name: Optional[str]
    location: Optional[tuple]
    grade: Optional[str]
    rating: Optional[int]
    length: Optional[int]
    rappel_length: Optional[int]
    pitches: Optional[tuple]
    description: Optional[str]
    ascend: Optional[str]

    class Config:
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