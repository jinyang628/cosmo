import httpx
import logging

from fastapi import APIRouter
from fastapi.responses import JSONResponse

from app.models.preferences import PreferencesRequest
from app.services.preferences import PreferencesService

log = logging.getLogger(__name__)


class PreferencesController:
    def __init__(self, service: PreferencesService):
        self.router = APIRouter()
        self.service = service
        self.setup_routes()

    def setup_routes(self):
        router = self.router

        @router.post("")
        async def save_preferences(input: PreferencesRequest) -> JSONResponse:
            log.info("Saving user preferences...")
            await self.service.save_preferences(input=input)
            log.info("User preferences saved")
            return JSONResponse(content="Preferences saved successfully")
