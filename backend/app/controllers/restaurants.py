import logging

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse

from app.auth.supabase import get_current_user_id
from app.config.google_places import GooglePlacesConfigError
from app.models.restaurants import NearbyRestaurantsRequest
from app.services.restaurants import RestaurantsSearchError, RestaurantsService

log = logging.getLogger(__name__)


class RestaurantsController:
    def __init__(self, service: RestaurantsService):
        self.router = APIRouter()
        self.service = service
        self.setup_routes()

    def setup_routes(self):
        router = self.router

        @router.post("/nearby")
        async def search_nearby_restaurants(
            input: NearbyRestaurantsRequest,
            user_id: str = Depends(get_current_user_id),
        ) -> JSONResponse:
            log.info("Searching nearby restaurants for user %s", user_id)
            try:
                restaurants = await self.service.search_nearby_restaurants(input=input)
            except GooglePlacesConfigError as exc:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=str(exc),
                ) from exc
            except RestaurantsSearchError as exc:
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail="Failed to search nearby restaurants",
                ) from exc

            return JSONResponse(
                content={
                    "restaurants": [
                        restaurant.model_dump() for restaurant in restaurants
                    ]
                }
            )
