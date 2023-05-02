from bson import ObjectId
from datetime import date
from pydantic import BaseModel, Field
from typing import List

from .grading_system import GradingSystem


class Grade(BaseModel):
    grade: str = Field(...)
    system: GradingSystem = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "grade": "",
                "system": GradingSystem.FRENCH,
            }
        }
