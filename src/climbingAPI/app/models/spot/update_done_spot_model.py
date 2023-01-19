from datetime import date
from pydantic import BaseModel
from bson import ObjectId
from typing import Optional, List


class UpdateSpotModel(BaseModel):
    date: Optional[str]
    spot_id: Optional[str]
    spot_name: Optional[str]
    done_routes: Optional[tuple]
    rating: Optional[int]
    comment: Optional[str]
    media_ids: Optional[tuple]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein",
                "done_routes": [],
                "rating": 5,
                "comment": "We had very good conditions that day.",
                "media_ids": []
            }
        }
