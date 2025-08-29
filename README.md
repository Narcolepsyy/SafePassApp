# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

# SafePassApp

This app integrates a Python FastAPI microservice wrapping the Hugging Face model `dima806/strong-password-checker-bert` to validate password strength in Devise.

## What was added
- Python FastAPI service at `python/password_service/` using `transformers` pipeline.
- Ruby client `app/services/password_strength_client.rb` with timeouts and fail-open behavior.
- Model validation in `User` to call the service on password set/change.
- Procfile entry to run the Python service alongside Rails in development.
- Tests for the validator with stubbing.

## Quick start (development)

1) Install dependencies and set up dev processes

```bash
bin/setup --skip-server
# Optional: create Python venv manually if you skipped setup
cd python/password_service
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

2) Run all dev processes (Rails, JS/CSS, Python service)

```bash
bin/dev
```

Rails will run on http://127.0.0.1:3000 and the password service on http://127.0.0.1:8001 by default.

3) Health check the Python service

```bash
bin/rails password_service:health
```

## Environment variables

- `PASSWORD_SERVICE_URL` (default `http://127.0.0.1:8001`): Base URL for the Python service.
- `PASSWORD_SERVICE_PORT` (default `8001`): Used by Procfile.dev to bind the service.
- Python service options:
  - `MODEL_ID` (default `dima806/strong-password-checker-bert`)
  - `THRESHOLD` (default `0.5`)

## How validation works

- On user create/update when `password` is present, Rails calls the Python service `/check` with the plaintext password.
- If the service returns a label containing `strong` with score >= `THRESHOLD`, the password is accepted; otherwise an error `is too weak` is added.
- If the service is slow/down, the client logs a warning and fails open (accepts the password) to avoid locking users out. Adjust this behavior in `PasswordStrengthClient` if you prefer fail-closed.

## Running tests

```bash
bin/rails test
```

Unit tests stub the service to verify both strong and weak cases without network calls.

## Production notes

- Run the Python service separately (systemd, container, etc.) and set `PASSWORD_SERVICE_URL` in the Rails environment.
- Ensure the Python runtime has enough memory/CPU to load `transformers` and `torch`.
- Consider pre-warming the model process on boot to reduce first-request latency.
