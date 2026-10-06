# tts.api 0.3.0.3

* A third place chatterbox runs: `source = "gpuhost"` synthesizes on the
  fleet's GPU host through the 'gpu.host' package (Suggests), one
  `/infer` request carrying the text and the voice. A voice file goes
  as its bytes; a name is looked up in the host's own library first,
  then the local one. `model` is the host's catalog entry
  (`"chatterbox-turbo"`; `"turbo"` means the same); NULL takes
  `options(tts.gpuhost_entry)`, else the first chatterbox entry the
  host's `/health` lists. The entry takes `temperature` and no CFG, so
  `exaggeration`, `cfg_weight` and `seed` are reported as not sent.
  The reply is written as a WAV; another extension or a `speed` goes
  through ffmpeg. `source = "auto"` now tries the package, then a
  configured GPU host, then the API.

# tts.api 0.3.0.2

* Ship the `tts` skill under `inst/skills/tts/`: agent instructions for
  reading text aloud against a Chatterbox server, chunking long input so
  the server does not truncate it silently, stripping markdown before
  synthesis, and choosing the backend and source explicitly. Moved here
  from the personal skill hub so it versions with the package.

# tts.api 0.3.0.1

* Sidecars record a `media` block of delivered facts probed from the
  produced file: for audio, the delivered duration, sample rate, and
  channels. The request is intent; the media block is what actually
  landed. Probe failure or a missing ffprobe drops the block and never
  breaks a write. Also guards `fn` against `do.call()` callers that
  spliced the closure source into the record. (Mirrors xtx.api's
  delivered-facts sidecar; the chatterbox engine is untouched.)

# tts.api 0.3.0

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
