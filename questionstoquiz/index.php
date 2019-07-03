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
$topnode = optional_param('topnode', null, PARAM_INT);
$coursenode  = optional_param('coursenode', null, PARAM_INT);
$questnode = optional_param('questnode', null, PARAM_INT);
$subnode = optional_param('subnode', null, PARAM_INT);

$quizid = optional_param('quizid', null, PARAM_INT);
$courseid = optional_param('courseid', null, PARAM_INT);
$quiznode  = optional_param('quiznode', null, PARAM_INT);

$qnodeset = array( "quiznode"=>$quiznode,"questnode"=>$questnode,"subnode"=>$subnode );

// viewnode reserved for future use
$viewmode = optional_param('viewmode', 'default', PARAM_INT);

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
$seldata->catparams = '';
$seldata->courseparams = '';
$seldata->quizparams = '';
$seldata->catlist = '';
$seldata->quizlist = '';
$prevnodeid = 0;
$sep='&';

// TEMPORARY PLACE FOR THIS QUERY @id NEEDS TO BE COURSE ID
$contextQuery="SELECT `ctx`.`id` from `mdl_context` `ctx`
join `mdl_course` `c` ON `c`.`id`=`ctx`.`instanceid`
where `c`.`id`=@id and `ctx`.`contextlevel`=50
UNION
select `ctx`.`id` from `mdl_context` `ctx`
join `mdl_course_categories` `cc` ON `cc`.`id`=`ctx`.`instanceid` 
join `mdl_course` `c` ON `c`.`category`=`cc`.`id`
where `c`.`id`=@id
and `ctx`.`contextlevel`=40;";

$contextQuery2="SELECT * FROM `mdl_question_categories` `qc`
WHERE `qc`.`contextid` IN (11293,3)
AND BINARY `qc`.`name` regexp '^[A-Z][A-Z0-9]+[AEX]$;";

$contextQuery3="SELECT * FROM `mdl_question_categories` `qc`
WHERE `qc`.`contextid` IN (SELECT `ctx`.`id` from `mdl_context` `ctx`
join `mdl_course` `c` ON `c`.`id`=`ctx`.`instanceid`
where `c`.`id`=32 and `ctx`.`contextlevel`=50
UNION
select `ctx`.`id` from `mdl_context` `ctx`
join `mdl_course_categories` `cc` ON `cc`.`id`=`ctx`.`instanceid` 
join `mdl_course` `c` ON `c`.`category`=`cc`.`id`
where `c`.`id`=32 and `ctx`.`contextlevel`=40)
AND BINARY `qc`.`name` regexp '^[A-Z][A-Z0-9]+[AEX]$';";

$SESSION->qparam->qcid=0;
$SESSION->qparam->qbid=0;
$SESSION->qparam->qb='';
$SESSION->qparam->qc='';
$SESSION->qparam->qbname='';
$SESSION->qparam->qcname='';

// First check if the course parameter has been provided
if ($courseid) {
	$seldata->courseparams = '&courseid='.$courseid;
	// If course parameter is set check if quiz parameter provided
	if ($quizid) {
		$seldata->quizparams.'&quizid='.$quizid;
	}
	else
	{
		$seldata->quizparams = $seldata->courseparams;
	}
	if ($catid) {
		$seldata->quizparams.'&quizid='.$quizid;
	}
	else
	{
		$seldata->quizparams = $seldata->courseparams;
	}
}

// Set the question bank title
$seldata->cattitle = page_linktext('Question Bank',$seldata->quizparams);

foreach($qnodeset as $nodelevel => $nodeid) {
	if ($nodeid) {
		$seldata->catparams .= $sep.$nodelevel.'='.$nodeid;
		$name = $DB->get_field('question_categories', 'name', array ( 'id' => $nodeid), IGNORE_MISSING);
		$seldata->cattitle .= ' / '.page_linktext($name,$seldata->quizparams.$seldata->catparams);
		$SESSION->qparam->qc=$nodelevel;
		$SESSION->qparam->qcid=$nodeid;
		$SESSION->qparam->qcname=$name;
	}
	else {
		$sql = 'SELECT `c`.`id` `id`,`c`.`name` `cname`,count(`c2`.`id`) `children`,count(`q`.`id`) `questions` FROM `mdl_question_categories` `c` LEFT OUTER JOIN `mdl_question_categories` `c2` ON `c2`.`parent`=`c`.`id` LEFT OUTER JOIN `mdl_question` `q` ON `q`.`category`=`c`.`id` WHERE (NOT ISNULL(`q`.`id`) OR NOT ISNULL(`c2`.`id`)) AND IFNULL(`q`.`qtype`,"") != "random" AND `c`.`parent`='.$SESSION->qparam->qcid.' GROUP BY `c`.`id` ORDER BY `c`.`name`';
		$rs = $DB->get_recordset_sql($sql);
		if ($rs->valid()) {
			foreach ($rs as $record) {
				
				if ($record->children > 0) {
					$seldata->catlist .= '<li>'.page_linktext($record->cname,$seldata->quizparams.$seldata->catparams.$sep.$nodelevel.'='.$record->id).' ('.$record->children.' children)</li>';
				}
				elseif ($record->questions >0) {
					$seldata->catlist .= '<li>'.$record->cname. ' '.get_icon_link('preview','See questions','/question/edit.php?courseid=1&qbshowtext=1&recurse=1&showhidden=1&category='.$record->id.'%2c1').'</li>';
				}
				else {
					$seldata->catlist .= '<li>'.$record->cname.'</li>';
				}
			}
		}
		$rs->close();
		break;
	}
}

$seldata->quiztitle = page_linktext('Courses',$seldata->catparams);
if ($courseid) {
	$coursename = $DB->get_field('course','shortname',array( 'id' => $courseid ));
	$seldata->quiztitle .= ' / '.page_linktext($coursename,$seldata->courseparams.$seldata->catparams);

	if ($quizid) {
		$quizmodid=$DB->get_field('course_modules','id',array( 'instance' => $quizid,'module'=>16 ));
		$quizname=$DB->get_field('quiz','name',array( 'id' => $quizid ));
		$seldata->quiztitle .= ' / '.page_linktext($quizname,$seldata->quizparams.$seldata->catparams).' '.get_icon_link('preview','View quiz','/mod/quiz/view.php?id='.$quizmodid);
		$prevquizid=$quizid;
		$prevquizname=$quizname;
		$SESSION->qparam->qb='quiz';
		$SESSION->qparam->qbid=$quizid;
		$SESSION->qparam->qbname=$quizname;
	}
	else {
		$SESSION->qparam->qb='course';
		$SESSION->qparam->qbid=$courseid;
		$SESSION->qparam->qbname=$coursename;
		$sql = 'SELECT `q`.`id` `id`,`q`.`name` `cname`,count(`s`.`id`) `questions` FROM `mdl_quiz` `q` LEFT OUTER JOIN `mdl_quiz_slots` `s` ON `s`.`quizid`=`q`.`id` WHERE `q`.`course`='.$courseid.' GROUP BY `q`.`id` ORDER BY `q`.`name`;';
		$rs = $DB->get_recordset_sql($sql);
		if ($rs->valid()) {
			foreach ($rs as $record) {
				$quizmodid=$DB->get_field('course_modules','id',array( 'instance' => $record->id,'module'=>16 ));
				$seldata->quizlist .= '<li>'.page_linktext($record->cname,$seldata->courseparams.$seldata->catparams.$sep.'quizid='.$record->id).' '.get_icon_link('preview','View quiz','/mod/quiz/view.php?id='.$quizmodid).' ('.$record->questions.' questions)</li>';
			}
		}
	}
}
else {

	$sql = 'SELECT `c`.`id` `id`,`c`.`shortname` `cname`,count(`q`.`id`) `quizzes` FROM `mdl_course` `c` JOIN `mdl_quiz` `q` ON `q`.`course`=`c`.`id` GROUP BY `c`.`id` ORDER BY `c`.`shortname`';
	$rs = $DB->get_recordset_sql($sql);
	if ($rs->valid()) {
		foreach ($rs as $record) {
			$seldata->quizlist .= '<li>'.page_linktext($record->cname,$seldata->catparams.$sep.'courseid='.$record->id).' ('.$record->quizzes.' quizzes)</li>';
		}
	}
	
}




echo $OUTPUT->header();

if ($SESSION->qparam->qb=='quiz') {
	$SESSION->fdata->quizid=$SESSION->qparam->qbid;
	$SESSION->fdata->quizname=$SESSION->qparam->qbname;
}
if ($SESSION->qparam->qc=='quiznode') {
	$SESSION->fdata->categoryid=$SESSION->qparam->qcid;
	$SESSION->fdata->categoryname=$SESSION->qparam->qcname;
}

// Set up the form.
$form = new questionstoquiz_form(null, array());
if ($form->is_cancelled()) {
    redirect($homeurl);
}




$data = $form->get_data();
if (!$data) { // Display the form.

	echo '<p>Use the links in the lists below to navigate to a new empty quiz and the category that contains the questions. Your selections will appear in the form at the bottom of the screen.</p>';
	echo '<table width="100%"><tbody>';
	echo '<tr>'.table_th('Course and Quiz').table_th('Question Categories').'</tr>';
	echo '<tr>'.table_th($seldata->quiztitle).table_th($seldata->cattitle).'</tr>';
	echo '<tr>'.table_td($seldata->quizlist).table_td($seldata->catlist).'</tr>';
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