# sidecar.R
# Call-record sidecars: every asset this package writes gets a JSON record of
# the call that made it, at <output>.json. The record carries the resolved
# request (defaults filled) plus a `media` block describing the artifact as
# delivered -- the request is intent, the media block is what actually landed
# (e.g. the produced audio's true duration, which need not match a requested
# length). The sidecar rides with the media file: it survives any downstream
# bundle or timeline rebuild. Convention shared across cornball.ai generation
# packages (cornball_sidecar schema v1: package, version, fn, request, media,
# elapsed, created).

# Arm a sidecar for the calling function: registers an on.exit hook that, on
# return, writes <output>.json when the output file exists with an mtime at or
# after the call started (i.e. the call actually produced its asset; error
# paths and cache hits write nothing). One line at the top of a public
# generation function:  .sidecar_arm(environment())  -- use the output_arg
# name of the function's output-path argument ("output", "file", ...).
.sidecar_arm <- function(env, output_arg = "output") {
    fn_call <- sys.call(-1)
    if (is.null(fn_call)) {
        fn <- "unknown"
    } else {
        fn <- deparse(fn_call[[1]])
    }
    # do.call() splices the closure itself into the call; a multi-line
    # deparse is the function source, not a name.
    if (length(fn) != 1) {
        fn <- "unknown"
    }
    arg_names <- setdiff(names(formals(sys.function(-1))), "...")
    started <- Sys.time()
    # Splice the function OBJECT into the on.exit call: the hook then needs
    # no name lookup, so it works regardless of the caller's search path.
    expr <- bquote((.(.sidecar_finish))(.(fn), .(output_arg), .(env),
                   .(started), .(arg_names)))
    do.call(on.exit, list(expr, add = TRUE), envir = env)
}

# The on.exit half: snapshot the function's RESOLVED arguments (short atomics
# only -- no raw payloads) and write the record next to the produced asset.
.sidecar_finish <- function(fn, output_arg, env, started, arg_names) {
    out <- tryCatch(get(output_arg, envir = env), error = function(e) NULL)
    ok <- is.character(out) && length(out) == 1 && !is.na(out) &&
    file.exists(out) && file.mtime(out) >= started - 1
    if (!ok) {
        return(invisible(NULL))
    }
    a <- mget(arg_names, envir = env, ifnotfound = list(NULL))
    keep <- vapply(a, function(x) {
        !is.null(x) && is.atomic(x) && !is.raw(x) && length(x) <= 16
    }, logical(1))
    .write_sidecar(out, fn, a[keep], started)
}

# Write the record. A sidecar failure must never break generation.
.write_sidecar <- function(output, fn, request, started = NULL) {
    pkg <- utils::packageName()
    rec <- list(cornball_sidecar = 1L, package = pkg,
                version = as.character(utils::packageVersion(pkg)),
                fn = fn, request = request,
                media = .sidecar_media(output),
                elapsed = if (!is.null(started)) {
            round(as.numeric(difftime(Sys.time(), started, units = "secs")), 2)
        },
                created = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"))
    rec <- rec[!vapply(rec, is.null, logical(1))]
    try(jsonlite::write_json(rec, paste0(output, ".json"), auto_unbox = TRUE,
                             pretty = TRUE), silent = TRUE)
    invisible(paste0(output, ".json"))
}

# Facts about the artifact as delivered, probed with ffprobe by media kind.
# This package produces audio, so the audio branch is what fires; the video
# and image branches keep the helper identical to the other cornball.ai
# generation packages (shared cornball_sidecar schema v1). For video,
# `frames` is the DECODED frame count (-count_frames), not the container
# header, which can be off by one. Must never error and must never block a
# write: probe failure or a missing ffprobe just drops the media block.
.sidecar_media <- function(output) {
    if (!nzchar(Sys.which("ffprobe"))) {
        return(NULL)
    }
    ext <- tolower(tools::file_ext(output))
    kind <- if (ext %in% c("mp4", "mov", "webm", "mkv")) {
        "video"
    } else if (ext %in% c("png", "jpg", "jpeg", "webp")) {
        "image"
    } else if (ext %in% c("mp3", "wav", "flac", "ogg")) {
        "audio"
    } else {
        return(NULL)
    }
    m <- try(switch(kind, video = .probe_video(output, ext),
                    image = .probe_image(output, ext),
                    audio = .probe_audio(output, ext)), silent = TRUE)
    # `format` is the extension, known without probing; a block carrying only
    # that measured nothing (unreadable/missing file) -- emit no media block.
    if (inherits(m, "try-error") || is.null(m) ||
        length(setdiff(names(m), "format")) == 0) {
        NULL
    } else {
        m
    }
}

.ffprobe_json <- function(args) {
    out <- suppressWarnings(system2("ffprobe",
                                    c("-v", "error", args, "-of", "json"),
                                    stdout = TRUE, stderr = FALSE))
    jsonlite::fromJSON(paste(out, collapse = ""))
}

.probe_video <- function(output, ext) {
    j <- .ffprobe_json(c("-select_streams", "v:0", "-count_frames",
                         "-show_entries",
                         "stream=width,height,r_frame_rate,nb_read_frames",
                         "-show_entries", "format=duration", output))
    s <- j$streams
    if (is.null(s) || nrow(s) == 0) {
        return(NULL)
    }
    rate <- as.numeric(strsplit(s$r_frame_rate[1], "/", fixed = TRUE)[[1]])
    m <- list(format = ext,
              frames = suppressWarnings(as.integer(s$nb_read_frames[1])),
              fps = round(rate[1] / rate[2], 3),
              width = as.integer(s$width[1]),
              height = as.integer(s$height[1]),
              duration = suppressWarnings(round(as.numeric(j$format$duration), 3)))
    .drop_empty(m)
}

.probe_image <- function(output, ext) {
    j <- .ffprobe_json(c("-select_streams", "v:0", "-show_entries",
                         "stream=width,height", output))
    s <- j$streams
    if (is.null(s) || nrow(s) == 0) {
        return(NULL)
    }
    .drop_empty(list(format = ext, width = as.integer(s$width[1]),
                     height = as.integer(s$height[1])))
}

.probe_audio <- function(output, ext) {
    j <- .ffprobe_json(c("-show_entries",
                         "stream=sample_rate,channels:format=duration",
                         "-select_streams", "a:0", output))
    dur <- suppressWarnings(round(as.numeric(j$format$duration), 3))
    s <- j$streams
    sr <- if (!is.null(s) && nrow(s) > 0) {
        suppressWarnings(as.integer(s$sample_rate[1]))
    } else {
        NULL
    }
    ch <- if (!is.null(s) && nrow(s) > 0) {
        suppressWarnings(as.integer(s$channels[1]))
    } else {
        NULL
    }
    .drop_empty(list(format = ext, duration = dur, sample_rate = sr,
                     channels = ch))
}

.drop_empty <- function(m) {
    m[!vapply(m, function(x) is.null(x) || length(x) == 0 || all(is.na(x)),
              logical(1))]
}
