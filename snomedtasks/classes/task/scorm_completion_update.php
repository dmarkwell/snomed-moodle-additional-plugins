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
 * Scheduled task for syncing scormc roles.
 *
 * @package    tool_scormcomplete
 * @copyright  2017 SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
namespace tool_snomedtasks\task;

use core\task\scheduled_task;

/**
 * Scheduled task for syncing scorm roles.
 *
 * @copyright  2017 SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class scorm_completion_update extends scheduled_task {

    /**
     * Get name.
     * @return string
     */
    public function get_name() {
        // Shown in admin screens.
        return get_string('scorm_completion_update','tool_snomedtasks');
    }

    /**
     * Execute.
     */
public function execute() {
		global $DB;

    	mtrace("\n  Processing Recent SCORM Viewing Data (since last run) ...", '');

    	$DB->execute('CALL ScormCompletionUpdate("recent")');

    	mtrace("\n  Processing of Recent SCORM Viewing Data Completed.", '');
		
    	return true;
    }
}
