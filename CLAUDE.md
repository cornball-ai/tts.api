Here is a rewritten version of your specification, fully updated for the **OpenAI-compatible**, backend-agnostic package named **`ttsapi`**.
This is clean, concise, and ready for documentation or a design doc.

---

# **PACKAGE SPECIFICATION**

### **Package name:** `ttsapi`

### **Purpose:**

A minimal-dependency R client for **OpenAI-compatible Text-to-Speech APIs**, including:

* OpenAI `/v1/audio/speech`
* Local servers implementing the same spec (Chatterbox Blackwell, LM Studio, OpenWebUI, AnythingLLM, etc.)

### **Dependencies:**

**Imports:**

* `curl`
* `jsonlite`

**Suggests:**

* `stevedore` (optional Docker helpers)

**Excluded:**

* No ffmpeg
* No tidyverse/httr2
* No audio concatenation logic

---

# **1. Exported Functions**

These functions form the complete public interface:

---

## **1. `tts_set_api_base()`**

Sets the base URL for the API (OpenAI or local server).

Example:

```r
tts_set_api_base("http://localhost:4123")
```

Internally:

```r
options(ttsapi.api_base = "http://localhost:4123")
```

If unset and any API function is called, return a clear error.

---

## **2. `tts_set_api_key()`**

Sets the API key (used only for cloud services such as OpenAI).

Example:

```r
tts_set_api_key(Sys.getenv("OPENAI_API_KEY"))
```

Internally:

```r
options(ttsapi.api_key = "<key>")
```

Local servers typically ignore this field.

---

## **3. `tts_speech()`**

Implements:

```
POST /v1/audio/speech
```

Parameters (directly matching OpenAI spec):

* `input`
* `voice`
* `model` (optional; many local servers ignore this)
* `temperature`
* `speed`
* `audio_format` (filename extension determines preferred format)

Outputs:

* If `file = "output.mp3"` → writes binary audio to file
* If `file = NULL` → returns raw audio bytes (useful in Shiny)

Internals use only:

* `curl::curl_fetch_memory()`
* `jsonlite::toJSON()`
* `jsonlite::fromJSON()` (for parsing error responses)

---

## **4. `tts_health()`**

Checks whether the backend is reachable.

Possible endpoints:

* `/health`
* `/v1/status`
* (fallback: simple GET on `/`)

Returns a structured list:

```r
list(
  ok = TRUE/FALSE,
  status = "<message>",
  raw = <response>
)
```

Connection failure yields `ok = FALSE`.

---

## **5. `tts_voices()`**

Returns a list of available voices.

Mode A (API server provides endpoint):

```
GET /v1/audio/voices
```

Mode B (optional Docker and stevedore):

* Inspects `/voices` directory inside container
* Returns available voice filenames

If stevedore is not installed, return an informative message.

---

# **2. Internal Helpers (Unexported)**

These provide the foundation for the exported API.

---

### **`.tts_get_api_base()`**

Fetches the currently configured API base.
Errors if unset.

---

### **`.tts_get_api_key()`**

Returns API key (or NULL if not set).

---

### **`.tts_request()`**

Low-level HTTP wrapper around `curl::curl_fetch_memory()`:

Responsibilities:

* Construct URL
* Prepare headers (including `Authorization`, if key present)
* Send JSON bodies
* Parse API error responses cleanly
* Distinguish binary vs. JSON responses

---

### **`.tts_post_json()`**

Minimal helper to post JSON to an API endpoint.

---

# **3. Optional Docker Helper Layer (`Suggests: stevedore`)**

Not required for core operation.
Provides convenience functions:

---

### `tts_docker_start()`

Start a local TTS server container (e.g., Chatterbox Blackwell).

### `tts_docker_stop()`

Stop it.

### `tts_docker_logs()`

Retrieve logs.

### `tts_docker_list_voices()`

List voice files inside container volume mounts.

All Docker functions:

* Check for `stevedore`
* Error cleanly if not installed

---

# **4. Package Options**

Set in `.onLoad()`:

```r
options(
  ttsapi.api_base = NULL,
  ttsapi.api_key  = NULL,
  ttsapi.timeout  = 30
)
```

* `api_base` must be set by user
* `api_key` required only for OpenAI
* `timeout` applies to curl handle

---

# **5. Package Structure**

```
ttsapi/
  DESCRIPTION
  NAMESPACE
  R/
    tts_speech.R
    tts_health.R
    tts_voices.R
    tts_set_api_base.R
    tts_set_api_key.R
    internal_request.R
    internal_host.R
    docker_helpers.R
    zzz.R
  man/
  README.Rmd
  tests/
```

No audio processing, no chunking, no ffmpeg.

---

# **6. Error Handling Philosophy**

* **Never fail silently**
* Server errors with JSON → convert to human-friendly R errors
* If host is unset → error with instructions
* If connection fails → clear explanation
* If file writing fails → propagate system error with path context

Example:

```
Error in tts_speech(): API error (400): Invalid voice 'xyz'
```

---

# **7. Documentation & Examples**

The README should cover:

* Setting `ttsapi` host
* Adding OpenAI key (for cloud use)
* Calling `tts_speech()`
* Checking health
* Listing voices
* Using a local server (Chatterbox, LM Studio, OpenWebUI)
* Optional Docker usage via stevedore

---

# **8. Ready-to-Code**

Everything is now finalized:

* Name: **`ttsapi`**
* Scope: OpenAI-compatible TTS API client
* Architecture: minimal, portable
* Dependencies: minimal (curl + jsonlite)
* No chunking, no ffmpeg
* Optional Docker tooling
* Fully backend-agnostic

We can now scaffold the package and start dropping in skeletons or full implementations.

---

If you'd like next steps:

**A)** usethis scaffolding checklist for GitHub-first workflow
**B)** skeletons for all exported functions
**C)** full working functions
**D)** README template for OpenAI + local Chatterbox examples

Just say A/B/C/D.
