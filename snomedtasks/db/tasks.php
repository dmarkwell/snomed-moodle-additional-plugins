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
 * Tasks definitions.
 *
 * @package    tool_snomedtasks
 * @copyright  2018 SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

$tasks = array(
	array(
        'classname' => 'tool_snomedtasks\task\communication_preference_update',
        'blocking' => 0,
        'minute' => 'R',
        'hour' => '*',
        'day' => '*',
        'dayofweek' => '*',
        'month' => '*'
    ),
	array(
        'classname' => 'tool_snomedtasks\task\management_max_update',
        'blocking' => 0,
        'minute' => 'R',
        'hour' => '18',
        'day' => '1,28,29,30,31',
        'dayofweek' => '0',
        'month' => '*'
    ),
	array(
        'classname' => 'tool_snomedtasks\task\presentation_history_report',
        'blocking' => 0,
        'minute' => 'R',
        'hour' => '2',
        'day' => '*',
        'dayofweek' => '*',
        'month' => '*'
    ),
	array(
        'classname' => 'tool_snomedtasks\task\presentation_history_update',
        'blocking' => 0,
        'minute' => 'R',
        'hour' => '1',
        'day' => '*',
        'dayofweek' => '*',
        'month' => '*'
    ),
	array(
        'classname' => 'tool_snomedtasks\task\quiz_attempt_export',
        'blocking' => 0,
        'minute' => 'R',
        'hour' => '4',
        'day' => '*',
        'dayofweek' => '*',
        'month' => '*'
    ),
	array(
        'classname' => 'tool_snomedtasks\task\scorm_completion_update',
        'blocking' => 0,
        'minute' => '*/5',
        'hour' => '*',
        'day' => '*',
        'dayofweek' => '*',
        'month' => '*'
    ),
	array(
        'classname' => 'tool_snomedtasks\task\scorm_completion_update_full',
        'blocking' => 0,
        'minute' => '8',
        'hour' => '0',
        'day' => '*',
        'dayofweek' => '*',
        'month' => '*'
    ),	array(
        'classname' => 'tool_snomedtasks\task\webinar_attendee_update',
        'blocking' => 0,
        'minute' => '10',
        'hour' => '0',
        'day' => '*',
        'dayofweek' => '*',
        'month' => '*'
    ),
	array(
        'classname' => 'tool_snomedtasks\task\survey_to_profile_update',
        'blocking' => 0,
        'minute' => 'R',
        'hour' => '1',
        'day' => '*',
        'dayofweek' => '*',
    ),
);
