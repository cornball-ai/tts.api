# Call-record sidecars: armed functions write <output>.json on success only.

# A toy "generation" function standing in for a backend call.
toy_gen <- function(prompt, output = tempfile(fileext = ".mp4"),
                    seed = NULL, fail = FALSE) {
    tts.api:::.sidecar_arm(environment())
    if (fail) {
        stop("backend exploded")
    }
    writeLines("video bytes", output)
    invisible(output)
}

out <- toy_gen("a corny prompt", seed = 42L)
sc <- paste0(out, ".json")
expect_true(file.exists(sc))
rec <- jsonlite::fromJSON(sc)
expect_equal(rec$cornball_sidecar, 1L)
expect_equal(rec$package, "tts.api")
expect_equal(rec$fn, "toy_gen")
expect_equal(rec$request$prompt, "a corny prompt")
expect_equal(rec$request$seed, 42L)
expect_equal(rec$request$fail, FALSE)
expect_true(is.numeric(rec$elapsed))
unlink(c(out, sc))

# Error path: no asset, no sidecar.
out2 <- tempfile(fileext = ".mp4")
expect_error(toy_gen("boom", output = out2, fail = TRUE))
expect_false(file.exists(paste0(out2, ".json")))

# Pre-existing stale file (cache hit / skipped work): no sidecar.
out3 <- tempfile(fileext = ".mp4")
writeLines("old", out3)
Sys.setFileTime(out3, Sys.time() - 3600)
toy_cache <- function(output) {
    tts.api:::.sidecar_arm(environment())
    invisible(output) # touches nothing
}
toy_cache(out3)
expect_false(file.exists(paste0(out3, ".json")))
unlink(out3)

# file-named output arg, resolved inside the function (rembg shape).
toy_file <- function(image, file = NULL) {
    tts.api:::.sidecar_arm(environment(), "file")
    if (is.null(file)) {
        file <- tempfile(fileext = ".png")
    }
    writeLines("png bytes", file)
    invisible(file)
}
res <- toy_file("in.png")
expect_true(file.exists(paste0(res, ".json")))
rec2 <- jsonlite::fromJSON(paste0(res, ".json"))
expect_equal(rec2$request$image, "in.png")
unlink(c(res, paste0(res, ".json")))
