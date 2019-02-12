<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Strings for component 'tool_uploadschedulerappts', language 'en'
 *
 * @package    tool_uploadschedulerappts
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

$string['csvcomment']            = '{$a->line} {$a->linenum} [Comment]: {$a->skipped}.';
$string['csvfile']               = 'CSV file';
$string['csvline']               = 'CSV file row:';
$string['csvfile_help']          = 'The format of the CSV file must be as follows:

* First line must be:  #uploadschedulerappts
* Second line must be: schedulerid,starttime,duration,tutor,timeanddateUrl,timeanddateText,webinarUrl,exclusivity
* Each line of the file after the first two must contain one record.
* Each record is a series of data items in a fixed order separated by commas.
* The required fields are schedulerid, starttime, duration, tutor, timeanddateUrl, timeanddateText, webinarUrl, exclusivity.';

$string['invalid_name_header']  = 'Invalid file! First line must be: #uploadschedulerappts';
$string['invalid_col_header']   = 'Invalid file! Second line must be: schedulerid,starttime,duration,tutor,timeanddateUrl,timeanddateText,webinarUrl,exclusivity';

$string['fieldscannotbeblank']   = '{$a->line} {$a->linenum} [{$a->oplabel}]: Fields cannot be blank';
$string['heading']               = 'Upload scheduler appt slots from a CSV file';
$string['pluginname']            = 'Upload scheduler appts';
$string['pluginname_help']       = 'Upload scheduler appts creates sheduler slots from a CSV file. It does not create individual student appointement.';
$string['webinarurl_title']		 = 'Webinar access URL';
$string['privacy:metadata']      = 'The upload scheduler appts administration tool does not store personal data. It only creates slots linked to tutors - no student data stored.';
$string['toofewcols']            = '{$a->line} {$a->linenum} [{$a->oplabel}]: Too few columns, expecting 8. {$a->skipped}.';
$string['toomanycols']           = '{$a->line} {$a->linenum} [{$a->oplabel}]: Too many columns, expecting 8. {$a->skipped}.';
$string['upload_complete']       = 'Result: {$a} Schedules uploaded successfully.';
$string['upload_errors']   		 = 'Warning: Errors in schedule upload. {$a} rows not uploaded.';
