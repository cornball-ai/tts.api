# Test tts() input validation

# input must be non-empty character
expect_error(tts(NULL, voice = "nova"), pattern = "non-empty character")
expect_error(tts("", voice = "nova"), pattern = "non-empty character")
expect_error(tts(123, voice = "nova"), pattern = "non-empty character")
expect_error(tts(c("a", "b"), voice = "nova"), pattern = "non-empty character")

# voice must be non-empty character
expect_error(tts("hello", voice = NULL), pattern = "non-empty character")
expect_error(tts("hello", voice = ""), pattern = "non-empty character")
expect_error(tts("hello", voice = 123), pattern = "non-empty character")

# backend must be valid
expect_error(tts("hello", voice = "nova", backend = "invalid"), pattern = "arg")

