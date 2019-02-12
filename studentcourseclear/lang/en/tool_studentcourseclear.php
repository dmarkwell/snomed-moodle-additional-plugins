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
 * Strings for component 'tool_studentcourseclear', language 'en'
 *
 * @package    tool_studentcourseclear
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();


$string['pluginname']   		= 'Clear student course records';
$string['heading']      		= 'Delete Selected Course Records for a Student';
$string['student_info'] 		= 'Details of the Student';
$string['course_info'] 			= 'Details of the Course';
$string['coursename']   		= 'Course Name';
$string['confirm_info_button'] 	= 'Confirm student course record deletion';
$string['ok_button'] 			= 'Delete Course Progress';
$string['back_to_form'] 		= '<br/><a href="{$a}">Back to form</a><br/>';
$string['no_records_to_clear'] 	= 'No records to clear for this selection.';
$string['actions_completed'] 	=	'Actions completed to clear course progress data:';
$string['scorm_sync'] 			= 'Synchornizing SCORM completion status.';
$string['invalid_user']			= 'Error! User {$a->lastname} with email {$a->email} not found!';
$string['invalid_course']		= 'Error! Course {$a->coursename} not found!';
$string['completion_message'] 	= 'Deleted progress data for:<br/> Course: {$a->coursename} <br/> User: {$a->lastname} ({$a->email})<br/>';
$string['validation_message'] 	= 'Valid user and course.<br/>The "Confirm" checkbox must be checked to actually delete progress data for:<br/> Course: {$a->coursename} <br/> User: {$a->lastname} ({$a->email})<br/>';
