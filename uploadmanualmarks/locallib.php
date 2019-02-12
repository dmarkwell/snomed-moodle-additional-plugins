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
 * Library of functions for uploading a course block settings CSV file.
 *
 * @package    tool_uploadmanualmarks
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;

require_once($CFG->libdir.'/blocklib.php');

/**
 * Validates and processes files for uploading marks from a CSV file
 *
 * @copyright   2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class tool_uploadmanualmarks_handler {

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
     * @throws uploadmanualmarks_exception if the file can't be opened for reading
     * @return object File handler
     */
    public function open_file() {
        global $USER;
        if (is_file($this->filename)) {
            if (!$file = fopen($this->filename, 'r')) {
                throw new uploadmanualmarks_exception('cannotreadfile', $this->filename, 500);
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
                throw new uploadmanualmarks_exception('cannotreadfile', $this->filename, 500);
            }
            $file = reset($files);
            if (!$file = $file->get_content_file_handle()) {
                throw new uploadmanualmarks_exception('cannotreadfile', $this->filename, 500);
            }
        }
        return $file;
    }

    /**
     * Processes the file to handle the marking uploads
     *
     * Opens the file, loops through each row. 
     * Checks the values in each column.
     * If all is well adds the new mark.
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
        $strings->line = get_string('csvline', 'tool_uploadmanualmarks');
        $strings->skipped = get_string('skipped');
		$uploaded = 0;
		$duplicates = 0;
		$quizid = 0;
            // Loop through each row of the file.
        while ($csvrow = fgetcsv($file)) {
			$line++;
			if ($line < 3 ) {
				if ($line == 1 && !$csvrow == '#updatemanualmarks' ) {
					throw new uploadmanualmarks_exception('invalid_name_header', $this->filename, 500);
				}
				if ($line == 2 && !$csvrow == 'quizid,attemptid,seqnum,maxmark,mark' ) {
					throw new uploadmanualmarks_exception('invalid_col_header', $this->filename, 500);
				}
				continue;
			}
            // Check for the correct number of columns.
            if (count($csvrow) < 5) {
                $report[] = get_string('toofewcols', 'tool_uploadmanualmarks', $strings);
                continue;
            }
            if (count($csvrow) > 5) {
                $report[] = get_string('toomanycols', 'tool_uploadmanualmarks', $strings);
                continue;
            }			
            $strings->linenum = $line;

            // Read in clean parameters to prevent sql injection.
            $quizid = clean_param($csvrow[0], PARAM_INT);
            $attemptid = clean_param($csvrow[1], PARAM_INT);
            $seqnum = clean_param($csvrow[2], PARAM_INT);
            $maxmark = clean_param($csvrow[3], PARAM_FLOAT);
            $mark = clean_param($csvrow[4], PARAM_FLOAT);

            // Prepare reporting message strings.
            $strings->quizid = $quizid;
            $strings->attemptid = $attemptid;
            $strings->seqnum = $seqnum;
            $strings->maxmark = $maxmark;
            $strings->mark = $mark;
			
			// Call AddAttemptResult - note the quizid is not used here but at end of loop
			try {
				$DB->execute("CALL AddAttemptResult({$attemptid},{$seqnum},{$maxmark},{$mark})");
				$uploaded++;
			}
			catch (Exception $e) {
				$duplicates++;
			}
        }
        fclose($file);
		if ($duplicates > 0) {
			echo get_string('duplicate_records', 'tool_uploadmanualmarks',$duplicates).'<br/>';
		}
		if ($uploaded > 0 && $quizid > 0) {
			// Call AddedAttemptsRegrade - to apply the new attempts to the gradebook entry
			echo get_string('uploaded_marks', 'tool_uploadmanualmarks',$uploaded).'<br/>';
			$DB->execute("CALL AddedAttemptsRegrade({$quizid})");
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
class uploadmanualmarks_exception extends moodle_exception {

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
        parent::__construct($errorcode, 'tool_uploadmanualmarks', '', $a);
        $this->http = $http;
    }
}
