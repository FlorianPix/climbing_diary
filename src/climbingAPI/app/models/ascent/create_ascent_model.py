from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import List, Optional

from app.models.py_object_id import PyObjectId


class CreateAscentModel(BaseModel):
    comment: Optional[str]
    date: date
    style: int = Field(..., ge=0, le=5)
    type: int = Field(..., ge=0, le=4)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "comment": "Great ascent",
                "date": "2022-10-06",
                "style": 0,
                "type": 3,
            }
        }
