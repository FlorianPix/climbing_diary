from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List


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
        json_encoders = {ObjectId: str}
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
