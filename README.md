# Personal Music NAS

This repository is now focused on the NAS music service and the Flutter music client.

## Structure

- `services/agent-server/` - NAS-side Python service.
  - Proxies Daoliyu music APIs.
  - Stores server data under `/data`.
  - Handles Daoliyu login, music status, playback proxy, radio episodes, and MiniMax TTS radio generation.
- `clients/mu-music/` - Flutter client for Android, macOS, iOS, and web targets.
- `data/` - Local development data notes and secret examples.
- `docs/nas/` - NAS and music proxy implementation notes.
- `operateLog.md` - Local operation history.

## Open Source Boundary

The public repository should only include local-file music management and clean service/client code.

Do not commit:

- real `.env` files
- Daoliyu account credentials
- MiniMax subscription/API keys
- private metadata plugins
- QQ Music / NetEase / Kugou / Kuwo scraper implementations
- generated build output

Third-party metadata scraping should live in private plugin folders outside the public code path.

## NAS Service

Run with Docker Compose:

```bash
docker compose up -d --build
```

Local development:

```bash
cd services/agent-server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m app.main
```

Useful endpoints:

- `GET /health`
- `GET /v1/music/status`
- `POST /v1/music/auth/login`
- `GET /v1/music/radio/status`
- `POST /v1/music/radio/daily/run`

## Flutter Client

```bash
cd clients/mu-music
flutter pub get
flutter run -d macos
```

Build examples:

```bash
flutter build macos --debug
flutter build apk --release --split-per-abi
```

## Secrets

For NAS deployment, store secrets in the mounted data volume:

```text
/volume1/docker/personal-os-agent/data/secrets/agent-server.env
/volume1/docker/personal-os-agent/data/secrets/daoliyu.env
```

For local development, use:

```text
data/secrets/agent-server.env
data/secrets/daoliyu.env
```

Only `*.env.example` files are intended to be committed.
