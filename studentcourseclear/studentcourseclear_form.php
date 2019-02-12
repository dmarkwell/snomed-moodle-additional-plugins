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
class studentcourseclear_form extends moodleform {
    public function definition() {
        global $CFG;
		global $SESSION;
        $mform = $this->_form; // Don't forget the underscore! 
		$mform->addElement('header','course_info',get_string('course_info', 'tool_studentcourseclear'));
        
		$mform->addElement('text', 'coursename', get_string('coursename', 'tool_studentcourseclear')); // Add elements to your form
        $mform->setType('coursename', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('coursename',get_string('required'),'required');		
		$mform->setDefault('coursename',$SESSION->fdata->coursename);
		
		$mform->addElement('header','student_info',get_string('student_info', 'tool_studentcourseclear'));
		
		$mform->addElement('text', 'lastname', get_string('lastname')); // Add elements to your form
        $mform->setType('lastname', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('lastname',get_string('required'),'required');
		$mform->setDefault('lastname',$SESSION->fdata->lastname);
		
        $mform->addElement('text', 'email', get_string('email')); // Add elements to your form
        $mform->setType('email', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('email',get_string('required'),'required');
		$mform->addRule('email',get_string('invalidemail'),'email');
		$mform->setDefault('email',$SESSION->fdata->email);
		//
        $mform->addElement('checkbox', 'confirm', get_string('confirm_info_button', 'tool_studentcourseclear'));

		$this->add_action_buttons(true, get_string('ok_button', 'tool_studentcourseclear'));
		
    }
	    //Custom validation should be added here
    function validation($data, $files) {

        return;
    }
}
