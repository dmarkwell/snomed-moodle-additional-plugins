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
 * @package    tool_questionstoquiz
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;

global $DB, $CFG, $SESSION;

/**
 * Validates and data entered in a form
 *
 * @copyright   2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

class tool_questionstoquiz_handler {


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
		//$quizid = $DB->get_field('quiz', 'id', array('name' => $data->quizname), IGNORE_MISSING);
		$quizid = $data->quizid;
		if (!$quizid) {
			// Invalid quiz name
			echo div_color(get_string('invalid_quiz', 'tool_questionstoquiz',$data),'red');
			$fail = 1;
			$data->quizid = 'No ID';
		}
		else {
			$quizquestcount = $DB->count_records_sql('Select COUNT(`id`) FROM `mdl_quiz_slots` WHERE `quizid`='.$quizid);
			if ($quizquestcount>0) {
				// Invalid user identifier
				echo div_color(get_string('quiz_has_questions', 'tool_questionstoquiz',$data),'red');
				$fail = 1;
			}
		}
		
		//$categoryid = $DB->get_field('question_categories', 'id', array('name' => $data->categoryname), IGNORE_MISSING);
		$categoryid =$data->categoryid;
		if (!$categoryid) {
			// Invalid user identifier
			echo div_color(get_string('invalid_category', 'tool_questionstoquiz',$data),'red');
			$fail = 1;
			$data->categoryid = 'No ID';
			$data->subcatcount = 0;
		}
		else {
			//$data->categoryid = $categoryid;
			$subcatcount = $DB->count_records_sql('Select COUNT(`id`) FROM `mdl_question_categories` WHERE `name` regexp "[0-9]$" AND `parent` = '.$categoryid);
			if ($subcatcount<2) {
				// Invalid user identifier
				echo div_color(get_string('too_few_subcategories', 'tool_questionstoquiz',$data),'red');
				$fail = 1;
			}
			$data->subcatcount = $subcatcount;
		}

		if (!$data->confirm && !$fail) {
			// Confirm not checked so do not process just show test message.
			echo div_color(get_string('validation_message', 'tool_questionstoquiz',$data),'purple').'<br/>';
			$fail = 1;
		}	
		
		if (!$fail) {
	    	echo get_string('adding_questions', 'tool_questionstoquiz',$data);
			$time = new DateTime();
			$timestamp=$time->getTimestamp();
			// Note: $timestamp is provided as an argument to the function to minimze the risk of the procedure being called manually
	
	    	$DB->execute('CALL `QuestionsToQuiz`('.$quizid.','.$categoryid.','.$timestamp.')');
	
	    	echo get_string('actions_completed','tool_questionstoquiz').'<ul>';
			
			
			// Check the log file and display the actions taken
			
			$selcmd = 'SELECT `info`,`value3` FROM `mdl_elp_log` WHERE `task`="QuestionsToQuiz" AND `added`='.$timestamp;
	
			$rs = $DB->get_recordset_sql($selcmd);			
			foreach ($rs as $record) {
	    		// Display the info records
				echo '<li>'.$record->info."</li>";
			}
			$rs->close();
			
			echo div_color(get_string('completion_message', 'tool_questionstoquiz',$data),darkgreen).'<br/>';
		}
	// Display a link back to the form
	echo get_string('back_to_form','tool_questionstoquiz',questionstoquiz_url(''));
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
class questionstoquiz_exception extends moodle_exception {

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
        parent::__construct($errorcode, 'tool_questionstoquiz', '', $a);
        $this->http = $http;
    }
}

function questionstoquiz_url($relativeurl) {
	global $CFG;
    return $CFG->wwwroot.'/admin/tool/questionstoquiz/'.$relativeurl;
}

function get_icon_link($icon,$title,$link) {
    global $CFG, $OUTPUT;
	/* Options for $icon include: 
		show, hide, viewdetail, preview, add, edit, edit_menu, editstring, 
		up, down, right, left, move, copy, delete, restore, export,
		unlock, locked, lock, block, unblock, approve, 
		message, email, subscribed, unsubscribed, markasread, selected,
		collapsed, collapsed_rtl, sort, sort_asc, sort_desc, 
		assignroles, enrolusers, cohort, groups, removecontact, addcontact,
		calc, calc_off, switch_minus, switch_plus, switch_whole, portfolioadd
	*/
	 
	$imgedit = $OUTPUT->pix_icon('t/'.$icon, $title);
	return html_writer::tag('a', $imgedit,
            array('title' => $title,
				'href' => $CFG->wwwroot.$link));
}

function get_option_list($rs,$param_prefix)
{
	$text='<ul>';
	foreach ($rs as $record) {
		$text.='<li>'.page_linktext($record->name,$param_prefix.$record->id).'</li>';
	}
	$text.='</ul>';
	return $text;
}

function page_linktext($text,$params) {
	global $CFG;
    return '<a href="'.questionstoquiz_url('index.php'.$params).'">'.$text.'</a>';	
}

function table_td($content){
	return '<td width="33%" style="vertical-align: text-top;">'.$content.'</td>';
}
function table_th($content){
	return '<th width="33%" style="vertical-align: text-top;horizontal-align: text-center;">'.$content.'</th>';
}

function div_color($text,$color)
{
	return '<div style="color:'.$color.';">'.$text.'</div>';
}
