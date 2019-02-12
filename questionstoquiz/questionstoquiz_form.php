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
 * Form for viewing/entering parameters for a custom SQL report.
 *
 * @package student_course_restart
 * @copyright 2019 SNOMED International
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();


require_once($CFG->libdir . '/formslib.php');
require_once(dirname(__FILE__) . '/locallib.php');

/**
 * Form for viewing a custom SQL report.
 *
 * @copyright 2019 SNOMED International
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class questionstoquiz_form extends moodleform {
    public function definition() {
        global $CFG;
		global $SESSION;
        $mform = $this->_form; // Don't forget the underscore! 
		
		$mform->addElement('text', 'quizname', get_string('quizname', 'tool_questionstoquiz')); // Add elements to your form
        $mform->setType('quizname', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('quizname',get_string('required'),'required');		
		$mform->setDefault('quizname',$SESSION->fdata->quizname);
		
		$mform->addElement('text', 'quizid', get_string('quizid', 'tool_questionstoquiz')); // Add elements to your form
        $mform->setType('quizid', PARAM_INT);                   //Set type of element
		$mform->addRule('quizid',get_string('required'),'required');		
		$mform->setDefault('quizid',$SESSION->fdata->quizid);
		
		
		$mform->addElement('text', 'categoryname', get_string('categoryname')); // Add elements to your form
        $mform->setType('categoryname', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('categoryname',get_string('required'),'required');
		$mform->setDefault('categoryname',$SESSION->fdata->categoryname);
		
		$mform->addElement('text', 'categoryid', get_string('categoryid', 'tool_questionstoquiz')); // Add elements to your form
        $mform->setType('categoryid', PARAM_INT);                   //Set type of element
		$mform->addRule('categoryid',get_string('required'),'required');		
		$mform->setDefault('categoryid',$SESSION->fdata->categoryid);                   //Set type of element
		
		$mform->hardFreeze('categoryname');
		$mform->hardFreeze('quizname');
		$mform->hardFreeze('categoryid');
		$mform->hardFreeze('quizid');
        $mform->addElement('checkbox', 'confirm', get_string('confirm_info_button', 'tool_questionstoquiz'));

		$this->add_action_buttons(true, get_string('ok_button', 'tool_questionstoquiz'));
		
    }
	    //Custom validation should be added here
    function validation($data, $files) {

        return;
    }
}
