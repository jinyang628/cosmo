from app.models.preferences import PreferencesRequest


class PreferencesService:
    def __init__(self):
        self.saved_preferences: PreferencesRequest | None = None

    async def save_preferences(self, input: PreferencesRequest) -> None:
        self.saved_preferences = input
