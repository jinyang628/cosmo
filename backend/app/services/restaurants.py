import logging
import math
from decimal import Decimal, InvalidOperation
from typing import Any

import httpx

from app.config.google_places import GooglePlacesConfig, GooglePlacesConfigError
from app.models.preferences import DietPreference
from app.models.restaurants import (
    NearbyRestaurantsRequest,
    Restaurant,
    RestaurantAccessibilityOptions,
    RestaurantAttribution,
    RestaurantLocation,
)

log = logging.getLogger(__name__)


class RestaurantsSearchError(RuntimeError):
    pass


class RestaurantsService:
    _text_search_url = "https://places.googleapis.com/v1/places:searchText"
    _field_mask = ",".join(
        [
            "places.name",
            "places.id",
            "places.attributions",
            "places.displayName",
            "places.formattedAddress",
            "places.shortFormattedAddress",
            "places.location",
            "places.types",
            "places.primaryType",
            "places.primaryTypeDisplayName",
            "places.accessibilityOptions",
            "places.rating",
            "places.userRatingCount",
            "places.priceLevel",
            "places.priceRange",
            "places.googleMapsUri",
            "places.websiteUri",
            "places.businessStatus",
            "places.currentOpeningHours",
            "places.movedPlace",
            "places.movedPlaceId",
        ]
    )

    async def search_nearby_restaurants(
        self, input: NearbyRestaurantsRequest
    ) -> list[Restaurant]:
        try:
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
        except GooglePlacesConfigError as exc:
            log.error("Google Places config error: %s", exc)
            raise RestaurantsSearchError("Google Places config error") from exc
        except Exception as exc:
            log.error(
                "Unknown error occurred while building Google Places text search payload: %s",
                exc,
            )
            raise RestaurantsSearchError(
                "Unknown error occurred while building Google Places text search payload"
            ) from exc

        try:
            async with httpx.AsyncClient(timeout=10) as client:
                response = await client.post(
                    self._text_search_url,
                    headers=headers,
                    json=payload,
                )
                response.raise_for_status()
        except httpx.HTTPStatusError as exc:
            log.error(
                "Google Places text search failed with status %s: %s",
                exc.response.status_code,
                exc.response.text,
            )
            raise RestaurantsSearchError("Google Places text search failed") from exc
        except httpx.HTTPError as exc:
            log.error("Google Places text search request failed: %s", exc)
            raise RestaurantsSearchError("Google Places text search failed") from exc

        try:
            data = response.json()
        except ValueError as exc:
            raise RestaurantsSearchError("Google Places returned invalid JSON") from exc

        places = data.get("places", [])
        if not isinstance(places, list):
            raise RestaurantsSearchError("Google Places returned an invalid response")

        restaurants = [
            restaurant for place in places if (restaurant := _parse_place(place))
        ]
        return [restaurant for restaurant in restaurants if restaurant.open_now is True]


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
        longitude_delta = math.degrees(
            radius_meters / (earth_radius_meters * abs(latitude_cosine))
        )
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
    current_opening_hours = _dict_or_none(place.get("currentOpeningHours"))

    return Restaurant(
        id=place_id,
        name=name,
        resource_name=_string_or_none(place.get("name")),
        formatted_address=_string_or_none(place.get("formattedAddress")),
        short_formatted_address=_string_or_none(place.get("shortFormattedAddress")),
        location=location,
        types=_string_list(place.get("types")),
        primary_type=_string_or_none(place.get("primaryType")),
        primary_type_display_name=_localized_text_or_none(
            place.get("primaryTypeDisplayName")
        ),
        rating=_float_or_none(place.get("rating")),
        user_rating_count=_int_or_none(place.get("userRatingCount")),
        price_level=_string_or_none(place.get("priceLevel")),
        price_range=_format_price_range(place.get("priceRange")),
        google_maps_uri=_string_or_none(place.get("googleMapsUri")),
        website_uri=_string_or_none(place.get("websiteUri")),
        business_status=_string_or_none(place.get("businessStatus")),
        open_now=(
            _bool_or_none(current_opening_hours.get("openNow"))
            if current_opening_hours
            else None
        ),
        opening_hours_weekday_descriptions=_string_list(
            current_opening_hours.get("weekdayDescriptions")
            if current_opening_hours
            else None
        ),
        accessibility_options=_parse_accessibility_options(
            place.get("accessibilityOptions")
        ),
        attributions=_parse_attributions(place.get("attributions")),
        moved_place=_string_or_none(place.get("movedPlace")),
        moved_place_id=_string_or_none(place.get("movedPlaceId")),
    )


def _parse_location(value: Any) -> RestaurantLocation | None:
    if not isinstance(value, dict):
        return None

    latitude = _float_or_none(value.get("latitude"))
    longitude = _float_or_none(value.get("longitude"))
    if latitude is None or longitude is None:
        return None

    return RestaurantLocation(latitude=latitude, longitude=longitude)


def _parse_accessibility_options(value: Any) -> RestaurantAccessibilityOptions | None:
    if not isinstance(value, dict):
        return None

    return RestaurantAccessibilityOptions(
        wheelchair_accessible_parking=_bool_or_none(
            value.get("wheelchairAccessibleParking")
        ),
        wheelchair_accessible_entrance=_bool_or_none(
            value.get("wheelchairAccessibleEntrance")
        ),
        wheelchair_accessible_restroom=_bool_or_none(
            value.get("wheelchairAccessibleRestroom")
        ),
        wheelchair_accessible_seating=_bool_or_none(
            value.get("wheelchairAccessibleSeating")
        ),
    )


def _parse_attributions(value: Any) -> list[RestaurantAttribution]:
    if not isinstance(value, list):
        return []

    attributions: list[RestaurantAttribution] = []
    for item in value:
        if isinstance(item, dict):
            attributions.append(
                RestaurantAttribution(
                    display_name=_string_or_none(item.get("displayName")),
                    uri=_string_or_none(item.get("uri")),
                    photo_uri=_string_or_none(item.get("photoUri")),
                )
            )

    return attributions


def _localized_text_or_none(value: Any) -> str | None:
    if not isinstance(value, dict):
        return None

    return _string_or_none(value.get("text"))


def _format_price_range(value: Any) -> str | None:
    if not isinstance(value, dict):
        return None

    start_price = _format_money(value.get("startPrice"))
    end_price = _format_money(value.get("endPrice"))
    if start_price and end_price:
        return f"{start_price}-{end_price}"
    if start_price:
        return f"{start_price}+"
    if end_price:
        return f"Up to {end_price}"

    return None


def _format_money(value: Any) -> str | None:
    if not isinstance(value, dict):
        return None

    currency_code = _string_or_none(value.get("currencyCode"))
    units = value.get("units", "0")
    nanos = _int_or_none(value.get("nanos")) or 0
    try:
        amount = Decimal(str(units)) + (Decimal(nanos) / Decimal("1000000000"))
    except (InvalidOperation, ValueError):
        return None

    amount_text = f"{amount:,.2f}".rstrip("0").rstrip(".")
    currency_prefix = _currency_prefix(currency_code)
    if currency_prefix:
        return f"{currency_prefix}{amount_text}"
    if currency_code:
        return f"{currency_code} {amount_text}"

    return amount_text


def _currency_prefix(currency_code: str | None) -> str | None:
    return {
        "AUD": "A$",
        "CAD": "C$",
        "EUR": "EUR ",
        "GBP": "GBP ",
        "HKD": "HK$",
        "JPY": "JPY ",
        "SGD": "S$",
        "USD": "$",
    }.get(currency_code or "")


def _dict_or_none(value: Any) -> dict | None:
    return value if isinstance(value, dict) else None


def _string_or_none(value: Any) -> str | None:
    return value if isinstance(value, str) else None


def _string_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []

    return [item for item in value if isinstance(item, str)]


def _bool_or_none(value: Any) -> bool | None:
    return value if isinstance(value, bool) else None


def _float_or_none(value: Any) -> float | None:
    if isinstance(value, bool):
        return None

    return float(value) if isinstance(value, float | int) else None


def _int_or_none(value: Any) -> int | None:
    return value if isinstance(value, int) and not isinstance(value, bool) else None
