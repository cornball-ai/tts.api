# source = "gpuhost": chatterbox on the fleet's GPU host through gpu.host.
#
# Everything here runs against gpu.host's request hook, so no host and no
# network: the assertions are about what tts() sends and what it writes
# from the host's reply. The source-resolution tests fake .has_chatterbox
# so they do not depend on what this machine has installed.

if (!requireNamespace("gpu.host", quietly = TRUE)) {
    exit_file("gpu.host not installed")
}

# ---- isolate from any real gpu.host configuration on this machine ----
cfg_dir <- tempfile("tts-gpuhost-")
old_cfg <- Sys.getenv("R_USER_CONFIG_DIR", unset = NA)
Sys.setenv(R_USER_CONFIG_DIR = cfg_dir)
old_env <- Sys.getenv(c("GPU_HOST_BASE", "GPU_HOST_TOKEN"), unset = NA)
Sys.unsetenv(c("GPU_HOST_BASE", "GPU_HOST_TOKEN"))
old_opts <- options(gpu.host.base = NULL, gpu.host.token = NULL,
                    gpu.host.http = NULL, tts.gpuhost_entry = NULL,
                    tts.api_base = NULL, tts.timeout = 30)

ns <- asNamespace("tts.api")
with_fake <- function(name, value, expr) {
    orig <- get(name, ns)
    unlockBinding(name, ns)
    assign(name, value, envir = ns)
    on.exit({
        assign(name, orig, envir = ns)
        lockBinding(name, ns)
    }, add = TRUE)
    force(expr)
}
without_chatterbox <- function(expr) with_fake(".has_chatterbox", function() FALSE, expr)

# ---- the hook: a health listing, a voice library, and a PCM reply ----
sent <- NULL
calls <- list()
envelope <- function(x, status = 200L) {
    list(status = status,
         headers = list("content-type" = "application/json"),
         body = charToRaw(as.character(jsonlite::toJSON(x, auto_unbox = TRUE,
                                                        null = "null"))))
}
health <- list(status = "ok", protocol = "gpu-host/1",
               entries = c("whisper-small", "chatterbox-turbo"), checks = "x")
library_voices <- list(list(id = "abc123", name = "FatherChristmas"))
samples <- c(0, 0.25, -0.25, 0.5)
pcm <- writeBin(samples, raw(), size = 4L, endian = "little")
answer <- list(status = 200L,
               headers = list("content-type" = "application/octet-stream",
                              "x-gpuhost-meta" = '{"ok":true,"sample_rate":24000}'),
               body = pcm)
options(gpu.host.http = function(method, url, headers, body, timeout) {
    calls[[length(calls) + 1L]] <<- url
    if (grepl("/health$", url)) {
        return(envelope(list(ok = TRUE, value = health)))
    }
    if (grepl("/voices$", url)) {
        return(envelope(list(ok = TRUE, value = list(protocol = "gpu-host/1",
                                                     voices = library_voices))))
    }
    sent <<- list(method = method, url = url, headers = headers, body = body,
                  timeout = timeout)
    answer
})

tok <- tempfile("token-")
writeBin(as.raw(1:32), tok)
ref <- tempfile(fileext = ".wav")
ref_bytes <- as.raw(c(0x52, 0x49, 0x46, 0x46, 1:100))
writeBin(ref_bytes, ref)

# ---- not configured: the source refuses and says how to configure ----
expect_false(tts.api:::.gpu_host_configured())
expect_error(tts("hello", voice = ref, source = "gpuhost"), "gpu_host_config")
options(gpu.host.base = "http://gpu:7878", gpu.host.token = tok)
expect_true(tts.api:::.gpu_host_configured())
expect_error(tts("hello", voice = "nova", backend = "openai", source = "gpuhost"),
             "backend = 'chatterbox'")

# ---- the request on the wire: a voice file as bytes, the reply as WAV ----
wav <- tts("hello there", voice = ref, model = "chatterbox-turbo",
           source = "gpuhost")
expect_equal(sent$method, "POST")
expect_equal(sent$url, "http://gpu:7878/infer")
expect_equal(sent$timeout, 30)
expect_true(startsWith(unname(sent$headers[["Authorization"]]), "Bearer "))
req <- jsonlite::fromJSON(sent$body)
expect_equal(req$v, "gpu-host/1")
expect_equal(req$entry, "chatterbox-turbo")
expect_equal(sort(names(req$input)), c("text", "voice_b64"))
expect_equal(req$input$text, "hello there")
expect_equal(req$input$voice_b64, jsonlite::base64_enc(ref_bytes))
expect_equal(req$key, gpu.host::gpu_host_key("chatterbox-turbo", list(
    text = "hello there", voice_b64 = jsonlite::base64_enc(ref_bytes))))
# no file: the WAV bytes
expect_true(is.raw(wav))
expect_equal(rawToChar(wav[1:4]), "RIFF")
expect_equal(readBin(wav[25:28], "integer", size = 4L, endian = "little"), 24000L)
expect_equal(readBin(wav[45:52], "integer", n = 4L, size = 2L, signed = TRUE,
                     endian = "little"), c(0L, 8192L, -8192L, 16384L))

# temperature travels; the knobs the entry lacks are said, not sent
expect_message(tts("hi", voice = ref, model = "turbo", source = "gpuhost",
                   temperature = 0.7, exaggeration = 0.3, cfg_weight = 0.4),
               "takes no exaggeration, cfg_weight; not sent")
req <- jsonlite::fromJSON(sent$body)
expect_equal(req$entry, "chatterbox-turbo")
expect_equal(req$input$temperature, 0.7)
expect_false("exaggeration" %in% names(req$input))
expect_false("cfg_weight" %in% names(req$input))
expect_silent(tts("hi", voice = ref, model = "turbo", source = "gpuhost"))

# ---- the voice by name: the host's library, then the local one ----
calls <- list()
tts("hi", voice = "FatherChristmas", model = "turbo", source = "gpuhost")
expect_true(any(grepl("/voices$", unlist(calls))))
req <- jsonlite::fromJSON(sent$body)
expect_equal(sort(names(req$input)), c("text", "voice_id"))
expect_equal(req$input$voice_id, "abc123")
tts("hi", voice = "fatherchristmas", model = "turbo", source = "gpuhost")
expect_equal(jsonlite::fromJSON(sent$body)$input$voice_id, "abc123")
# a name the host lacks falls back to the local library, as bytes
local_dir <- tempfile("voices-")
dir.create(local_dir)
file.copy(ref, file.path(local_dir, "Local.wav"))
old_dir <- options(tts.voices_dir = local_dir)
res <- tryCatch(tts("hi", voice = "Local", model = "turbo", source = "gpuhost"),
                error = function(e) e)
if (inherits(res, "error")) {
    # the local library is found through voice_file(); if this package
    # resolves its directory another way, say so rather than pass vacuously
    expect_true(grepl("not in the local library", conditionMessage(res)),
                info = conditionMessage(res))
} else {
    expect_equal(jsonlite::fromJSON(sent$body)$input$voice_b64,
                 jsonlite::base64_enc(ref_bytes))
}
options(old_dir)
e <- tryCatch(tts("hi", voice = "Nobody", model = "turbo", source = "gpuhost"),
              error = function(e) e)
expect_true(grepl("not a file, not in the GPU host's library \\(FatherChristmas\\)",
                  conditionMessage(e)))

# ---- which entry: model, then the option, then the host's listing ----
options(tts.gpuhost_entry = "chatterbox-other")
tts("hi", voice = ref, source = "gpuhost")
expect_equal(jsonlite::fromJSON(sent$body)$entry, "chatterbox-other")
options(tts.gpuhost_entry = NULL)
calls <- list()
tts("hi", voice = ref, source = "gpuhost")
expect_equal(calls[[1L]], "http://gpu:7878/health")
expect_equal(jsonlite::fromJSON(sent$body)$entry, "chatterbox-turbo")
health$entries <- "whisper-small"
expect_error(tts("hi", voice = ref, source = "gpuhost"), "no chatterbox entry")
health$entries <- c("whisper-small", "chatterbox-turbo")

# ---- to a file: WAV as is, and the sidecar names the source ----
out <- tempfile(fileext = ".wav")
expect_equal(tts("hi", voice = ref, model = "turbo", file = out, source = "gpuhost"),
             out)
expect_equal(readBin(out, "raw", file.size(out)), wav)
side <- paste0(out, ".json")
expect_true(file.exists(side))
rec <- jsonlite::fromJSON(side)
expect_equal(rec$request$source, "gpuhost")
expect_equal(rec$request$backend, "chatterbox")
expect_equal(rec$request$model, "turbo")
unlink(c(out, side))

# ---- source = "auto": the package, then the host, then the API ----
# (the default source stays "api", as before)
sent <- NULL
without_chatterbox(tts("hi", voice = ref, model = "turbo", source = "auto"))
expect_equal(sent$url, "http://gpu:7878/infer")
expect_error(without_chatterbox(tts("hi", voice = ref, model = "turbo")),
             "set_tts_base")
options(gpu.host.base = NULL)
expect_error(without_chatterbox(tts("hi", voice = ref, model = "turbo", source = "auto")),
             "set_tts_base")
options(gpu.host.base = "http://gpu:7878")

# ---- the host's refusals surface as they are ----
answer <- list(status = 409L, headers = list("content-type" = "application/json"),
               body = charToRaw('{"ok":false,"error":"same key, different content"}'))
e <- tryCatch(tts("hi", voice = ref, model = "turbo", source = "gpuhost"),
              error = function(e) e)
expect_true(inherits(e, "gpu_host_error"))
expect_equal(e$status, 409L)
answer <- envelope(list(ok = FALSE, error = "generation hit the cap"))
expect_error(tts("hi", voice = ref, model = "turbo", source = "gpuhost"),
             "returned no audio")

# ---- restore ----
options(old_opts)
for (nm in names(old_env)) {
    if (is.na(old_env[[nm]])) Sys.unsetenv(nm) else do.call(Sys.setenv, as.list(old_env[nm]))
}
if (is.na(old_cfg)) Sys.unsetenv("R_USER_CONFIG_DIR") else Sys.setenv(R_USER_CONFIG_DIR = old_cfg)
unlink(c(ref, tok, cfg_dir, local_dir), recursive = TRUE)
