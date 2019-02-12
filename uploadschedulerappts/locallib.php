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
 * Library of functions for uploading a scheduler appointment slots CSV file.
 *
 * @package    tool_uploadschedulerappts
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;

/**
 * Validates and processes files for uploading scheduler appt slots from a CSV file
 *
 * @copyright   2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class tool_uploadschedulerappts_handler {

    /**
     * The ID of the file uploaded through the form
     *
     * @var string
     */
    private $filename;

    /**
     * Constructor, sets the filename
     *
     * @param string $filename
     */
    public function __construct($filename) {
        $this->filename = $filename;
    }

    /**
     * Attempts to open the file
     *
     * Open an uploaded file using the File API.
     * Return the file handler.
     *
     * @throws uploadschedulerappts_exception if the file can't be opened for reading
     * @return object File handler
     */
    public function open_file() {
        global $USER;
        if (is_file($this->filename)) {
            if (!$file = fopen($this->filename, 'r')) {
                throw new uploadschedulerappts_exception('cannotreadfile', $this->filename, 500);
            }
        } else {
            $fs = get_file_storage();
            $context = context_user::instance($USER->id);
            $files = $fs->get_area_files($context->id,
                                         'user',
                                         'draft',
                                         $this->filename,
                                         'id DESC',
                                         false);
            if (!$files) {
                throw new uploadschedulerappts_exception('cannotreadfile', $this->filename, 500);
            }
            $file = reset($files);
            if (!$file = $file->get_content_file_handle()) {
                throw new uploadschedulerappts_exception('cannotreadfile', $this->filename, 500);
            }
        }
        return $file;
    }

    /**
     * Processes the file to handle the schedule uploads
     *
     * Opens the file, loops through each row. 
     * Checks the values in each column.
     * If all is well adds the new schedule slot.
     * Returns a report of successes and failures.
     *
     * @see open_file()
     * @return string A report of successes and failures.
     */
    public function process() {
        global $DB, $CFG;
        $report = array();
		
        // Set a counter so we can report line numbers for errors.
        $line = 0;

        // Remember the last course, to avoid reloading all blocks on each line.
        $previouscourse = '';
        $courseblock = null;

        // Open the file.
        $file = $this->open_file();

        // Prepare reporting message strings.
        $strings = new stdClass;
        $strings->linenum = $line;
        $strings->line = get_string('csvline', 'tool_uploadschedulerappts');
        $strings->skipped = get_string('skipped');
		$uploaded = 0;
		$duplicates = 0;
        // Loop through each row of the file.
        while ($csvrow = fgetcsv($file)) {
			$line++;
			if ($line < 3 ) {
				if ($line == 1 && !$csvrow == '#uploadschedulerappts' ) {
					throw new uploadschedulerappts_exception('invalid_name_header', $this->filename, 500);
				}
				if ($line == 2 && !$csvrow == 'schedulerid,starttime,duration,tutor,timeanddateUrl,timeanddateText,webinarUrl,exclusivity' ) {
					throw new uploadschedulerappts_exception('invalid_col_header', $this->filename, 500);
				}
				continue;
			}
            // Check for the correct number of columns.
            if (count($csvrow) < 8) {
                $report[] = get_string('toofewcols', 'tool_uploadschedulerappts', $strings);
                continue;
            }
            if (count($csvrow) > 8) {
                $report[] = get_string('toomanycols', 'tool_uploadschedulerappts', $strings);
                continue;
            }	
			
            $strings->linenum = $line;
            // Read in clean parameters to prevent sql injection.
            $schedulerid = clean_param($csvrow[0], PARAM_TEXT);
            $starttime = clean_param($csvrow[1], PARAM_TEXT);
            $duration = clean_param($csvrow[2], PARAM_TEXT);
            $tutor = clean_param($csvrow[3], PARAM_TEXT);
            $timeanddateUrl = '"' . clean_param($csvrow[4], PARAM_URL) . '"';
			$timeanddateText = clean_param($csvrow[5], PARAM_TEXT);
			$webinarText = clean_param($csvrow[6], PARAM_URL);
			$webinarUrl='"' . $webinarText . '"';
			$exclusivity = clean_param($csvrow[7], PARAM_INT);
			$target=' target="_blank"';
			
			$webinar_title = get_string('webinarurl_title', 'tool_uploadschedulerappts');
			
            // Prepare reporting message strings.
            $strings->schedulerid = $schedulerid;
            $strings->starttime = $starttime;
            $strings->duration = $duration;
            $strings->tutor = $tutor;
            $strings->timeanddateUrl = $timeanddateUrl;
            $strings->timeanddateText = $timeanddateText;
            $strings->webinarUrl = $webinarUrl;
            $strings->exclusivity = $exclusivity;
			
			$record = new stdClass();
			$record->schedulerid = $schedulerid;
            $record->starttime = $starttime;
            $record->duration = $duration;			
            $record->teacherid = $tutor;
			$record->appointmentlocation = '';
			$record->reuse = 0;
			$record->timemodified = time();
			$record->notes = "<p><a href={$timeanddateUrl}{$target}>{$timeanddateText}</a></p><p>{$webinar_title}:</p><ul><li><a href={$webinarUrl}{$target}>{$webinarText}</a></li></ul>";	
			$record->notesformat = 1;	
			$record->exclusivity = $exclusivity;	
			$record->emaildate = 0;
			$record->hideuntil = time();
			try {
				$DB->insert_record('scheduler_slots',$record);
				$uploaded++;
			}
			catch (Exception $e) {
				 echo "Error in line: {$strings->linenum}</br>";
				$upload_errors++;
			}
        }
        fclose($file);
		if ($upload_errors > 0) {
			echo get_string('upload_errors', 'tool_uploadschedulerappts',$upload_errors).'<br/>';
		}
		if ($uploaded > 0) {
			echo get_string('upload_complete', 'tool_uploadschedulerappts',$uploaded).'<br/>';
		}
        return implode("<br/>", $report);
    }
}

/**
 * An exception for reporting errors
 *
 * Extends the moodle_exception with an http property, to store an HTTP error
 * code for responding to AJAX requests.
 *
 * @copyright   2010 Tauntons College, UK
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class uploadschedulerappts_exception extends moodle_exception {

    /**
     * Stores an HTTP error code
     *
     * @var int
     */
    public $http;

    /**
     * Constructor, creates the exeption from a string identifier, string
     * parameter and HTTP error code.
     *
     * @param string $errorcode
     * @param string $a
     * @param int $http
     */
    public function __construct($errorcode, $a = null, $http = 200) {
        parent::__construct($errorcode, 'tool_uploadschedulerappts', '', $a);
        $this->http = $http;
    }
}
