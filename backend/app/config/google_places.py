import os


class GooglePlacesConfigError(RuntimeError):
    pass


class GooglePlacesConfig:
    @staticmethod
    def api_key() -> str:
        value = os.getenv("GOOGLE_PLACES_API_KEY")
        if value is None or not value.strip():
            raise GooglePlacesConfigError("GOOGLE_PLACES_API_KEY is not configured")

        return value.strip()
