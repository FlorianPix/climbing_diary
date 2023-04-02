from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId

from app.models.py_object_id import PyObjectId


class CreatePitchModel(BaseModel):
    comment: str = Optional[str]
    grade: str = Field(...)
    length: int = Field(...)
    name: str = Field(...)
    num: int = Field(..., ge=1)
    rating: int = Field(..., ge=0, le=5)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "comment": "Top Route",
                "grade": "6a",
                "length": 35,
                "name": "Pitch 1 vom Falkensteiner Riss",
                "num": 1,
                "rating": 5,
            }
        }