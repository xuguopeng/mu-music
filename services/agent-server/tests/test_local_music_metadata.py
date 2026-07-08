from types import SimpleNamespace
import unittest

from app.local_music import (
    fallback_track_metadata,
    flac_streaminfo_duration_seconds,
    guess_media_type,
    safe_duration_seconds,
    track_row_to_api,
)


class SafeDurationSecondsTest(unittest.TestCase):
    def test_non_finite_duration_falls_back_to_zero(self) -> None:
        self.assertEqual(safe_duration_seconds(SimpleNamespace(info=SimpleNamespace(length=float("nan")))), 0)
        self.assertEqual(safe_duration_seconds(SimpleNamespace(info=SimpleNamespace(length=float("inf")))), 0)

    def test_invalid_duration_falls_back_to_zero(self) -> None:
        self.assertEqual(safe_duration_seconds(SimpleNamespace(info=SimpleNamespace(length="bad"))), 0)
        self.assertEqual(safe_duration_seconds(SimpleNamespace(info=None)), 0)

    def test_valid_duration_is_truncated_to_seconds(self) -> None:
        self.assertEqual(safe_duration_seconds(SimpleNamespace(info=SimpleNamespace(length=215.9))), 215)


class FallbackTrackMetadataTest(unittest.TestCase):
    def test_fallback_uses_file_name_when_tags_are_unreadable(self) -> None:
        import tempfile
        from pathlib import Path

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "刘若英-后来.flac"
            path.write_bytes(b"not a real flac")

            metadata = fallback_track_metadata(path)

        self.assertEqual(metadata["title"], "后来")
        self.assertEqual(metadata["artist"], "刘若英")
        self.assertEqual(metadata["file_name"], "刘若英-后来.flac")
        self.assertEqual(metadata["duration_seconds"], 0)


class AudioResponseMetadataTest(unittest.TestCase):
    def test_flac_streaminfo_duration_is_used_without_mutagen(self) -> None:
        import tempfile
        from pathlib import Path

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "test.flac"
            path.write_bytes(build_flac_header(duration_seconds=215))

            self.assertEqual(flac_streaminfo_duration_seconds(path), 215)

    def test_flac_media_type_is_explicit_audio_flac(self) -> None:
        from pathlib import Path

        self.assertEqual(guess_media_type(Path("后来.flac")), "audio/flac")

    def test_api_payload_uses_flac_header_duration_when_row_duration_is_zero(self) -> None:
        import tempfile
        from pathlib import Path

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "后来 - 刘若英.flac"
            path.write_bytes(build_flac_header(duration_seconds=341))

            payload = track_row_to_api(
                {
                    "id": "track-id",
                    "title": "后来",
                    "artist": "刘若英",
                    "album": "我等你",
                    "source_path": str(path),
                    "duration_seconds": 0,
                    "file_name": path.name,
                    "file_format": "flac",
                    "file_size": path.stat().st_size,
                    "year": "",
                    "genre": "",
                    "track_number": 0,
                    "disc_number": 0,
                    "cover_path": "",
                    "lyrics": "",
                    "play_count": 0,
                    "favorite": 0,
                    "last_played_at": "",
                }
            )

        self.assertEqual(payload["durationSeconds"], 341)
        self.assertEqual(payload["dt"], 341000)


def build_flac_header(duration_seconds: int, sample_rate: int = 44_100) -> bytes:
    total_samples = sample_rate * duration_seconds
    packed = (
        (sample_rate & 0xFFFFF) << 44
        | 1 << 41
        | 15 << 36
        | (total_samples & 0xFFFFFFFFF)
    )
    streaminfo = (
        (4096).to_bytes(2, "big")
        + (4096).to_bytes(2, "big")
        + (0).to_bytes(3, "big")
        + (0).to_bytes(3, "big")
        + packed.to_bytes(8, "big")
        + bytes(16)
    )
    return b"fLaC" + b"\x80\x00\x00\x22" + streaminfo


if __name__ == "__main__":
    unittest.main()
