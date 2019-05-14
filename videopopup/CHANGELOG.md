# Change Log
All notable changes to this project will be documented in this file.


## [0.1.0] - 2019-01-03
### Added
- Initial test version.
- Developed in outline.

## [1.0.0] - 2019-01-11
### Added
- First release version.

## [1.0.1] - 2019-02-13
### Added
- Minor update.

## [1.1.0] - 2019-05-18
### Added
- Added call parameter $mode to change default behaviour on access:
- Previous version always redirected parent window to course-section.
- Revised version has two options:
- a) Default does NOT redirect parent window
- b) With added URL parameter &mode=course redirected parent window to course-section.
- RATIONALE: Calls to videos that are NOT from video metadata should not redirect the parent window (e.g. from a link within a SCORM presentation). Calls from course metadata can be automatically updated to added the required mode parameter enabling continuation of current process.