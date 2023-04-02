from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional


class UpdatePitchModel(BaseModel):
    ascend_ids: Optional[tuple]
    media_ids: Optional[tuple]

    comment: Optional[str]
    grade: Optional[str]
    length: Optional[int]
    name: Optional[str]
    num: Optional[int]
    rating: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "ascend_ids": [],
                "media_ids": [],
                "comment": "Top Route",
                "grade": "6a",
                "length": 35,
                "name": "Pitch 1 vom Falkensteiner Riss",
                "num": 1,
                "rating": 5,
            }
        }