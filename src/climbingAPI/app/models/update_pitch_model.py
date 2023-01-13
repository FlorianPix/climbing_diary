from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional


class UpdatePitchModel(BaseModel):
    date: Optional[date]
    name: Optional[str]
    route_id: Optional[str]
    route_name: Optional[str]
    total_pitch_number: Optional[int]
    pitch_number: Optional[int]
    grade: Optional[str]
    length: Optional[int]
    description: Optional[str]
    ascend: Optional[str]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Pitch 1",
                "route_id": "636bb10741073418ee4d0885",
                "route_name": "Falkensteiner Riss",
                "total_pitch_number": 3,
                "pitch_number": 1,
                "grade": "3",
                "length": 10,
                "description": "very easy and can be combined with pitch two at the cost of rope drag",
                "ascend": "onsight",
            }
        }