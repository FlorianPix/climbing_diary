from pydantic import Field
from app.models.route.create_route_model import CreateRouteModel
from app.models.grade import Grade
from app.models.grading_system import GradingSystem


class CreateSinglePitchRouteModel(CreateRouteModel):
    grade: Grade = Field(...)
    length: int = Field(..., ge=0)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        schema_extra = {
            "example": {
                "comment": "Top Route",
                "location": "Sektor Falkensteiner Riss",
                "name": "Falkenstein Riss",
                "rating": 5,
                "grade": {"grade": "5a", "system": GradingSystem.FRENCH},
                "length": 40,
            }
        }
