from datetime import datetime
from pydantic import BaseModel, Field
from bson import ObjectId

from app.models.py_object_id import PyObjectId


class IdWithDatetime(BaseModel):
    updated: datetime
    a_id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "updated": "2022-10-06T20:13:16.816000",
                "_id": "",
            }
        }
