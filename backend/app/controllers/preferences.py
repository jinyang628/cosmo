import logging

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse

from app.auth.supabase import get_current_user_id
from app.config.supabase import SupabaseConfigError
from app.models.preferences import PreferencesRequest
from app.services.preferences import PreferencesSaveError, PreferencesService

log = logging.getLogger(__name__)


class PreferencesController:
    def __init__(self, service: PreferencesService):
        self.router = APIRouter()
        self.service = service
        self.setup_routes()

    def setup_routes(self):
        router = self.router

        @router.post("")
        async def save_preferences(
            input: PreferencesRequest,
            user_id: str = Depends(get_current_user_id),
        ) -> JSONResponse:
            log.info("Saving user preferences...")
            try:
                await self.service.save_preferences(input=input, user_id=user_id)
            except SupabaseConfigError as exc:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=str(exc),
                ) from exc
            except PreferencesSaveError as exc:
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail="Failed to save preferences",
                ) from exc

            log.info("User preferences saved")
            return JSONResponse(content={"saved": True})
