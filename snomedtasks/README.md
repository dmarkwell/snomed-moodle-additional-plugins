# SNOMED Scheduled Tasks Cron Plugin #

Called by Moodle Scheduled Tasks - Updates various customized data as part of regular support for SNOMED International E-Learning business processes.

## Description ##
Supports completion regular updating of key files used by SNOMED International E-Learning.

### quiz_attempt_export ###
Export Quiz Attempts to Enable Access with Ad-Hoc Report

DB process: Call QuizAttemptExport("")
- Adds or updates data in table: mdl_elp_quiz_attempt_export

Notes:
- Attempt data can then be downloaded with the Ad-Hoc report
- Data then loaded into Google Sheet for marking
- After marking a CSV file is output 
- This file is uploaded with by the "Upload manual marks" plugin (tool_uploadmanualmarks)

### presentation_history_update
Update Data from which Presentation History Reports are generated

DB process: Call PresentationHistoryUpdate("")
- Adds or updates data in table: mdl_elp_fileupdates (raw data on each file update) and mdl_elp_fileupdate_summaries (summaries by month, quarter and year) 

Notes
- The mdl_elp_fileupdate_summaries table data is used to generate reports
- See presentation_history_report

### presentation_history_report
Publish Monthly Presentation History Reports

DB process: Call PresentationHistoryReport("")
- Creates or Updates pages (mdl_course_modules+mdl_page) showing newly created and changed presentations.

Notes
- Default process just processes the reports the current and previous month.
- The DB procedure can be called with YYYY, YYYYQn, YYYYMM to create or update annual, quartely or monthly reports for specific dates.

### management_max_update
Update table from which the Management Reports are generated

DB process: Call ManagementMaxUpdate("")
- Creates or Updates pages (mdl_elp_management_max) providing data required for extensive management reports.

Notes
- The actual reports are generated using Ad-Hoc reports.
- This process may take 30-60 seconds to run.
	
### scorm_completion_update
Update SCORM Completions - Recent updates 

DB process: Call ScormCompletionUpdate("recent")
- Uses presentation data to update cross reference information for all scorm activities (tables: mdl_elp_scorm_ref and mdl_elp_scorm_link)
- Uses completion and scorm activity data to update tracking data (table: mdl_elp_scorm_track)
- Uses the data in these tables to update completion data on other instances of the same scorm presentation in other course areas

Notes
- The "recent" parameter means this checks on completion and scorm activites are limited to changes since last run of the process.
- This takes only a few seconds and should be done regularly.


### scorm_completion_update_full
Update SCORM Completions - Full version

DB process: Call ScormCompletionUpdate("full")
- See scorm_completion_update

Notes
- The "full" parameter means this checks all completion and scorm activites.
- This takes longer the "recent" version and should only be done daily.
- The "full" version allows newly added instances of a presentation viewed earlier to be marked as complete.

	
### communication_preference_update
Update Student Communication Preferences

DB process: Call CommunicationPreferenceUpdate()
- Adds or removes users from cohorts (table: mdl_groups_members) related to acceptance of Policies and Communication preferences questionaire responses.
- Also add data to user customised profile fields (table: mdl_user_info_data)

Notes
- Addition to cohorts allows emailing to be correctly targetted based on preferences (in conformance with GDPR)
- Addition of data to profile fields allows preferences to be viewing the user record
	
### webinar_attendee_update
Update Webinar Attendee Group Membership

DB process: Call WebinarAttendeeUpdate
- Adds users who have been marked as attending (score>=1) a webinar to a webinar specific attendee group (table: mdl_groups_members)

Notes
- Allows restrictions to permit access to Webinar attendance/mark data from user grade view without allowing them to re-attend

### survey_to_profile_update
Update Profiles from Responses to Surveys

DB process: Call SurveyToProfileUpdate
- Adds users who have been marked as attending (score>=1) a webinar to a webinar specific attendee group (table: mdl_groups_members)

Notes
- Allows restrictions to permit access to Webinar attendance/mark data from user grade view without allowing them to re-attend


## Requirements ##

This plugin requires Moodle 2.9+ from https://moodle.org


## Installation and Update ##

Install the plugin, like any other plugin, to the following folder:

    /admin/tool/snomedtasks

See http://docs.moodle.org/33/en/Installing_plugins for details on installing Moodle plugins.

There are no special considerations required for updating the plugin.

### Uninstallation ###

Uninstall the plugin by going into the following:

__Administration &gt; Site administration &gt; Plugins &gt; Plugins overview__

...and click Uninstall. You may also need to manually delete the following folder:

    /admin/tool/snomedtasks

## Usage &amp; Settings ##

Configurable settings for this plugin include the ability to schedule tasks at different regular times.

## License ##

2018 David Markwell SNOMED International

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
