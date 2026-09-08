---
name: tts
description: >
  Read text aloud with tts.api against a Chatterbox TTS server: chunk long
  text so the server does not truncate it silently, strip markdown before
  synthesis, concatenate the parts, and pick the backend and source
  explicitly. Use when reading a document, post, or file aloud, generating
  clips with a cloned voice, or when a long input comes back as a tiny
  silent file.
---

# tts: long text through tts.api

The package docs (`README.md`, `CLAUDE.md`) cover server setup,
`set_tts_base()`, `tts_health()`, and voice management. This skill covers
the part they do not: getting a whole document through the server intact.

## Say what you mean

`tts()` has two independent axes. `backend` picks what synthesizes
(`chatterbox`, `qwen3`, `openai`, `elevenlabs`; `auto` lets the package
choose). `source` picks where it runs: `api` (the server), `package`
(in-process, chatterbox only), or `auto`. Pass both explicitly for anything
that must use a cloned voice on the server:

```r
library(tts.api)
set_tts_base("http://<tts-host>:7810")
voice_ensure("FatherChristmas")          # uploads the reference clip if missing
tts(input = "Ho ho ho, merry Christmas.",
    voice = "FatherChristmas",
    file = "~/Sync/santa.mp3",
    backend = "chatterbox", source = "api")
```

"Voice reference file not found" means the call resolved to a backend or
source that cannot see the server's voice library. Name them.

## Long text is truncated silently

Chatterbox accepts one request of roughly 2000 to 3000 characters. A longer
`input` returns a tiny MP3 (under 1 KB) with no audible content and no
error. For anything longer than a paragraph: split on paragraph boundaries,
pack paragraphs into chunks, render each chunk, concatenate.

```r
library(tts.api)
set_tts_base("http://<tts-host>:7810")
voice_ensure("FatherChristmas")

text <- paste(readLines("~/cornball_ai/content/posts/some-post.md", warn = FALSE),
              collapse = "\n")

# Split on blank lines so paragraph boundaries stay clean.
paragraphs <- unlist(strsplit(text, "\n{2,}", perl = TRUE))

# Pack paragraphs into chunks of up to ~1800 characters each.
max_chars <- 1800L
chunks <- character()
cur <- ""
for (p in paragraphs) {
    if (!nzchar(trimws(p))) next
    if (nchar(cur) + nchar(p) + 2L > max_chars) {
        chunks <- c(chunks, cur)
        cur <- p
    } else {
        cur <- if (nzchar(cur)) paste(cur, p, sep = "\n\n") else p
    }
}
if (nzchar(cur)) chunks <- c(chunks, cur)

# Render each chunk.
parts <- file.path(tempdir(), sprintf("part_%03d.mp3", seq_along(chunks)))
for (i in seq_along(chunks)) {
    tts(input = chunks[i], voice = "FatherChristmas", file = parts[i],
        backend = "chatterbox", source = "api")
}

# Concatenate with ffmpeg, no re-encode.
listfile <- tempfile(fileext = ".txt")
writeLines(sprintf("file '%s'", parts), listfile)
out <- "~/Sync/full-audio.mp3"
system2("ffmpeg", c("-y", "-f", "concat", "-safe", "0",
                    "-i", listfile, "-c", "copy", out))
```

1800 is conservative. Push toward 2500 for fewer chunks; back off to 1200
if a chunk still truncates. Check every part's size before concatenating: a
part under 1 KB is a truncated chunk, not a short one.

## Strip markdown first

Raw markdown sounds bad. Before chunking:

```r
lines <- readLines(path, warn = FALSE)

# YAML frontmatter.
yaml_end <- grep("^---\\s*$", lines)
if (length(yaml_end) >= 2L) lines <- lines[(yaml_end[2L] + 1L):length(lines)]
text <- paste(lines, collapse = "\n")

# Code fences entirely.
text <- gsub("```[^\n]*\n[\\s\\S]*?```", " ", text, perl = TRUE)

# Header hashes, keep the text.
text <- gsub("^#+\\s+", "", text, perl = TRUE)
text <- gsub("\\n#+\\s+", "\n\n", text, perl = TRUE)

# Markdown links: link text only.
text <- gsub("\\[([^\\]]+)\\]\\([^\\)]+\\)", "\\1", text, perl = TRUE)

# Bold, italic, inline code.
text <- gsub("\\*\\*([^*]+)\\*\\*", "\\1", text, perl = TRUE)
text <- gsub("\\*([^*]+)\\*", "\\1", text, perl = TRUE)
text <- gsub("`([^`]+)`", "\\1", text, perl = TRUE)
```

## Where output goes

Write clips to `~/Sync/` on a headless host so they can be reviewed from
another device. Voice reference clips live in `~/.cornball/voices/`;
`voice_library()` lists them and `voice_ensure()` uploads one to the server
on first use. Short (5 to 30 s) clean speech clones best.

## Gotchas

- **Tiny or empty MP3**: silent truncation. Chunk, and check part sizes.
- **"API base URL not set"**: call `set_tts_base("http://<tts-host>:7810")`
  or set `options(tts.api_base = ...)`.
- **"Server unreachable"**: the container is down or the hostname is not
  resolving; `tts_health()` first.
- The concrete server hostname belongs in the user's shell environment or
  project instructions, not in this skill.
