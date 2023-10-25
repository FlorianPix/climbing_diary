from pydantic import BaseModel
from typing import Optional


class UpdateAscentModel(BaseModel):
    media_ids: Optional[tuple]
    comment: Optional[str]
    date: Optional[str]
    style: Optional[int]
    type: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "media_ids": [],
                "comment": "Great ascent",
                "date": "2022-10-06",
                "style": 0,
                "type": 3,
            }
        }
