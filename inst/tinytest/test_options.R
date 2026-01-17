# Test option setters

# Save original options
old_base <- getOption("tts.api_base")
old_key <- getOption("tts.api_key")
old_elevenlabs <- getOption("tts.elevenlabs_key")
on.exit({
  options(tts.api_base = old_base)
  options(tts.api_key = old_key)
  options(tts.elevenlabs_key = old_elevenlabs)
}, add = TRUE)

# Test set_tts_base
set_tts_base("http://localhost:4123")
expect_equal(getOption("tts.api_base"), "http://localhost:4123")

# Test set_tts_key
set_tts_key("test-key-123")
expect_equal(getOption("tts.api_key"), "test-key-123")

# Test set_elevenlabs_key
set_elevenlabs_key("elevenlabs-test-key")
expect_equal(getOption("tts.elevenlabs_key"), "elevenlabs-test-key")
