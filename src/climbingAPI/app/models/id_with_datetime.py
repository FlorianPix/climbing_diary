from datetime import datetime
from pydantic import BaseModel, Field


class IdWithDatetime(BaseModel):
    updated: datetime
    a_id: str = Field(default_factory=str, alias="_id")

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "updated": "2022-10-06T20:13:16.816000",
                "_id": "",
            }
        }
