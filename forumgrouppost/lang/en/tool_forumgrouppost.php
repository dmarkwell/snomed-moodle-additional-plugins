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
 * Strings for component 'tool_forumgrouppost', language 'en'
 *
 * @package    tool_forumgrouppost
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

$string['pluginname']			= 'Forum Post to Groups';
$string['heading']				= 'Forum Post to Groups';
$string['pageid']				= 'Page Id';
$string['pagename']   			= 'Page Title';
$string['forumid']				= 'Forum Id';
$string['forumname']			= 'Forum Name';
$string['courseid']				= 'Course Id';
$string['coursename']			= 'Course Name';
$string['intake']   			= 'Intake year and month as YYYYMM';
$string['regexp_yyyymm']   		= 'Must be a valid year and month in the form YYYYMM';

$string['confirm_info_button'] 	= 'Confirm post to groups';
$string['ok_button']			= 'Post to Groups';
$string['back_to_form']			= '<br/><a href="{$a}">Back to form</a><br/>';
$string['actions_completed'] 	= 'Message posted to groups';
$string['invalid_course']		= 'Error! Course {$a->coursename} not found!';
$string['invalid_intake']		= 'Error! No groups for intake: {$a->intake} to course: {$a->coursename}!';
$string['completion_message'] 	= 'Message page <i>{$a->pagename}</i> posted on forum <i>{$a->forumname}</i> to assignment groups in <i>{$a->intake}</i> of course: <i>{$a->coursename}</i><br/>';
$string['validation_message'] 	= 'Valid message page <i>{$a->pagename}</i> ready for posting on forum <i>{$a->forumname}</i> to assignment groups in <i>{$a->intake}</i> of course: <i>{$a->coursename}</i>.<br/>To complete the posting.<ol><li>Follow the "Back to Form" link</li><li>Check "Confirm post to groups" checkbox.</li><li>Click the "Post to Groups" button.<br/>';
$string['no_post']				= 'Error! No message posts were made. Please check the settings.';
