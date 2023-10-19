from datetime import date, datetime
from pydantic import BaseModel, Field
from typing import List


class AscentModel(BaseModel):
    updated: datetime
    media_ids: List[str] = []
    ascent_id: str = Field(default_factory=str, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
    date: date
    style: int = Field(..., ge=0, le=5)
    type: int = Field(..., ge=0, le=4)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "updated": "2022-10-06T20:13:16.816000",
                "_id": "",
                "media_ids": [],
                "user_id": "",
                "comment": "Great ascent",
                "date": "2022-10-06",
                "style": 0,
                "type": 3,
            }
        }
