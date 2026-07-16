#' List Voice Files in Library
#'
#' Scans a directory for voice sample files and returns their paths.
#'
#' @param voices_dir Path to voice library directory.
#'   Defaults to \code{TTS_VOICES_DIR} env var, then \code{~/.cornball/voices}.
#' @return Named character vector: names are voice names (filename without
#'   extension), values are full file paths. Returns empty named character
#'   vector if directory doesn't exist or contains no voice files.
#'
#' @export
#' @examples
#' \dontrun{
#' voice_library()
#' voice_library("~/my-voices")
#' }
voice_library <- function(voices_dir = NULL) {
    if (is.null(voices_dir)) {
        voices_dir <- Sys.getenv("TTS_VOICES_DIR", "~/.cornball/voices")
    }
    voices_dir <- path.expand(voices_dir)

    if (!dir.exists(voices_dir)) {
        return(structure(character(0), names = character(0)))
    }

    files <- list.files(voices_dir, pattern = "\\.(wav|mp3|m4a|flac)$",
                        full.names = TRUE, ignore.case = TRUE)
    if (length(files) == 0) {
        return(structure(character(0), names = character(0)))
    }

    names(files) <- tools::file_path_sans_ext(basename(files))
    files
}

#' Resolve Voice Name to File Path
#'
#' Looks up a voice by name in the voice library directory.
#' Case-insensitive matching is attempted if exact match fails.
#'
#' @param voice_name Character. Name of the voice to find.
#' @param voices_dir Path to voice library directory (see \code{\link{voice_library}}).
#' @return Character string: full path to the voice file.
#'   Stops with an error if the voice is not found.
#'
#' @export
#' @examples
#' \dontrun{
#' voice_file("BigCasey")
#' voice_file("delicatecasey")
#' }
voice_file <- function(voice_name, voices_dir = NULL) {
    lib <- voice_library(voices_dir)

    # Exact match
    if (voice_name %in% names(lib)) {
        return(unname(lib[voice_name]))
    }

    # Case-insensitive match
    idx <- match(tolower(voice_name), tolower(names(lib)))
    if (!is.na(idx)) {
        return(unname(lib[idx]))
    }

    stop("Voice '", voice_name, "' not found in library. Available: ",
         paste(names(lib), collapse = ", "), call. = FALSE)
}

#' Ensure Voice is Available on TTS Server
#'
#' Checks if a voice exists on the current TTS server. If not, finds the
#' voice file in the library and uploads it.
#'
#' @param voice_name Character. Name of the voice.
#' @param voices_dir Path to voice library directory (see \code{\link{voice_library}}).
#' @return Invisible \code{TRUE} if the voice is available (already present or
#'   successfully uploaded).
#'
#' @export
#' @examples
#' \dontrun{
#' set_tts_base("http://localhost:4123")
#' voice_ensure("BigCasey")
#' tts("Hello!", voice = "BigCasey", file = "out.mp3")
#' }
voice_ensure <- function(voice_name, voices_dir = NULL) {
    # Check if voice already on server
    server_voices <- tryCatch(voices(), error = function(e) NULL)

    if (!is.null(server_voices)) {
        # Normalize to character vector of names
        v_names <- if (is.data.frame(server_voices) &&
            "name" %in% names(server_voices)) {
            server_voices$name
        } else if (is.data.frame(server_voices) &&
            "id" %in% names(server_voices)) {
            server_voices$id
        } else if (is.character(server_voices)) {
            server_voices
        } else {
            character(0)
        }

        if (tolower(voice_name) %in% tolower(v_names)) {
            message("Voice '", voice_name, "' already on server")
            return(invisible(TRUE))
        }
    }

    # Find and upload
    vf <- voice_file(voice_name, voices_dir)
    message("Uploading voice '", voice_name, "' from ", vf)
    voice_upload(voice_file = vf, voice_name = voice_name, language = "en")
    invisible(TRUE)
}
