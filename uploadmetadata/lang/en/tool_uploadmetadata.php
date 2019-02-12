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
 * Strings for component 'tool_uploadmetadata', language 'en'
 *
 * @package    tool_uploadmetadata
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

$string['csvcomment']            = '{$a->line} {$a->linenum} [Comment]: {$a->skipped}.';
$string['csvfile']               = 'Tab-delimited file';
$string['csvline']               = 'Tab-delimited file row:';
$string['csvfile_help']          = 'The format of the tab-delimited file must be as follows:

* First line must be:  {$a->name_header}
* Second line must be: {$a->col_header}
* Each line of the file after the first two must contain one record.
* Each record is a series of data items in a fixed order separated by tabs.
* The required fields are: {$a->col_names}';

$string['invalid_name_header']  = 'Invalid file! First line must be: {$a->name_header}';
$string['invalid_col_header']   = 'Invalid file! Second line must be: {$a->col_header}';

$string['fieldscannotbeblank']   = '{$a->line} {$a->linenum} [{$a->oplabel}]: Fields cannot be blank: block ({$a->blockname}), course ($a->coursename), region ($a->region), weight ($a->weight). {$a->skipped}.';
$string['heading']               = 'Upload presentation metadata from a tab-delimited file';
$string['pluginname']            = 'Upload presentation metadata';
$string['pluginname_help']       = 'Upload presentation metadata from a tab-delimited file';
$string['privacy:metadata']      = 'The upload metadata administration tool does not store personal data.';

$string['toofewcols']            = '{$a->line} {$a->linenum} : Too few columns, expecting {$a->col_count}, found {$a-cols}. {$a->skipped}.';
$string['toomanycols']           = '{$a->line} {$a->linenum} : Too many columns, expecting {$a->col_count}, found {$a-cols}. {$a->skipped}.';
$string['upload_success']        = 'Result: Added {$a->added} metadata pages and updated {$a->updated} metadata pages.';
$string['upload_errors']    	 = 'Warning: {$a} Errors in metadata pages tab-delimited file!';
$string['activity_metadata_updated']      = 'Presentation and video activity metadata updated.';
$string['public_metadata_updated']        = 'Public metadata pages updated.';
$string['presentation_index_updated']     = 'Presentation index updated.';