from datetime import date, datetime
from pydantic import BaseModel, Field
from typing import List


class TripModel(BaseModel):
    updated: datetime
    media_ids: List[str] = []
    spot_ids: List[str] = []
    trip_id: str = Field(default_factory=str, alias="_id")
    user_id: str = Field(...)

    comment: str = Field(...)
    end_date: date
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)
    start_date: date

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "updated": "2022-10-06T20:13:16.816000",
                "media_ids": [],
                "spot_ids": [],
                "_id": "",
                "user_id": "",
                "comment": "Great trip",
                "end_date": "2022-10-08",
                "name": "Ausflug zum Falkenstein",
                "start_date": "2022-10-06",
                "rating": 5,
            }
        }
