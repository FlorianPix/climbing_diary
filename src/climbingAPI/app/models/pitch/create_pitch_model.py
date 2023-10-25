from pydantic import BaseModel, Field
from typing import Optional
from ..grade import Grade


class CreatePitchModel(BaseModel):
    comment: Optional[str]
    grade: Grade = Field(...)
    length: int = Field(..., ge=0)
    name: str = Field(...)
    num: int = Field(..., ge=1)
    rating: int = Field(..., ge=0, le=5)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "comment": "Top Pitch",
                "grade": {"6a", 3},
                "length": 35,
                "name": "Pitch 1 vom Falkensteiner Riss",
                "num": 1,
                "rating": 5,
            }
        }