from typing import Optional
from app.models.route.update_route_model import UpdateRouteModel
from app.models.grade import Grade
from app.models.grading_system import GradingSystem


class UpdateSinglePitchRouteModel(UpdateRouteModel):
    ascent_ids: Optional[tuple]
    grade: Optional[Grade]
    length: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "media_ids": [],
                "ascent_ids": [],
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
                "grade": {"grade": "IV", "system": GradingSystem.SAXONY},
                "length": 40,
            }
        }
