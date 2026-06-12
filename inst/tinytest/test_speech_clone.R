# Test speech_clone() input validation

# input must be non-empty character
expect_error(
  speech_clone(NULL, voice_file = "x.wav"),
  pattern = "non-empty character"
)
expect_error(
  speech_clone("", voice_file = "x.wav"),
  pattern = "non-empty character"
)
expect_error(
  speech_clone(123, voice_file = "x.wav"),
  pattern = "non-empty character"
)

# voice_file must be a character string
expect_error(
  speech_clone("hello", voice_file = NULL),
  pattern = "character string"
)
expect_error(
  speech_clone("hello", voice_file = 123),
  pattern = "character string"
)

# voice_file must exist
expect_error(
  speech_clone("hello", voice_file = "nonexistent_xyz.wav"),
  pattern = "not found"
)

# backend must be valid
expect_error(
  speech_clone("hello", voice_file = "x.wav", backend = "invalid"),
  pattern = "arg"
)
