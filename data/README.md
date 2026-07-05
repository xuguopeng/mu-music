# Agent Server Data Directory

This directory mirrors the NAS host path used by Docker:

```text
/volume1/docker/personal-os-agent/data
```

The container mounts it as:

```text
/data
```

Runtime databases and real secret files must stay out of git.

For Daoliyu, copy:

```text
data/secrets/daoliyu.env.example
```

to:

```text
/volume1/docker/personal-os-agent/data/secrets/daoliyu.env
```

Then fill in the real account values on the NAS.

For NAS radio generation with MiniMax TTS, add these values to either:

```text
/volume1/docker/personal-os-agent/data/secrets/agent-server.env
```

or the existing:

```text
/volume1/docker/personal-os-agent/data/secrets/daoliyu.env
```

```env
RADIO_OUTPUT_DIR=/data/radio
MINIMAX_SUBSCRIPTION_KEY=
MINIMAX_API_KEY=
MINIMAX_GROUP_ID=
MINIMAX_TTS_VOICE_ID=male-qn-jingying
MINIMAX_TTS_MODEL=speech-2.8-hd
RADIO_DAILY_ENABLED=true
RADIO_DAILY_TIME=07:30
RADIO_DAILY_TIMEZONE=Asia/Shanghai
RADIO_WEATHER_CITY=陕西西安
RADIO_WEATHER_LAT=34.3416
RADIO_WEATHER_LON=108.9398
RADIO_RECENT_LIMIT=30
```

`MINIMAX_SUBSCRIPTION_KEY` is the preferred Token Plan key. `MINIMAX_API_KEY`
remains supported only as a pay-as-you-go fallback; do not put either real key
in git-tracked files or `docker-compose.yml`.

If MiniMax is not configured, the service still creates a playable local test
audio file so the desktop and mobile playback flow can be verified.
