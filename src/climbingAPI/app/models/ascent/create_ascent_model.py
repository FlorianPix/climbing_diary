from datetime import date
from pydantic import BaseModel, Field
from typing import List, Optional


class CreateAscentModel(BaseModel):
    comment: Optional[str]
    date: date
    style: int = Field(..., ge=0, le=5)
    type: int = Field(..., ge=0, le=4)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "comment": "Great ascent",
                "date": "2022-10-06",
                "style": 0,
                "type": 3,
            }
        }
