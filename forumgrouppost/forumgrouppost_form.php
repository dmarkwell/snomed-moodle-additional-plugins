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
 * @package forumgrouppost
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
class forumgrouppost_form extends moodleform {
    public function definition() {
        global $CFG;
		global $SESSION;
        $mform = $this->_form; // Don't forget the underscore! 

		$mform->addElement('text', 'coursename', get_string('coursename', 'tool_forumgrouppost')); // Add elements to your form
        $mform->setType('coursename', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('coursename',get_string('required'),'required');		
		$mform->setDefault('coursename',$SESSION->fdata->coursename);
		
		$mform->addElement('text', 'courseid', get_string('courseid', 'tool_forumgrouppost')); // Add elements to your form
        $mform->setType('courseid', PARAM_INT);                   //Set type of element
		$mform->addRule('courseid',get_string('required'),'required');		
		$mform->setDefault('courseid',$SESSION->fdata->courseid);
		
		$mform->addElement('text', 'forumname', get_string('forumname', 'tool_forumgrouppost')); // Add elements to your form
        $mform->setType('forumname', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('forumname',get_string('required'),'required');		
		$mform->setDefault('forumname',$SESSION->fdata->forumname);
		
		$mform->addElement('text', 'forumid', get_string('forumid', 'tool_forumgrouppost')); // Add elements to your form
        $mform->setType('forumid', PARAM_INT);                   //Set type of element
		$mform->addRule('forumid',get_string('required'),'required');		
		$mform->setDefault('forumid',$SESSION->fdata->forumid);
		
		
		$mform->addElement('text', 'pagename', get_string('pagename', 'tool_forumgrouppost')); // Add elements to your form
        $mform->setType('pagename', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('pagename',get_string('required'),'required');
		$mform->setDefault('pagename',$SESSION->fdata->pagename);
		
		$mform->addElement('text', 'pageid', get_string('pageid', 'tool_forumgrouppost')); // Add elements to your form
        $mform->setType('pageid', PARAM_INT);                   //Set type of element
		$mform->addRule('pageid',get_string('required'),'required');		
		$mform->setDefault('pageid',$SESSION->fdata->pageid);              //Set type of element
		
		$mform->addElement('text', 'intake', get_string('intake', 'tool_forumgrouppost')); // Add elements to your form
        $mform->setType('intake', PARAM_NOTAGS);                   //Set type of element
		$mform->addRule('intake',get_string('required'),'required');
		$mform->addRule('intake',get_string('regexp_yyyymm', 'tool_forumgrouppost'),'regex','/[0-9]{6}/');
		$mform->setDefault('intake',$SESSION->fdata->intake);
		
		$mform->hardFreeze('coursename');
		$mform->hardFreeze('courseid');
		$mform->hardFreeze('forumname');
		$mform->hardFreeze('forumid');
		$mform->hardFreeze('pagename');
		$mform->hardFreeze('pageid');
		
        $mform->addElement('checkbox', 'confirm', get_string('confirm_info_button', 'tool_forumgrouppost'));

		$this->add_action_buttons(true, get_string('ok_button', 'tool_forumgrouppost'));
		
    }
	    //Custom validation should be added here
    function validation($data, $files) {

        return;
    }
}
