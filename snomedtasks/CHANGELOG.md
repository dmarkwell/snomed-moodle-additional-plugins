# Change Log for SNOMED Scheduled Tasks Cron Plugin
All notable changes to this project will be documented in this file.

## [0.1.0] - 2018-12-17
### Created
Created snomedtasks based on and replacing datasync and scorm completion as a more flexible inclusive solution.

## [1.0.0] - 2018-12-20
### Created
First stable release version produced following extensive updates, fixes and enhancements.

Supports the following tasks scheduled tasks:

- communication_preference_update
- management_max_update
- presentation_history_report
- presentation_history_update
- quiz_attempt_export
- scorm_completion_update
- scorm_completion_update_full
- webinar_attendee_update

## [1.0.3] - 2018-12-21
### Created
Minor updates tested.

## [1.0.4] - 2019-01-02
### Created
Added task for
- survey_to_profile_update

## [1.0.5] - 2019-01-30
### Created
Corrected the parameter value for 'recent' updates in: scorm_completion_update
In practice the error had no effect as all values except 'full' result in 'recent' so this was just a tidy up rather than a substantive change.
