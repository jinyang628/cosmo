from pydantic import BaseModel, Field

from app.models.preferences import DietPreference


class NearbyRestaurantsRequest(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    radius_meters: int = Field(ge=1, le=50000)
    max_result_count: int = Field(default=10, ge=1, le=20)
    diet_preferences: list[DietPreference] = Field(default_factory=list)


class RestaurantLocation(BaseModel):
    latitude: float
    longitude: float


class Restaurant(BaseModel):
    id: str
    name: str
    formatted_address: str | None = None
    location: RestaurantLocation | None = None
    rating: float | None = None
    user_rating_count: int | None = None
    price_level: str | None = None
    google_maps_uri: str | None = None
    business_status: str | None = None


class NearbyRestaurantsResponse(BaseModel):
    restaurants: list[Restaurant]
