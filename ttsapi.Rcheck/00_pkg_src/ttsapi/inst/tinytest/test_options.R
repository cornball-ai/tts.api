# Test option setters

# Save original options
old_base <- getOption("ttsapi.api_base")
old_key <- getOption("ttsapi.api_key")
old_elevenlabs <- getOption("ttsapi.elevenlabs_key")
on.exit({
  options(ttsapi.api_base = old_base)
  options(ttsapi.api_key = old_key)
  options(ttsapi.elevenlabs_key = old_elevenlabs)
}, add = TRUE)

# Test set_tts_base
set_tts_base("http://localhost:4123")
expect_equal(getOption("ttsapi.api_base"), "http://localhost:4123")

# Test set_tts_key
set_tts_key("test-key-123")
expect_equal(getOption("ttsapi.api_key"), "test-key-123")

# Test set_elevenlabs_key
set_elevenlabs_key("elevenlabs-test-key")
expect_equal(getOption("ttsapi.elevenlabs_key"), "elevenlabs-test-key")
