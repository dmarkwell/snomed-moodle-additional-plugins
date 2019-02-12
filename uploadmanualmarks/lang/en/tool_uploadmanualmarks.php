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
 * Strings for component 'tool_uploadmanualmarks', language 'en'
 *
 * @package    tool_uploadmanualmarks
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

$string['csvcomment']            = '{$a->line} {$a->linenum} [Comment]: {$a->skipped}.';
$string['csvfile']               = 'CSV file';
$string['csvline']               = 'CSV file row:';
$string['csvfile_help']          = 'The format of the CSV file must be as follows:

* First line must be:  #updatemanualmarks
* Second line must be: quizid,attemptid,seqnum,maxmark,mark
* Each line of the file after the first two must contain one record.
* Each record is a series of data items in a fixed order separated by commas.
* The required fields are quizid, attemptid, seqnum, maxmark, mark.';

$string['invalid_name_header']  = 'Invalid file! First line must be: #updatemanualmarks';
$string['invalid_col_header']   = 'Invalid file! Second line must be: quizid,attemptid,seqnum,maxmark,mark';

$string['fieldscannotbeblank']   = '{$a->line} {$a->linenum} [{$a->oplabel}]: Fields cannot be blank: block ({$a->blockname}), course ($a->coursename), region ($a->region), weight ($a->weight). {$a->skipped}.';
$string['heading']               = 'Upload manual marks from a CSV file';
$string['pluginname']            = 'Upload manual marks';
$string['pluginname_help']       = 'Upload manual marks for essay or text questions from a CSV file';
$string['privacy:metadata']      = 'The upload manual marks administration tool does not store personal data.';
$string['regionnotvalid']        = '{$a->line} {$a->linenum} [{$a->oplabel}]: Region "{$a->region}" is unknown. {$a->skipped}.';
$string['toofewcols']            = '{$a->line} {$a->linenum} [{$a->oplabel}]: Too few columns, expecting 5. {$a->skipped}.';
$string['toomanycols']           = '{$a->line} {$a->linenum} [{$a->oplabel}]: Too many columns, expecting 5. {$a->skipped}.';
$string['uploaded_marks']        = 'Result: {$a} Marks uploaded';
$string['duplicate_records']     = 'Warning: {$a} Duplicate mark items ignored. You are probably trying to re-upload of a previously uploaded file!';
