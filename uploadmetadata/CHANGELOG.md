# Change Log
All notable changes to this project will be documented in this file.


## [0.1.0] - 2018-12-11
### Added
- Initial beta release.
- Based on upload blocksettings with revisions to fit purpose.

## [1.0.0] - 2018-12-12
### Updated
- Initial stable release.
- Tested and available to team.


## [1.1.0] - 2018-12-17
### Updated
- Minor update.
- Separately calls and report on
- 1. UpdateMetadata() - which applies the uploaded metadata to presentation and video activities.
- 2. UpdatePublicMetadataPages() - which applies the uploaded metadata to public accessible pages.
- 3. UpdatePresentationIndex() - which creates the public pages listing presentations.

## [1.1.1] - 2018-12-28
### Updated
- Minor update.
- Added mode=update parameter to index form to trigger UpdateMetadata() to run.
- This is useful when needing to apply metadata to newly added instances of a presentation or video. 