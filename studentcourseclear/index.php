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
 * @package    tool_studentcourseclear
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require_once(__DIR__.'/../../../config.php');
require_once($CFG->libdir.'/adminlib.php');

// Include our function library.
$pluginname = 'studentcourseclear';
require_once($CFG->dirroot.'/admin/tool/'.$pluginname.'/locallib.php');

// Globals.
global $CFG, $OUTPUT, $USER, $SITE, $PAGE;

// Ensure only administrators have access.
$homeurl = new moodle_url('/');
require_login();
if (!is_siteadmin()) {
    redirect($homeurl, "This feature is only available for site administrators.", 5);
}

// URL Parameters.
// There are none.

// Include form.
require_once(dirname(__FILE__).'/'.$pluginname.'_form.php');

// Heading ==========================================================.

$title = get_string('pluginname', 'tool_'.$pluginname);
$heading = get_string('heading', 'tool_'.$pluginname);
$url = new moodle_url('/admin/tool/'.$pluginname.'/');
if ($CFG->branch >= 25) { // Moodle 2.5+.
    $context = context_system::instance();
} else {
    $context = get_system_context();
}

$PAGE->set_pagelayout('admin');
$PAGE->set_url($url);
$PAGE->set_context($context);
$PAGE->set_title($title);
$PAGE->set_heading($heading);
admin_externalpage_setup('tool_'.$pluginname); // Sets the navbar & expands navmenu.

// Set up the form.
$form = new studentcourseclear_form(null, array());
if ($form->is_cancelled()) {
    redirect($homeurl);
}

echo $OUTPUT->header();

// Display or process the form.

$data = $form->get_data();
if (!$data) { // Display the form.

    echo $OUTPUT->heading($heading);

    // Display the form.
    $form->display();

} 
else {      // Process the form data.

    // Show form data for confirmation.
    $handler = new tool_studentcourseclear_handler();
    $report = $handler->process($data);
    echo $report;
	
}


// Footer.
echo $OUTPUT->footer();