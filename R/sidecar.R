# sidecar.R
# Call-record sidecars: every asset this package writes gets a JSON record of
# the call that made it, at <output>.json. The API client is the only place
# the resolved call exists (defaults filled, sizes computed), and the sidecar
# rides with the media file -- it survives any downstream bundle or timeline
# rebuild. cornductor scoops sidecars into the OTIO media-reference metadata.
# Convention shared across cornball.ai generation packages (cornball_sidecar
# schema v1: package, version, fn, request, elapsed, created).

# Arm a sidecar for the calling function: registers an on.exit hook that, on
# return, writes <output>.json when the output file exists with an mtime at or
# after the call started (i.e. the call actually produced its asset; error
# paths and cache hits write nothing). One line at the top of a public
# generation function:  .sidecar_arm(environment())  -- use the output_arg
# name of the function's output-path argument ("output", "file", ...).
.sidecar_arm <- function(env, output_arg = "output") {
    fn_call <- sys.call(-1)
    fn <- if (is.null(fn_call)) "unknown" else deparse(fn_call[[1]])
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
                elapsed = if (!is.null(started)) {
            round(as.numeric(difftime(Sys.time(), started, units = "secs")), 2)
        },
                created = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"))
    rec <- rec[!vapply(rec, is.null, logical(1))]
    try(jsonlite::write_json(rec, paste0(output, ".json"),
                             auto_unbox = TRUE, pretty = TRUE), silent = TRUE)
    invisible(paste0(output, ".json"))
}
