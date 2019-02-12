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
 * Library of functions for processing snomed test form data.
 *
 * @package    tool_forumgrouppost
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die;



/**
 * Validates and data entered in a form
 *
 * @copyright   2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class tool_forumgrouppost_handler {

	/**
     * Processes the form data
     * Returns a report of successes and failures.
     *
     * @return string A report of successes and failures.
     */
    public function process($data) {
        global $DB, $CFG, $SESSION, $USER;
        $report = array();
		$fail = 0;
		$SESSION->fdata=$data;
		
		$groupkey=$DB->get_field_sql('SELECT `m`.`data` FROM `mdl_local_metadata_field` `f` JOIN `mdl_local_metadata` `m` ON `m`.`fieldid`=`f`.`id` and `m`.`instanceid`=3 	WHERE `contextlevel` =50 AND `f`.`shortname` = "groupkey"');
		
		$sel='name regexp "^'.$groupkey.'_Assign[0-9]*_'.$data->intake.'_[A-Z]$" AND courseid='.$data->courseid;
		elp_logadd($sel,'Select-Count');
		$groups=$DB->count_records_select('groups','name regexp "^'.$groupkey.'_Assign[0-9]*_'.$data->intake.'_[A-Z]$" AND courseid='.$data->courseid);
		
		elp_logadd($groups,$data->intake);
		
		if ($groups==0) {
			echo div_color(get_string('invalid_intake', 'tool_forumgrouppost',$data),'red').'<br/>';
			$fail = 1;
		}
		
			
		if (!$data->confirm && !$fail) {
			// Confirm not checked so do not process just show test message.
			echo div_color(get_string('validation_message', 'tool_forumgrouppost',$data),'purple').'<br/>';
			$fail = 1;
		}	
		$postcount = 0;
		if (!$fail) {
			$tutorid=$USER->id;
			
			$page=$DB->get_record('book_chapters',array( 'id' => $data->pageid ));
				
			$discuss=new stdClass();
			$discuss->course=$data->courseid;
			$discuss->forum=$data->forumid;
			$discuss->name=$page->title;
			$discuss->firstpost='0';
			$discuss->userid=$tutorid;
			$discuss->assessed='0';
			$discuss->usermodified=$tutorid;
			$discuss->timestart='0';
			$discuss->timeend='0';
			
			$post=new stdClass();
			$post->parent='0';
			$post->userid=$tutorid;
			$post->mailed='1';
			$post->subject=$page->title;
			$post->message=$page->content;
			$post->messageformat='1';
			$post->messagetrust='0';
			$post->attachment='';
			$post->totalscore='0';
			$post->mailnow='0';			
			
			elp_logadd($discuss,'Discussion-Gen');
			elp_logadd($post,'Post-Gen');
			elp_logadd($sel,'Select-Loop');
			$rs = $DB->get_recordset_select('groups',$sel);
			elp_logadd($rs,'RecordSet');
			if ($rs->valid()) {
				foreach ($rs as $record) {
					elp_logadd($record,'Record');
					$discuss->timemodified=unix_timestamp();
					$discuss->groupid=$record->id;
					elp_logadd($discuss,'Discussion-Ins');
					$discussionid=$DB->insert_record('forum_discussions',$discuss,true);
					
					
					$post->discussion=$discussionid;
					$post->created=unix_timestamp();
					$post->modified=unix_timestamp();
					elp_logadd($post,'Post-Ins');
					$postid=$DB->insert_record('forum_posts',$post,true);
					
					
					$discuss_upd=clone $discuss;
					$discuss_upd->id=$discussionid;
					$discuss_upd->firstpost=$postid;
					elp_logadd($discuss,'Discussion-Upd');
					$DB->update_record('forum_discussions',$discuss_upd);
					
					$postcount += 1;
				}
			}
			if (!$postcount) 
			{
				echo '</ul>'.div_color(get_string('no_posts','tool_forumgrouppost',$data),'red').'<br/>';
			}
			else
			{
                $data->posts=$postcount;
				echo div_color(get_string('completion_message', 'tool_forumgrouppost',$data),darkgreen).'<br/>';
				unset($SESSION->fdata);
				unset($SESSION->qparam);
			}
		}
	// Display a link back to the form
	$params = get_params_fromdata($data);
	echo get_string('back_to_form','tool_forumgrouppost',forumgrouppost_url('index.php'.$params));
	return implode("<br/>", $report);
    }
}


/**
 * An exception for reporting errors
 *
 * Extends the moodle_exception with an http property, to store an HTTP error
 * code for responding to AJAX requests.
 *
 * @copyright   2010 Tauntons College, UK
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class forumgrouppost_exception extends moodle_exception {

    /**
     * Stores an HTTP error code
     *
     * @var int
     */
    public $http;

    /**
     * Constructor, creates the exeption from a string identifier, string
     * parameter and HTTP error code.
     *
     * @param string $errorcode
     * @param string $a
     * @param int $http
     */
    public function __construct($errorcode, $a = null, $http = 200) {
        parent::__construct($errorcode, 'tool_forumgrouppost', '', $a);
        $this->http = $http;
    }
}


function forumview_linktext($text,$forumid) {
	global $CFG;
    return '<a href="'.$CFG->wwwroot.'/mod/forum/view.php?id?'.$forumid.'">'.$text.'</a>';
}

function bookview_linktext($text,$bookid,$chapterid) {
	global $CFG;
	$bookmoduleid=$DB->get_field_sql('SELECT `m`.`id` FROM `mdl_course_modules` `m` JOIN `mdl_book` `b` ON `b`.`id`=`m`.`instance` AND `m`.`module`=3 AND `b`.`id`='.$bookid);
	$params = 'id='.$bookid;
	if ($chapterid) {
		$params .= '&chapterid='.$chapterid;
	}	
    return '<a href="'.$CFG->wwwroot.'/mod/book/view.php?'.$params.'">'.$text.'</a>';
}

function page_linktext($text,$params) {
	global $CFG;
    return '<a href="'.$CFG->wwwroot.'/admin/tool/forumgrouppost/index.php'.$params.'">'.$text.'</a>';	
}

function table_td($content) {
	return '<td width="50%" style="vertical-align: text-top;">'.$content.'</td>';
}
function table_th($content) {
	return '<th width="50%" style="vertical-align: text-top;horizontal-align: text-center;">'.$content.'</th>';
}


function forumgrouppost_url($relativeurl) {
    global $CFG;
    return $CFG->wwwroot.'/admin/tool/forumgrouppost/'.$relativeurl;
}

function div_color($text,$color) {
	return '<div style="color:'.$color.';">'.$text.'</div>';
}

function get_icon_link($icon,$title,$link) {
    global $CFG, $OUTPUT;
	/* Options for $icon include: 
		show, hide, viewdetail, preview, add, edit, edit_menu, editstring, 
		up, down, right, left, move, copy, delete, restore, export,
		unlock, locked, lock, block, unblock, approve, 
		message, email, subscribed, unsubscribed, markasread, selected,
		collapsed, collapsed_rtl, sort, sort_asc, sort_desc, 
		assignroles, enrolusers, cohort, groups, removecontact, addcontact,
		calc, calc_off, switch_minus, switch_plus, switch_whole, portfolioadd
	*/
	 
	$imgedit = $OUTPUT->pix_icon('t/'.$icon, $title);
	return html_writer::tag('a', $imgedit,
            array('title' => $title,
				'href' => $CFG->wwwroot.$link));
}


function get_params_fromdata($data) {
	global $DB;
	$params = '?courseid='.$data->courseid.'&forumid='.$data->forumid.'&pageid='.$data->pageid;
	$record = $DB->get_record('book_chapters', array ( 'id' => $data->pageid ));
	$sql = 'SELECT `id` FROM `mdl_book_chapters` WHERE `bookid`='.$record->bookid.' AND `pagenum` = (SELECT MAX(`pagenum`) FROM `mdl_book_chapters` WHERE `bookid`='.$record->bookid.' AND `subchapter`=0 AND `pagenum`< '.$record->pagenum.')';
	$chapterid = $DB->get_field_sql($sql);
	$params .= '&bookid='.$record->bookid.'&chapterid='.$chapterid;
	return $params;
}

function get_chapterinfo($chapter) {
	global $DB;
	if (gettype($chapter)=='object') {
		$chapterinfo = clone $chapter;
	}
	else {
		$chapterinfo = $DB->get_record('book_chapters', array ( 'id' => $chapter ), '*', IGNORE_MISSING);
	}
	$sql='SELECT IFNULL(MIN(`pagenum`-1)-'.$chapterinfo->pagenum.',-1) FROM `mdl_book_chapters` WHERE `bookid`='.$chapterinfo->bookid.' AND  `pagenum`>'.$chapterinfo->pagenum.' AND `subchapter`=0';
	$chapterinfo->pages = $DB->get_field_sql($sql);
	if ($chapterinfo->pages == -1) {
		$sql='SELECT MAX(`pagenum`)-'.$chapterinfo->pagenum.' FROM `mdl_book_chapters` WHERE `bookid`='.$chapterinfo->bookid;
		$chapterinfo->pages=$DB->get_field_sql($sql);
	}
	return $chapterinfo;
}

function unix_timestamp() {
	$time = new DateTime();
	return $time->getTimestamp();
}

function elp_logadd($data,$label) {
	global $DB;
	if (!$label) {
		$label='';
	}
	else {
		$label .= ': ';
	}
	$time = new DateTime();
	$timestamp=$time->getTimestamp();
	$record=new stdClass();
	$record->added=$timestamp;
	$record->task='ForumGroupPost';
	if (gettype($data)=='object'){
		$record->info=$label.json_encode($data);
	}
	else {
		$record->info=$label.$data;	
	}
	$DB->insert_record('elp_log',$record);
}

	
	
