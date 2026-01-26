# Test speech() input validation

# input must be non-empty character
expect_error(speech(NULL, voice = "nova"), pattern = "non-empty character")
expect_error(speech("", voice = "nova"), pattern = "non-empty character")
expect_error(speech(123, voice = "nova"), pattern = "non-empty character")
expect_error(speech(c("a", "b"), voice = "nova"), pattern = "non-empty character")

# voice must be non-empty character
expect_error(speech("hello", voice = NULL), pattern = "non-empty character")
expect_error(speech("hello", voice = ""), pattern = "non-empty character")
expect_error(speech("hello", voice = 123), pattern = "non-empty character")

# backend must be valid
expect_error(speech("hello", voice = "nova", backend = "invalid"), pattern = "arg")

