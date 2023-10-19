from pydantic import BaseModel, Field
from typing import List, Optional


class CreateSpotModel(BaseModel):
    comment: Optional[str]
    coordinates: List[float] = []
    distance_parking: Optional[int]
    distance_public_transport: Optional[int]
    location: str = Field(...)
    name: str = Field(...)
    rating: int = Field(..., ge=0, le=5)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "comment": "Great spot close to a lake with solid holds but kinda hard to reach.",
                "coordinates": [50.746036, 10.642666],
                "distance_parking": 120,
                "distance_public": 120,
                "location": "Deutschland, Thüringen, Thüringer Wald",
                "name": "Falkenstein",
                "rating": 5,
            }
        }
