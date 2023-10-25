from pydantic import BaseModel
from typing import Optional


class UpdateTripModel(BaseModel):
    media_ids: Optional[tuple]
    spot_ids: Optional[tuple]

    comment: Optional[str]
    end_date: Optional[str]
    name: Optional[str]
    rating: Optional[int]
    start_date: Optional[str]

    class Config:
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "media_ids": [],
                "spot_ids": [],
                "comment": "Great trip",
                "end_date": "2022-10-08",
                "name": "Ausflug zum Falkenstein",
                "start_date": "2022-10-06",
                "rating": 5,
            }
        }
