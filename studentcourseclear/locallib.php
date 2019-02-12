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
 * Library of functions for processing snomed test form data.
 *
 * @package    tool_studentcourseclear
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;

/**
 * Validates and data entered in a form
 *
 * @copyright   2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class tool_studentcourseclear_handler {

	/**
     * Processes the form data
     * Returns a report of successes and failures.
     *
     * @return string A report of successes and failures.
     */
    public function process($data) {
        global $DB, $CFG, $SESSION;
        $report = array();
		$fail = 0;
		$SESSION->fdata=$data;
		
		$courseid = $DB->get_field('course', 'id', array('shortname' => $data->coursename), IGNORE_MISSING);		
		if (!$courseid) {
			// Invalid course name
			echo div_color(get_string('invalid_course', 'tool_studentcourseclear',$data),'red');
			$fail = 1;
		}

		$userid = $DB->get_field('user', 'id', array('lastname' => $data->lastname, 'email' => $data->email), IGNORE_MISSING);
		if (!$userid) {
			// Invalid user identifier
			echo div_color(get_string('invalid_user', 'tool_studentcourseclear',$data),'red');
			$fail = 1;
		}
		
		if (!$data->confirm && !$fail) {
			// Confirm not checked so do not process just show test message.
			echo div_color(get_string('validation_message', 'tool_studentcourseclear',$data),'purple').'<br/>';
			$fail = 1;
		}	
		
		if (!$fail) {
	    	echo 'Clearing course data for selected student ...'.'<br/>';
			$time = new DateTime();
			$timestamp=$time->getTimestamp();
			// Note: $timestamp is provided as an argument to the function to minimze the risk of the procedure being called manually
	
	    	$DB->execute('CALL `ClearStudentCourseProgress`('.$courseid.','.$userid.','.$timestamp.')');
	
	    	echo get_string('actions_completed','tool_studentcourseclear').'<ul>';
			
			
			// Check the log file and display the actions taken
			
			$selcmd = 'SELECT `info`,`value3` FROM `mdl_elp_log` WHERE `task`="ClearStudentCourseProgress" AND `added`='.$timestamp;
			
			$cleared = 0;
	
			$rs = $DB->get_recordset_sql($selcmd);			
			foreach ($rs as $record) {
	    		// Display the info records and used value3 to determine if any records cleared
				echo '<li>'.$record->info."</li>";
				if ($record->value3>0)
					{
						$cleared = 1;
					}
			}
			$rs->close();
		
			if (!$cleared) 
			{
				echo '</ul>'.div_color(get_string('no_records_to_clear','tool_studentcourseclear'),'purple').'<br/>';
			}
			else
			{
				echo '</ul>'.get_string('scorm_sync','tool_studentcourseclear').'<br/>';
				
				// Synchronize SCORM viewing to remove any inconsistencies arising from clearance.
				$DB->execute('CALL ScormCompletionUpdate("full")');
				
				echo div_color(get_string('completion_message', 'tool_studentcourseclear',$data),darkgreen).'<br/>';
			}
		}
	// Display a link back to the form
	echo get_string('back_to_form','tool_studentcourseclear',studentcourseclear_url(''));
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
class studentcourseclear_exception extends moodle_exception {

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
        parent::__construct($errorcode, 'tool_studentcourseclear', '', $a);
        $this->http = $http;
    }
}


function studentcourseclear_url($relativeurl) {
    global $CFG;
    return $CFG->wwwroot.'/admin/tool/studentcourseclear/'.$relativeurl;
}

function div_color($text,$color)
{
	return '<div style="color:'.$color.';">'.$text.'</div>';
}
