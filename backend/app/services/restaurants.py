import logging
import math
from typing import Any

import httpx

from app.config.google_places import GooglePlacesConfig
from app.models.preferences import DietPreference
from app.models.restaurants import (
    NearbyRestaurantsRequest,
    Restaurant,
    RestaurantLocation,
)

log = logging.getLogger(__name__)


class RestaurantsSearchError(RuntimeError):
    pass


class RestaurantsService:
    _text_search_url = "https://places.googleapis.com/v1/places:searchText"
    _field_mask = ",".join(
        [
            "places.id",
            "places.displayName",
            "places.formattedAddress",
            "places.location",
            "places.rating",
            "places.userRatingCount",
            "places.priceLevel",
            "places.googleMapsUri",
            "places.businessStatus",
        ]
    )

    async def search_nearby(self, input: NearbyRestaurantsRequest) -> list[Restaurant]:
        payload = {
            "textQuery": _build_text_query(input.diet_preferences),
            "includedType": "restaurant",
            "strictTypeFiltering": True,
            "pageSize": input.max_result_count,
            "locationRestriction": _build_location_restriction(
                latitude=input.latitude,
                longitude=input.longitude,
                radius_meters=input.radius_meters,
            ),
        }
        headers = {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": GooglePlacesConfig.api_key(),
            "X-Goog-FieldMask": self._field_mask,
        }

        try:
            async with httpx.AsyncClient(timeout=10) as client:
                response = await client.post(
                    self._text_search_url,
                    headers=headers,
                    json=payload,
                )
                response.raise_for_status()
        except httpx.HTTPStatusError as exc:
            log.warning(
                "Google Places text search failed with status %s: %s",
                exc.response.status_code,
                exc.response.text,
            )
            raise RestaurantsSearchError("Google Places text search failed") from exc
        except httpx.HTTPError as exc:
            log.warning("Google Places text search request failed: %s", exc)
            raise RestaurantsSearchError("Google Places text search failed") from exc

        try:
            data = response.json()
        except ValueError as exc:
            raise RestaurantsSearchError("Google Places returned invalid JSON") from exc

        places = data.get("places", [])
        if not isinstance(places, list):
            raise RestaurantsSearchError("Google Places returned an invalid response")

        return [restaurant for place in places if (restaurant := _parse_place(place))]


def _build_text_query(diet_preferences: list[DietPreference]) -> str:
    return " ".join([*diet_preferences, "restaurant"])


def _build_location_restriction(
    latitude: float,
    longitude: float,
    radius_meters: int,
) -> dict:
    earth_radius_meters = 6378137
    latitude_delta = math.degrees(radius_meters / earth_radius_meters)
    low_latitude = max(-90, latitude - latitude_delta)
    high_latitude = min(90, latitude + latitude_delta)

    latitude_radians = math.radians(latitude)
    latitude_cosine = math.cos(latitude_radians)
    if low_latitude <= -90 or high_latitude >= 90 or abs(latitude_cosine) < 1e-12:
        low_longitude = -180
        high_longitude = 180
    else:
        longitude_delta = math.degrees(radius_meters / (earth_radius_meters * abs(latitude_cosine)))
        if longitude_delta >= 180:
            low_longitude = -180
            high_longitude = 180
        else:
            low_longitude = _normalize_longitude(longitude - longitude_delta)
            high_longitude = _normalize_longitude(longitude + longitude_delta)

    return {
        "rectangle": {
            "low": {
                "latitude": low_latitude,
                "longitude": low_longitude,
            },
            "high": {
                "latitude": high_latitude,
                "longitude": high_longitude,
            },
        }
    }


def _normalize_longitude(longitude: float) -> float:
    normalized = ((longitude + 180) % 360) - 180
    if normalized == -180 and longitude > 0:
        return 180

    return normalized


def _parse_place(place: Any) -> Restaurant | None:
    if not isinstance(place, dict):
        return None

    place_id = place.get("id")
    display_name = place.get("displayName")
    name = display_name.get("text") if isinstance(display_name, dict) else None
    if not isinstance(place_id, str) or not isinstance(name, str):
        return None

    location = _parse_location(place.get("location"))

    return Restaurant(
        id=place_id,
        name=name,
        formatted_address=_string_or_none(place.get("formattedAddress")),
        location=location,
        rating=_float_or_none(place.get("rating")),
        user_rating_count=_int_or_none(place.get("userRatingCount")),
        price_level=_string_or_none(place.get("priceLevel")),
        google_maps_uri=_string_or_none(place.get("googleMapsUri")),
        business_status=_string_or_none(place.get("businessStatus")),
    )


def _parse_location(value: Any) -> RestaurantLocation | None:
    if not isinstance(value, dict):
        return None

    latitude = _float_or_none(value.get("latitude"))
    longitude = _float_or_none(value.get("longitude"))
    if latitude is None or longitude is None:
        return None

    return RestaurantLocation(latitude=latitude, longitude=longitude)


def _string_or_none(value: Any) -> str | None:
    return value if isinstance(value, str) else None


def _float_or_none(value: Any) -> float | None:
    if isinstance(value, bool):
        return None

    return float(value) if isinstance(value, float | int) else None


def _int_or_none(value: Any) -> int | None:
    return value if isinstance(value, int) and not isinstance(value, bool) else None
