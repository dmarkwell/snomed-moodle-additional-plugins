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
 * @package    tool_forumgrouppost
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require_once(__DIR__.'/../../../config.php');
require_once($CFG->libdir.'/adminlib.php');

// Include our function library.
$pluginname = 'forumgrouppost';
require_once($CFG->dirroot.'/admin/tool/'.$pluginname.'/locallib.php');

// Globals.
global $CFG, $OUTPUT, $USER, $SITE, $PAGE;

// Ensure only administrators have access.
$homeurl = new moodle_url('/');
require_login();
if (!is_siteadmin()) {
    redirect($homeurl, "This feature is only available for site administrators.", 5);
}

// Define URL PARAMETERS
$courseid = optional_param('courseid', null, PARAM_INT);
$forumid = optional_param('forumid', null, PARAM_INT);

$bookid = optional_param('bookid', null, PARAM_INT);
$chapterid = optional_param('chapterid', null, PARAM_INT);
$pageid = optional_param('pageid', null, PARAM_INT);
$chstart = optional_param('chstart', null, PARAM_INT);
$pages = optional_param('pages', null, PARAM_INT);

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

$seldata=new stdClass();
$seldata->forumlist = '';
$seldata->booklist = '';

$sep='&';

$SESSION->qparam->qc='';
$SESSION->qparam->qcid=0;
$SESSION->qparam->qcname='';
$SESSION->qparam->qb='';
$SESSION->qparam->qbid=0;
$SESSION->qparam->qbname='';
$SESSION->qparam->qf='';
$SESSION->qparam->qfid=0;
$SESSION->qparam->qfname='';



$seldata=new stdClass();
$params->course='';
$params->forum='';
$params->book='';
$params->chapter='';
$params->page='';

$seldata->forumtitle = page_linktext('Courses','');


if (!$courseid) {
	// No Course selected so show the courses list for selection
	elp_logadd('None','CourseId');
	$sql = 'SELECT `c`.`id` `id`,`c`.`shortname` `shortname`,count(DISTINCT `f`.`id`) `forums`,count(DISTINCT `b`.`id`) `books` FROM `mdl_course` `c` JOIN `mdl_forum` `f` ON `f`.`course`=`c`.`id` AND `f`.`type`="qanda" JOIN `mdl_book` `b` ON `b`.`course`=`c`.`id` GROUP BY `c`.`id` ORDER BY `c`.`shortname`';
	$rs = $DB->get_recordset_sql($sql);
	if ($rs->valid()) {
		foreach ($rs as $record) {
			$seldata->forumlist .= '<li>'.page_linktext($record->shortname,'?courseid='.$record->id).' ('.$record->forums.' forums) ('.$record->books.' books)</li>';
		}
	}
}
else {
	// Course Selected
	elp_logadd($courseid,'CourseId');
	$params->course='?courseid='.$courseid;
	$coursename=$DB->get_field('course','shortname',array ( 'id' => $courseid ), IGNORE_MISSING);
	$SESSION->qparam->qc='course';
	$SESSION->qparam->qcname=$coursename;
	$SESSION->qparam->qcid=$courseid;
	$seldata->forumtitle .= ' / '.page_linktext($coursename,$params->course);
	// Set the preselected parameters

	if ($bookid) {
		$params->book = '&bookid='.$bookid;
		$params->page = $params->book;
		if ($chapterid) {
			$params->chapter = $params->book.'&chapterid='.$chapterid;
			$params->page = $params->chapter;
			if ($pageid) {
				$params->page = $params->chapter.'&pageid='.$pageid;
			}
		}
	}
	if ($forumid) {
		$params->forum = '&forumid='.$forumid;
	}

	// Get the display data
	
	$seldata->booktitle = page_linktext('Books',$params->course.$params->forum);
	if (!$bookid) {
		// Show books in this course
		$rs = $DB->get_recordset('book',array('course'=>$courseid),'name');
		if ($rs->valid()) {
			foreach ($rs as $record) {
				$seldata->booklist .= '<li>'.page_linktext($record->name,$params->course.$params->forum.'&bookid='.$record->id).'</li>';
			}
		}		
	}
	else {
		// Book Selected
		$bookname=$DB->get_field('book','name',array ( 'id'=>$bookid ), IGNORE_MISSING);
		$bookmodid=$DB->get_field('course_modules','id',array( 'instance' => $bookid,'module'=>3 ));
		$seldata->booktitle .= ' / '.page_linktext($bookname,$params->course.$params->forum.$params->book);
		if (!$chapterid) {
			$seldata->booktitle .= ' '.get_icon_link('preview','View book','/mod/book/view.php?id='.$bookmodid);
			elp_logadd('None','ChapterId');
			$SESSION->qparam->qb='book';
			$SESSION->qparam->qbname=$chapternname;
			$SESSION->qparam->qbid=$bookid;
			$chid=0;
			// Show Top Level chapters
			// Note: This also involves getting the page ranges for nested subchapters
			
			$rs = $DB->get_recordset('book_chapters', array ('bookid'=>$bookid, 'subchapter'=>0), 'pagenum');
			if ($rs->valid()) {
				foreach ($rs as $record) {
					elp_logadd(json_encode($record),'INREC');
					$chapterinfo = get_chapterinfo($record);
					elp_logadd(json_encode($chapterinfo),'OUT');
					if ($chapterinfo->pages) {
						
						$seldata->booklist .= '<li>'.page_linktext($chapterinfo->title.' ('.($chapterinfo->pages).' pages)',$params->course.$params->forum.$params->book.'&chapterid='.$chapterinfo->id).'</li>';
					}
					else {
						$seldata->booklist .= '<li>'.$chapterinfo->title.' (no pages)</li>';
					}
				}
			}	
		}
		else {
			$chapterinfo=get_chapterinfo($chapterid);
			$seldata->booktitle .= ' / '.page_linktext($chapterinfo->title,$params->course.$params->forum.$params->chapter);
			if (!$pageid) {
				// List pages
				$seldata->booktitle .= ' '.get_icon_link('preview','View chapter','/mod/book/view.php?id='.$bookmodid.'$chapterid='.$chapterid);
				$SESSION->qparam->qb='chapter';
				$SESSION->qparam->qbname=$chapterinfo->title;
				$SESSION->qparam->qbid=$chapterid;
				$rs = $DB->get_recordset_select('book_chapters','bookid='.$bookid.' AND subchapter=1 AND pagenum >'.$chapterinfo->pagenum.' AND pagenum <='.($chapterinfo->pagenum+$chapterinfo->pages),array(),'pagenum');
				if ($rs->valid()) {
					foreach ($rs as $record) {
						$seldata->booklist .= '<li>'.page_linktext($record->title,$params->course.$params->forum.$params->chapter.'&pageid='.$record->id).' '.get_icon_link('preview','View page','/mod/book/view.php?id='.$bookmodid.'&chapterid='.$record->id).'</li>';
					}
				}
			}
			else {
				elp_logadd($pageid,'PageId');
				// Page chosen
				$pagename=$DB->get_field('book_chapters','title',array ( 'id' => $pageid ), IGNORE_MISSING);
				$seldata->booktitle .= ' / '.page_linktext($pagename,$params->course.$params->forum.$params->page);
				$seldata->booktitle .= ' '.get_icon_link('preview','View chapter','/mod/book/view.php?id='.$bookmodid.'$chapterid='.$pageid);
				$SESSION->qparam->qb='page';
				$SESSION->qparam->qbname=$pagename;
				$SESSION->qparam->qbid=$pageid;
			}
		}
	}
	if (!$forumid) {
		elp_logadd('None','ForumId');
		//Show forums
		$rs = $DB->get_recordset('forum',array('course'=>$courseid,'type'=>'qanda'),'name');
		if ($rs->valid()) {
			foreach ($rs as $record) {
				$seldata->forumlist .= '<li>'.page_linktext($record->name,$params->course.$params->page.'&forumid='.$record->id).'</li>';
			}
		}
	}
	else {
		elp_logadd($forumid,'ForumId');
		//Forum Selected
		$forumname=$DB->get_field('forum','name',array ( 'id' => $forumid ), IGNORE_MISSING);
		$forummodid=$DB->get_field('course_modules','id',array( 'instance' => $forumid,'module'=>9 ));
		$seldata->forumtitle .= ' / '.page_linktext($forumname,$params->course.$params->page.$params->forum).' '.get_icon_link('preview','View forum','/mod/forum/view.php?id='.$forummodid);
		$SESSION->qparam->qf='forum';
		$SESSION->qparam->qfname=$forumname;
		$SESSION->qparam->qfid=$forumid;
	}
}

if ($SESSION->qparam->qb=='page') {
	$SESSION->fdata->pageid=$SESSION->qparam->qbid;
	$SESSION->fdata->pagename=$SESSION->qparam->qbname;
}
if ($SESSION->qparam->qc=='course') {
	$SESSION->fdata->courseid=$SESSION->qparam->qcid;
	$SESSION->fdata->coursename=$SESSION->qparam->qcname;
}
if ($SESSION->qparam->qf=='forum') {
	$SESSION->fdata->forumid=$SESSION->qparam->qfid;
	$SESSION->fdata->forumname=$SESSION->qparam->qfname;
}

echo $OUTPUT->header();

// Set up the form.
$form = new forumgrouppost_form(null, array());
if ($form->is_cancelled()) {
    redirect($homeurl);
}

// Display or process the form.

$data = $form->get_data();
if (!$data) { // Display the form.

    echo $OUTPUT->heading($heading);

	echo '<p>Use the links in the lists below to navigate to:<ul><li>The course and forum to which you wish to post a message; and</li><li>A page within a book chapter that contains the message to be posted.</li></ul>Your selections will appear in the form at the bottom of the screen.</p>';
	echo '<table width="100%"><tbody>';
	echo '<tr>'.table_th('Course and Forums').table_th('Book, Chapter and Pages').'</tr>';
	// echo '<tr>'.table_th().table_th($seldata->booktitle).'</tr>';
	echo '<tr>'.table_td('<b>'.$seldata->forumtitle.'</b>'.$seldata->forumlist).table_td('<b>'.$seldata->booktitle.'</b>'.$seldata->booklist).'</tr>';
	echo '</tbody></table>';
	
    // Display the form.
    $form->display();

} 
else {      // Process the form data.

    // Show form data for confirmation.
    $handler = new tool_forumgrouppost_handler();
    $report = $handler->process($data);
    echo $report;
	
}

// Footer.
echo $OUTPUT->footer();