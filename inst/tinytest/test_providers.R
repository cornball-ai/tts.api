# Test TTS provider configuration

# tts_providers is a named list
expect_true(is.list(tts_providers))
expect_true(length(tts_providers) > 0)

# Expected providers exist
expect_true("OpenAI" %in% names(tts_providers))
expect_true("ElevenLabs" %in% names(tts_providers))

# Each provider has expected structure
for (name in names(tts_providers)) {
  p <- tts_providers[[name]]
  expect_true(is.list(p), info = paste(name, "should be a list"))
  expect_true("voices" %in% names(p) || is.null(p$voices),
    info = paste(name, "should have voices field"))
  expect_true("base_url" %in% names(p),
    info = paste(name, "should have base_url"))
}

# OpenAI has static voice list
expect_true(is.character(tts_providers[["OpenAI"]]$voices))
expect_true("nova" %in% tts_providers[["OpenAI"]]$voices)
expect_true("alloy" %in% tts_providers[["OpenAI"]]$voices)
