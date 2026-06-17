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


class RestaurantAccessibilityOptions(BaseModel):
    wheelchair_accessible_parking: bool | None = None
    wheelchair_accessible_entrance: bool | None = None
    wheelchair_accessible_restroom: bool | None = None
    wheelchair_accessible_seating: bool | None = None


class RestaurantAttribution(BaseModel):
    display_name: str | None = None
    uri: str | None = None
    photo_uri: str | None = None


class Restaurant(BaseModel):
    id: str
    name: str
    resource_name: str | None = None
    formatted_address: str | None = None
    short_formatted_address: str | None = None
    location: RestaurantLocation | None = None
    types: list[str] = Field(default_factory=list)
    primary_type: str | None = None
    primary_type_display_name: str | None = None
    rating: float | None = None
    user_rating_count: int | None = None
    price_level: str | None = None
    price_range: str | None = None
    google_maps_uri: str | None = None
    website_uri: str | None = None
    business_status: str | None = None
    open_now: bool | None = None
    opening_hours_weekday_descriptions: list[str] = Field(default_factory=list)
    accessibility_options: RestaurantAccessibilityOptions | None = None
    attributions: list[RestaurantAttribution] = Field(default_factory=list)
    moved_place: str | None = None
    moved_place_id: str | None = None


class NearbyRestaurantsResponse(BaseModel):
    restaurants: list[Restaurant]
