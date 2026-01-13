pkgname <- "ttsapi"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "ttsapi-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('ttsapi')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("chatterbox_available")
### * chatterbox_available

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: chatterbox_available
### Title: Check if Chatterbox Service is Available
### Aliases: chatterbox_available

### ** Examples

## Not run: 
##D   if (chatterbox_available()) {
##D     speech("Hello", voice = "default", backend = "chatterbox")
##D   }
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("chatterbox_available", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("chatterbox_voice_upload")
### * chatterbox_voice_upload

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: chatterbox_voice_upload
### Title: Upload Voice to Chatterbox
### Aliases: chatterbox_voice_upload

### ** Examples

## Not run: 
##D   # Upload a voice sample
##D   success <- chatterbox_voice_upload("my_voice.wav", "my-voice")
##D 
##D   if (success) {
##D     speech("Hello!", voice = "my-voice", backend = "chatterbox")
##D   }
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("chatterbox_voice_upload", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("elevenlabs_voice_delete")
### * elevenlabs_voice_delete

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: elevenlabs_voice_delete
### Title: Delete ElevenLabs Voice
### Aliases: elevenlabs_voice_delete

### ** Examples

## Not run: 
##D elevenlabs_voice_delete("abc123")
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("elevenlabs_voice_delete", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("elevenlabs_voice_upload")
### * elevenlabs_voice_upload

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: elevenlabs_voice_upload
### Title: Upload Voice to ElevenLabs (Instant Voice Clone)
### Aliases: elevenlabs_voice_upload

### ** Examples

## Not run: 
##D # Clone from a single file
##D voice <- elevenlabs_voice_upload(
##D   files = "my_voice.mp3",
##D   name = "My Clone"
##D )
##D 
##D # Use the cloned voice
##D speech("Hello!", voice = voice$voice_id, backend = "elevenlabs")
##D 
##D # Clone from multiple samples
##D voice <- elevenlabs_voice_upload(
##D   files = c("sample1.mp3", "sample2.mp3"),
##D   name = "Better Clone",
##D   remove_background_noise = TRUE
##D )
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("elevenlabs_voice_upload", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("elevenlabs_voices")
### * elevenlabs_voices

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: elevenlabs_voices
### Title: List ElevenLabs Voices
### Aliases: elevenlabs_voices

### ** Examples

## Not run: 
##D voices <- elevenlabs_voices()
##D print(voices)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("elevenlabs_voices", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("languages")
### * languages

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: languages
### Title: List Supported Languages
### Aliases: languages

### ** Examples

## Not run: 
##D set_tts_base("http://localhost:4123")
##D langs <- languages()
##D print(langs)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("languages", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("set_elevenlabs_key")
### * set_elevenlabs_key

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: set_elevenlabs_key
### Title: Set ElevenLabs API Key
### Aliases: set_elevenlabs_key

### ** Examples

## Not run: 
##D set_elevenlabs_key("your-api-key-here")
##D # Or use environment variable ELEVENLABS_API_KEY
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("set_elevenlabs_key", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("set_tts_base")
### * set_tts_base

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: set_tts_base
### Title: Set the TTS API Base URL
### Aliases: set_tts_base

### ** Examples

## Not run: 
##D # For local Chatterbox server
##D set_tts_base("http://localhost:4123")
##D 
##D # For OpenAI
##D set_tts_base("https://api.openai.com")
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("set_tts_base", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("set_tts_key")
### * set_tts_key

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: set_tts_key
### Title: Set the TTS API Key
### Aliases: set_tts_key

### ** Examples

## Not run: 
##D set_tts_key(Sys.getenv("OPENAI_API_KEY"))
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("set_tts_key", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("speech")
### * speech

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: speech
### Title: Generate Speech from Text
### Aliases: speech

### ** Examples

## Not run: 
##D # Using local Chatterbox server
##D set_tts_base("http://localhost:4123")
##D speech("Hello, world!", voice = "FatherChristmas", file = "hello.wav")
##D 
##D # Using OpenAI TTS
##D speech("Hello, world!", voice = "nova", file = "hello.mp3", backend = "openai")
##D 
##D # Using ElevenLabs
##D speech("Hello, world!", voice = "XpDLYThV0yUAFjVTok7m",
##D        file = "hello.mp3", backend = "elevenlabs")
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("speech", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("speech_clone")
### * speech_clone

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: speech_clone
### Title: Generate Speech with Voice Cloning
### Aliases: speech_clone

### ** Examples

## Not run: 
##D set_tts_base("http://localhost:4123")
##D 
##D # Clone voice and generate speech
##D speech_clone(
##D   input = "Hello with my custom voice!",
##D   voice_file = "my_voice.mp3",
##D   file = "output.wav",
##D   exaggeration = 0.8
##D )
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("speech_clone", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("tts_health")
### * tts_health

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: tts_health
### Title: Check TTS API Health
### Aliases: tts_health

### ** Examples

## Not run: 
##D set_tts_base("http://localhost:4123")
##D h <- tts_health()
##D if (h$ok) {
##D   message("Server is ready!")
##D }
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("tts_health", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("tts_providers")
### * tts_providers

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: tts_providers
### Title: TTS Provider Configurations
### Aliases: tts_providers

### ** Examples

names(tts_providers)
tts_providers[["OpenAI"]]$voices



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("tts_providers", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("tts_voices")
### * tts_voices

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: tts_voices
### Title: Get Voices for a TTS Provider
### Aliases: tts_voices

### ** Examples

## Not run: 
##D tts_voices("OpenAI")
##D tts_voices("Chatterbox (Local)")
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("tts_voices", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("voice_upload")
### * voice_upload

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: voice_upload
### Title: Upload Voice to Library
### Aliases: voice_upload

### ** Examples

## Not run: 
##D set_tts_base("http://localhost:4123")
##D 
##D # Upload a voice
##D voice_upload(
##D   voice_file = "my_voice.wav",
##D   voice_name = "my-custom-voice"
##D )
##D 
##D # Upload with language
##D voice_upload(
##D   voice_file = "french_voice.wav",
##D   voice_name = "french-speaker",
##D   language = "fr"
##D )
##D 
##D # Then use it by name
##D speech(
##D   input = "Hello with my custom voice!",
##D   voice = "my-custom-voice",
##D   file = "output.wav"
##D )
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("voice_upload", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("voices")
### * voices

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: voices
### Title: List Available Voices
### Aliases: voices

### ** Examples

## Not run: 
##D set_tts_base("http://localhost:4123")
##D v <- voices()
##D print(v)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("voices", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
