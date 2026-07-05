# Music Scroll And Real Playback Debug

## Symptom

- Entering the music module felt stuck.
- Scrolling inside the music module could get trapped.
- The play button only controlled Daoliyu server-side player state and did not make the PC app produce audio.

## Root Cause

1. Music overview loaded auth, player, tracks, and playlists as one blocking `Promise.all`. A slow or blocked NAS request could make the whole module feel stuck.
2. The music module had nested scroll regions for tracks and playlists inside the already scrollable workspace. Mouse wheel events could land inside an inner region and appear to stop page scrolling.
3. Daoliyu track details expose `filePath` such as `/data/media/...`, but the OpenAPI file does not expose a direct audio stream endpoint. Real PC playback needs an Agent Server audio proxy or a mounted media directory.

## Fix

- Changed music overview loading to `Promise.allSettled`, so one failed request no longer blocks the whole module.
- Added 12-second timeouts to browser fallback NAS requests and Tauri `nas_json_request`.
- Removed nested scroll containers from the track and playlist lists.
- Added NAS audio endpoints:
  - `GET /v1/music/audio/{track_id}/status`
  - `GET /v1/music/audio/{track_id}`
- Added frontend local audio playback with an `<audio controls>` element.
- Documented `DAOLIYU_MEDIA_ROOT=/data/media` and the required Docker media volume mount.

## Verification

- `CI=true pnpm build` passed.
- `cargo test` passed, 33 tests.
- `python3 -m compileall services/agent-server/app` passed.
- Browser QA captured the music page and confirmed the local audio player renders.

## Remaining Deployment Note

For real audio on NAS, mount the actual music library into the Agent Server container so Daoliyu `filePath` entries under `/data/media` exist inside this container.

## Status

DONE_WITH_CONCERNS: code path is implemented and verified locally, but real audio output requires NAS deployment with the media volume mounted.
