# tts.api 0.2.0.2 (development)

* Add `source` argument to `tts()`: run chatterbox in-process via the R package (`source = "package"`) or over HTTP (`source = "api"`, the default), with `"auto"` picking the package when installed
* Call-record sidecars for `tts()`, `speech_clone()`, and `speech_design()`
* Fix voice listing for the `/v1/audio/voices` endpoint

# tts.api 0.2.0

* Rename `speech()` to `tts()` for API consistency
* Add qwen3-tts backend: instructions mapping and `language` parameter
* Add voice library for `~/.cornball/voices/`: `voice_library()`, `voice_file()`, `voice_ensure()`

# tts.api 0.1.0

* Initial release
* Support for OpenAI-compatible text-to-speech APIs
* Multiple backend support: OpenAI, Chatterbox, ElevenLabs
* Voice cloning support via voice_upload() and speech_clone()
* Speed adjustment via ffmpeg post-processing for local backends
