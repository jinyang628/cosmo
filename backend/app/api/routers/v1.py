import logging

from fastapi import APIRouter

from app.controllers.preferences import PreferencesController
from app.controllers.restaurants import RestaurantsController
from app.services.preferences import PreferencesService
from app.services.restaurants import RestaurantsService

log = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1")

### Health check


@router.get("/status")
async def status():
    log.info("Status endpoint called")
    return {"status": "ok"}


### Preferences


def get_preferences_controller_router():
    service = PreferencesService()
    return PreferencesController(service=service).router


router.include_router(
    get_preferences_controller_router(),
    tags=["preferences"],
    prefix="/preferences",
)


### Restaurants


def get_restaurants_controller_router():
    service = RestaurantsService()
    return RestaurantsController(service=service).router


router.include_router(
    get_restaurants_controller_router(),
    tags=["restaurants"],
    prefix="/restaurants",
)
