from enum import StrEnum

from pydantic import BaseModel, Field


class DietPreference(StrEnum):
    spicy = "spicy"
    vegetarian = "vegetarian"
    vegan = "vegan"
    pescatarian = "pescatarian"


class PreferencesRequest(BaseModel):
    distance_meters: int = Field(
        ge=100,
        le=10000,
        description="The maximum distance in meters for recommendations.",
    )
    budget_level: int = Field(
        ge=1,
        le=4,
        description="The maximum budget level for recommendations, from 1 to 4.",
    )
    diet_preferences: list[DietPreference] = Field(
        default_factory=list,
        description="Dietary preferences to apply to recommendations.",
    )
