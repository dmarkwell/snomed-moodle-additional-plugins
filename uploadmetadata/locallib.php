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
 * Library of functions for uploading a presentation metadata CSV file.
 *
 * @package    tool_uploadmetadata
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;

/**
 * Validates and processes files for uploading presentation metadata CSV file
 *
 * @copyright   2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class tool_uploadmetadata_handler {

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
     * @throws uploadmetadata_exception if the file can't be opened for reading
     * @return object File handler
     */
    public function open_file() {
        global $USER;
        if (is_file($this->filename)) {
            if (!$file = fopen($this->filename, 'r')) {
                throw new uploadmetadata_exception('cannotreadfile', $this->filename, 500);
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
                throw new uploadmetadata_exception('cannotreadfile', $this->filename, 500);
            }
            $file = reset($files);
            if (!$file = $file->get_content_file_handle()) {
                throw new uploadmetadata_exception('cannotreadfile', $this->filename, 500);
            }
        }
        return $file;
    }

    /**
     * Processes the file to handle the presentation metadata uploads
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
		$strings->filename = $this->filename;
        $strings->line = get_string('csvline', 'tool_uploadmetadata');
        $strings->skipped = get_string('skipped');
		// Add file specific data
		$strings->name_header = '#uploadmetadata';
		$strings->col_header = "filekey\tfileref\ttitle\ttable";
		$strings->col_count =  4;
		$strings->col_names = str_replace("\t",', ',$strings->col_header);


		// Prepare result message strings.
		$dbresult = new stdClass;
		$dbresult->added = 0;
		$dbresult->updated = 0;
		$dbresult->errors = 0;
		
        // Loop through each row of the file.
        while ($csvrow = fgetcsv($file,0,"\t","'")) {
			$line++;
			// Special handling for the first two rows
			if ($line < 3 ) {
				if ($line == 1 && !$csvrow == $strings->name_header ) {
					throw new uploadmetadata_exception('invalid_name_header', $strings, 500);
				}
				if ($line == 2 && !$csvrow == $strings->col_header ) {
					throw new uploadmetadata_exception('invalid_col_header', $strings, 500);
				}
				continue;
			}
			
			// General handling for third and subsequent rows
            $strings->linenum = $line;
            $strings->cols = (count($csvrow));
			// Check for the correct number of columns.
            if (count($csvrow) < $strings->col_count) {
                $report[] = get_string('toofewcols', 'tool_uploadmetadata', $strings);
                continue;
            }
            if (count($csvrow) > $strings->col_count) {
                $report[] = get_string('toomanycols', 'tool_uploadmetadata', $strings);
				continue;
            }	
            
			// Read in clean parameters to prevent sql injection.
			$filekey= clean_param($csvrow[0], PARAM_TEXT);
            $fileref = clean_param($csvrow[1], PARAM_TEXT);
			$title = clean_param($csvrow[2], PARAM_TEXT);
            $metadata = clean_param($csvrow[3], PARAM_RAW);
			
            // Prepare reporting message strings.
            $strings->filekey = $filekey;
            $strings->fileref = $fileref;
            $strings->title = $title;
            $strings->metadata = $metadata;
			
			// Prepare the record to be saved 
			$record = new stdClass();
			$record->filekey = $filekey;
			$record->fileref = $fileref;
			$record->title = $title;
			$record->metadata = $metadata;
			$record->timemodified = time();
			$record_existed = 0;
			
			// Delete existing item with filekey (if any)
			try {
				if ($DB->record_exists('elp_metadata', array('filekey' => $filekey))) {
					$DB->delete_records('elp_metadata', array('filekey' => $filekey)) ;
					$record_existed = 1; }
			}
			catch (Exception $e) {
				// In case of an error with the record exists and delete calls.
				
			}
			
			// Insert the uploaded item. 
			
			// $DB->insert_record('elp_metadata',$record);
			
			try {
				$DB->insert_record('elp_metadata',$record);
				if ($record_existed==1) {
					// Previous item with same filekey existed and was deleted so this is an update.
					$dbresult->updated++;
				}
				else {
					// No previous item with same filekey so this is an add.
					$dbresult->added++;
				}
			}
			catch (Exception $e) {
				// Insert failed so this is an error
				echo "Error in line: {$strings->linenum}</br>";
				$dbresult->errors++;
			}

        }
        fclose($file);
		
		// Either display an error message or a success message
		if ($dbresult->errors > 0) {
			echo get_string('upload_errors', 'tool_uploadmetadata',$dbresult->errors).'<br/>';
		}
		elseif ($dbresult->added > 0 || $dbresult->updated > 0) {
			echo get_string('upload_success', 'tool_uploadmetadata',$dbresult).'<br/><br/>';
			// If successful then Call UpdateMetadata() to apply new metadata to relevant activities
			update_metadata();
			$DB->execute("CALL UpdatePublicMetadataPages()");
			echo get_string('public_metadata_updated','tool_uploadmetadata').'<br/>';
			$DB->execute("CALL UpdatePresentationIndex()");
			echo get_string('presentation_index_updated','tool_uploadmetadata').'<br/>';
			
				
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
class uploadmetadata_exception extends moodle_exception {

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
        parent::__construct($errorcode, 'tool_uploadmetadata', '', $a);
        $this->http = $http;
    }
}

function update_metadata() {
	global $DB;
	$DB->execute("CALL UpdateMetadata()");
	echo get_string('activity_metadata_updated','tool_uploadmetadata').'<br/>';
}
