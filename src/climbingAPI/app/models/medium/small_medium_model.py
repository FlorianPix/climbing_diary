from datetime import datetime
from pydantic import BaseModel, Field
from typing import List


class SmallMediumModel(BaseModel):
    created_at: datetime
    medium_id: str = Field(default_factory=str, alias="_id")
    user_id: str = Field(...)
    title: str = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "created_at": "2022-10-06T20:13:16.816000",
                "_id": "",
                "user_id": "",
                "title": "trip.jpg",
            }
        }
