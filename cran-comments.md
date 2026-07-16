# cran-comments

## R CMD check results

0 errors | 0 warnings | 1 note

* New submission

## Test environments

* local Ubuntu 24.04, R 4.6.0
* GitHub Actions: ubuntu-latest, macos-latest
* local Windows, R 4.6.0
* local Windows, R-devel (4.7.0 pre-release)

## Reverse dependencies

None (new submission).

## Notes

The optional 'chatterbox' in-process backend is in Suggests and is only
exercised when chatterbox is installed; all such code is guarded with
requireNamespace(). The same applies to 'torch' (used only to free GPU
memory when clearing the chatterbox model cache).

Examples that require a running TTS server or a paid API key are wrapped
in \dontrun{}; option-setters and data accessors have runnable examples.
