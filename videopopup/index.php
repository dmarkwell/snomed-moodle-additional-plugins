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
 * Displays the form and processes the form submission.
 *
 * @package    local_videopopup
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require_once(__DIR__.'/../../config.php');

// require_once($CFG->libdir.'/adminlib.php');

// Include our function library.
$pluginname = 'videopopup';
require_once($CFG->dirroot.'/local/'.$pluginname.'/locallib.php');

// Globals.
global $CFG, $OUTPUT, $USER, $SITE, $PAGE;

// Ensure only logged in users have access.
$homeurl = new moodle_url('/');
require_login();


if (!isloggedin()) {
    redirect($homeurl, "This video is only available for logged in users.", 5);
}


// Define URL PARAMETERS
$videoid = optional_param('videoid', null, PARAM_NOTAGS);
$cmid = optional_param('cmid', '', PARAM_INT);  // Module Id

// Include form.
// NO FORM

// Heading ==========================================================.

$title = get_string('pluginname', 'local_'.$pluginname);
$heading = get_string('heading', 'local_'.$pluginname);
$url = new moodle_url('/local/'.$pluginname.'/');
if ($CFG->branch >= 25) { // Moodle 2.5+.
    $context = context_system::instance();
} else {
    $context = get_system_context();
}

// Requires the Module Id
if (!empty($cmid)) {
	if ($cmid != 'x') {
	    if (! $cm = get_coursemodule_from_id('page', $cmid, 0, true)) {
	        print_error('invalidcoursemodule');
	    }
	    if (! $course = $DB->get_record("course", array("id" => $cm->course))) {
	        print_error('coursemisconf');
	    }
	    if (! $page = $DB->get_record("page", array("id" => $cm->instance))) {
	        print_error('invalidcoursemodule');
	    }		
	}
} else {
    print_error('missingparameter');
}

// admin_externalpage_setup('local_'.$pluginname); // Sets the navbar & expands navmenu.

// Set up the form.
// NO FORM

// Display or process the form.
if ($course->format == 'singleactivity') {
    // Redirect students back to site home to avoid redirect loop.
    $exiturl = $CFG->wwwroot;
} else {
    // Redirect back to the correct section if one section per page is being used.
    $exiturl = "'".course_get_url($course, $cm->sectionnum)."'";
}
echo '<htm><head><title>'.$page->name.'</title></head>';
echo '<body onunload="window.opener.location.assign('.$exiturl.')";>';
echo '<iframe id="ytplayer" type="text/html" width="100%" height="98%" src="https://www.youtube.com/embed/'.$videoid.'?autoplay=1&enablejsapi=1&modestbranding=1&color=white&rel=0" frameborder="0" allowfullscreen>';