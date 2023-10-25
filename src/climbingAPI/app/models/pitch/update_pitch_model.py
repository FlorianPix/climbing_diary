from pydantic import BaseModel
from typing import Optional
from ..grade import Grade


class UpdatePitchModel(BaseModel):
    ascent_ids: Optional[tuple]
    media_ids: Optional[tuple]
    comment: Optional[str]
    grade: Optional[Grade]
    length: Optional[int]
    name: Optional[str]
    num: Optional[int]
    rating: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "ascent_ids": [],
                "media_ids": [],
                "comment": "Top Pitch",
                "grade": {"6a", 3},
                "length": 35,
                "name": "Pitch 1 vom Falkensteiner Riss",
                "num": 1,
                "rating": 5,
            }
        }