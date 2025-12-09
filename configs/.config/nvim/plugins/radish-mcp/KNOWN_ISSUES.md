# Known Issues

## Terminal Line Wrapping

**Issue:** Ghost mode pattern matching is affected by terminal line wrapping.

**Symptom:** Files with long paths may have truncated filenames in the ghost window.
Example: `LIVE_TEST.md` appears as `LIVE_TEST.m` because the terminal wraps the line.

**Root Cause:** When the terminal output line is longer than the terminal width, it gets wrapped. The `nvim_buf_get_lines()` API returns lines as they appear visually, so a wrapped line becomes multiple lines. The pattern only matches the first part before the wrap.

**Workaround:**
1. Increase terminal width to avoid wrapping
2. Use shorter file paths
3. Match on the beginning of the filename only

**Potential Fix:**
- Read from the actual process output instead of the terminal buffer
- Join wrapped lines based on continuation detection
- Use a different pattern that's less affected by wrapping

## Current Status
This is a known limitation of monitoring terminal buffers. The feature works correctly when lines don't wrap.
