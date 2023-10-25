from typing import List
from app.models.route.route_model import RouteModel


class MultiPitchRouteModel(RouteModel):
    pitch_ids: List[str] = []

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "updated": "2022-10-06T20:13:16.816000",
                "_id": "",
                "media_ids": [],
                "pitch_ids": [],
                "user_id": "",
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
            }
        }
