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
 * @package    tool_questionstoquiz
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require_once(__DIR__.'/../../../config.php');
require_once($CFG->libdir.'/adminlib.php');

// Include our function library.
$pluginname = 'questionstoquiz';
require_once($CFG->dirroot.'/admin/tool/'.$pluginname.'/locallib.php');

// Globals.
global $CFG, $OUTPUT, $USER, $SITE, $PAGE, $DB, $SESSION;

// Ensure only administrators have access.
$homeurl = new moodle_url('/');
require_login();
if (!is_siteadmin()) {
    redirect($homeurl, "This feature is only available for site administrators.", 5);
}

// Define URL PARAMETERS
// Selected courseid, quizid and question category id
$courseid = optional_param('courseid', null, PARAM_INT);
$quizid = optional_param('quizid', null, PARAM_INT);
$qcatid  = optional_param('qcatif', null, PARAM_INT);

// Include form.
require_once(dirname(__FILE__).'/'.$pluginname.'_form.php');

// Heading ==========================================================.

$title = get_string('pluginname', 'tool_'.$pluginname);
$heading = get_string('heading', 'tool_'.$pluginname);
$url = new moodle_url('/admin/tool/'.$pluginname.'/index.php');
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

$seldata=new stdClass;
$seldata->courselist = '';
$seldata->qcatlist = '';
$seldata->quizlist = '';
$seldata->courseid = '';
$seldata->qcatid = '';
$seldata->quizid = '';
$seldata->coursename = '';
$seldata->quizname = '';
$seldata->qcatname = '';



// TEMPORARY PLACE FOR THIS QUERY @id NEEDS TO BE COURSE ID

// Get the id and name of all courses that contain at least one quiz with no slots
$courseQuery="select distinct `c`.`id`,`c`.`shortname` `name`
from `mdl_course` `c`
 join `mdl_quiz` `q` on `q`.`course`=`c`.`id`
 left outer join `mdl_quiz_slots` `s` on `s`.`quizid`=`q`.`id`
where isnull(`s`.`id`) 
order by `c`.`shortname`;";

// Get all quizzes with no slots in a specified course
$quizQuery="select distinct `q`.`id`,`q`.`name`
from `mdl_quiz` `q`
 left outer join `mdl_quiz_slots` `s` on `s`.`quizid`=`q`.`id`
where isnull(`s`.`id`) and `q`.`course`=@courseid
order by `q`.`name`;";

// Get all questionCategories (with quiz level pattern) for a specified course
$questionCategoryQuery="SELECT `qc`.`id`,`qc`.`name` 
FROM `mdl_question_categories` `qc`
WHERE `qc`.`contextid` IN (SELECT `ctx`.`id` from `mdl_context` `ctx`
join `mdl_course` `c` ON `c`.`id`=`ctx`.`instanceid`
where `c`.`id`=@courseid and `ctx`.`contextlevel`=50
UNION
select `ctx`.`id` from `mdl_context` `ctx`
join `mdl_course_categories` `cc` ON `cc`.`id`=`ctx`.`instanceid` 
join `mdl_course` `c` ON `c`.`category`=`cc`.`id`
where `c`.`id`=@courseid and `ctx`.`contextlevel`=40)
AND BINARY `qc`.`name` regexp '^[A-Z][A-Z0-9]+[AEX]$';";

//Get course list only include courses with at least on empty quiz
//If only one course found this becomes the selected course
$course_rs = $DB->get_recordset_sql($courseQuery);
if ($course_rs->valid()) {
	if (count($course_rs)==1) {
		$seldata->courseid=$course_rs->id;
		$seldata->courselist='</br>';
		}
	else {
		$seldata->courseid=$courseid;
		$seldata->courselist=get_option_list($course_rs,'?courseid=');
		}
	}

if ($seldata->courseid) {
	// Open the quiz and qcat recordsets
	$quiz_sql=str_replace('@courseid',$seldata->courseid,$quizQuery);
	$quiz_rs = $DB->get_recordset_sql($quiz_sql);
	$qcat_sql=str_replace('@courseid',$seldata->courseid,$quizQuery);
	$qcat_rs = $DB->get_recordset_sql($qcat_sql);
	if ($quiz_rs->valid()) {
		if (count($quiz_rs)==1) {
			$seldata->quizid=$quiz_rs->id;
			}
		}
		if ($qcat_rs->valid()) {
			if (count($qcat_rs)==1) {
				$seldata->qcatid=$qcat_rs->id;
				}
			}
		// Prepare quiz parameter stem including &qcatid= only if $seldata->qcatid is set
		if ($seldata->qcatid == '') {
			$quiz_param='?courseid='.$seldata->courseid.'&quizid=';
		}
		else {
			$quiz_param='?courseid='.$seldata->courseid.'&qcatid='.$seldata->qcatid.'&quizid=';
		}
		// Prepare question category parameter stem including &quizid= only if $seldata->quizid is set
		if ($seldata->quizid == '') {
			$qcat_param='?courseid='.$seldata->courseid.'&qcatid=';
		}
		else {
			$qcat_param='?courseid='.$seldata->courseid.'&quizid='.$seldata->quizid.'&qcatid=';
		}
		if (count($quiz_rs)>1) {
			$seldata->quizid=$quizid;
			$seldata->courselist=get_option_list($quiz_rs,$quiz_param);
			}
		}
		if ($qcat_rs->valid()) {
			if (count($qcat_rs)>1) {
				$seldata->qcatid=$qcatid;
				$seldata->courselist=get_option_list($quiz_rs,$qcat_param);
				}
			}
// Get names of selected items
	$seldata->coursename = $DB->get_field('course','shortname', ['id' => $seldata->courseid]);
	$seldata->quizname = $DB->get_field('quiz', 'name', ['id' => $seldata->quizid]);
	$seldata->qcatname = $DB->get_field('question_categories','name', ['id' => $seldata->qcatid ]);

//get selected course if any
// First check if the course parameter has been provided


echo $OUTPUT->header();

$SESSION->fdata->quizid=$SESSION->$seldata->quizid;
$SESSION->fdata->quizname=$SESSION->$seldata->quizname;
$SESSION->fdata->categoryid=$SESSION->$seldata->qcatid;
$SESSION->fdata->categoryname=$SESSION->$seldata->qcatname;

// Set up the form.
$form = new questionstoquiz_form(null, array());
if ($form->is_cancelled()) {
    redirect($homeurl);
}

$data = $form->get_data();
if (!$data) { // Display the form.

	echo '<p>Use the links in the lists below to navigate to a new empty quiz and the category that contains the questions. Your selections will appear in the form at the bottom of the screen.</p>';
	echo '<table width="100%"><tbody>';
	echo '<tr>'.table_th('Courses').table_th('Quizes`').table_th('Question Categories').'</tr>';
	echo '<tr>'.table_td($seldata->courselist).table_td($seldata->quizlist).table_td($seldata->qcatlist).'</tr>';
	echo '<tr>'.table_th('Selected Course').table_th('Selected Quiz').table_th('Selected Category').'</tr>';
	echo '<tr>'.table_th($seldata->coursename).table_th($seldata->quizname).table_th($seldata->qcatname).'</tr>';
	echo '</tbody></table>';

    // Display the form.
    $form->display();

} 
else {      // Process the form data.

    // Show form data for confirmation.
    $handler = new tool_questionstoquiz_handler();
    $report = $handler->process($data);
    echo $report;
	
}


// Footer.
echo $OUTPUT->footer();