# Test speech_design() input validation

# input must be non-empty character
expect_error(
  speech_design(NULL, voice_description = "warm voice"),
  pattern = "non-empty character"
)
expect_error(
  speech_design("", voice_description = "warm voice"),
  pattern = "non-empty character"
)

# voice_description must be non-empty character
expect_error(
  speech_design("hello", voice_description = NULL),
  pattern = "non-empty character"
)
expect_error(
  speech_design("hello", voice_description = ""),
  pattern = "non-empty character"
)
