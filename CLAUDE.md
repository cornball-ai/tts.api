# ttsapi

Text-to-speech API client. Part of [cornyverse](~/cornyverse).

## Exports

| Function | Purpose |
|----------|---------|
| `speech(input, voice, file)` | Generate speech |
| `speech_clone(input, voice_file, file)` | Voice cloning (Chatterbox) |
| `voice_upload(voice_file, voice_name)` | Upload voice (Chatterbox) |
| `voices()` | List available voices |
| `set_tts_base(url)` | Set API endpoint |
| `set_tts_key(key)` | Set API key |
| `set_elevenlabs_key(key)` | Set ElevenLabs key |

## Backends

- **auto/chatterbox**: OpenAI-compatible API (local)
- **openai**: OpenAI TTS API
- **elevenlabs**: ElevenLabs API

## Options

```r
ttsapi.api_base   # OpenAI-compatible base URL
ttsapi.api_key    # API key
ttsapi.gpuctl     # Enable GPU management (TRUE/FALSE)
```
