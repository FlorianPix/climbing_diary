from datetime import date
from pydantic import BaseModel, Field
from typing import Optional


class CreateTripModel(BaseModel):
    trip_id: str = Field(default_factory=str, alias="_id")
    comment: Optional[str]
    end_date: date
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)
    start_date: date

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "comment": "Great trip",
                "end_date": "2022-10-08",
                "name": "Ausflug zum Falkenstein",
                "start_date": "2022-10-06",
                "rating": 5,
            }
        }
