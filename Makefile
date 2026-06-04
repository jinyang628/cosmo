.PHONY: lint

lint:
	cd frontend && dart format .
	cd frontend && flutter analyze
	cd backend && poetry run black .
	cd backend && poetry run isort .
	cd backend && poetry run autoflake --in-place --remove-all-unused-imports --recursive .

start-backend:
	cd backend && poetry run uvicorn app.api.main:app --reload --host 0.0.0.0 --port 8080 --env-file .env

start-frontend:
	cd frontend && flutter run
