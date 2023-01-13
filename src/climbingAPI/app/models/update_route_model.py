from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List


class UpdateRouteModel(BaseModel):
    date: Optional[str]
    name: Optional[str]
    location: Optional[tuple]
    grade: Optional[str]
    rating: Optional[int]
    length: Optional[int]
    rappel_length: Optional[int]
    pitches: Optional[tuple]
    comments: Optional[List[str]]

    class Config:
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
