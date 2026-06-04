import logging
from datetime import UTC, datetime

from postgrest.exceptions import APIError
from starlette.concurrency import run_in_threadpool

from app.clients.supabase import get_supabase_service_client
from app.models.preferences import PreferencesRequest

log = logging.getLogger(__name__)


class PreferencesSaveError(RuntimeError):
    pass


class PreferencesService:
    async def save_preferences(self, input: PreferencesRequest, user_id: str) -> None:
        payload = {
            "user_id": user_id,
            "distance_meters": input.distance_meters,
            "budget_level": input.budget_level,
            "diet_preferences": [
                preference.value for preference in input.diet_preferences
            ],
            "updated_at": datetime.now(UTC).isoformat(),
        }

        await run_in_threadpool(self._upsert_preferences, payload=payload)

    def _upsert_preferences(self, payload: dict) -> None:
        try:
            (
                get_supabase_service_client()
                .table("preferences")
                .upsert(payload, on_conflict="user_id")
                .execute()
            )
        except APIError as exc:
            log.error(exc)
            raise PreferencesSaveError(str(exc)) from exc
