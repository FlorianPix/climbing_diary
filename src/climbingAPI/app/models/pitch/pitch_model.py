from datetime import datetime
from pydantic import BaseModel, Field
from typing import List
from ..grade import Grade


class PitchModel(BaseModel):
    updated: datetime
    ascent_ids: List[str] = []
    media_ids: List[str] = []
    pitch_id: str = Field(default_factory=str, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
    grade: Grade = Field(...)
    length: int = Field(...)
    name: str = Field(...)
    num: int = Field(..., ge=1)
    rating: int = Field(..., ge=0, le=5)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "updated": "2022-10-06T20:13:16.816000",
                "_id": "",
                "ascent_ids": [],
                "media_ids": [],
                "user_id": "",
                "comment": "Top Pitch",
                "grade": {"6a", 3},
                "length": 35,
                "name": "Pitch 1 vom Falkensteiner Riss",
                "num": 1,
                "rating": 5,
            }
        }