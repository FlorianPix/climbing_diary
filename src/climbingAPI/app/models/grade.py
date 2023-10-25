from pydantic import BaseModel, Field
from .grading_system import GradingSystem


class Grade(BaseModel):
    grade: str = Field(...)
    system: GradingSystem = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "grade": "5a",
                "system": GradingSystem.FRENCH,
            }
        }
