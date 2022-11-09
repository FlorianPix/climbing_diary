from datetime import date
from pydantic import BaseModel, Field
from bson import ObjectId

from .py_object_id import PyObjectId


class SpotModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date: date
    name: str = Field(...)
    coordinates: tuple = Field(...)
    country: str = Field(...)
    location: tuple = Field(...)
    routes: tuple = Field(...)
    rating: int = Field(..., ge=0, le=5)
    description: str = Field(...)
    children_friendly: bool = Field(...)
    close_parking: bool = Field(...)
    camping_nearby: bool = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "date": "2022-10-08",
                "name": "Falkenstein",
                "coordinates": [-73.856077, 40.848447],
                "country": "Germany",
                "location": ["Thüringen", "Thüringer_Wald"],
                "routes": ["Falkensteiner_Riss-Germany-Thüringen-Thüringer_Wald"],
                "rating": 4,
                "description": "Great spot close to a lake with solid holds but kindof hard to reach.",
                "children_friendly": True,
                "close_parking": False,
                "camping_nearby": True,
            }
        }