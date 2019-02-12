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
 * Strings for component 'tool_questionstoquiz', language 'en'
 *
 * @package    tool_questionstoquiz
 * @copyright  2018 David Markwell SNOMED International
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();


$string['pluginname']			= 'Questions to Quiz';
$string['heading']				= 'Question Category Display';
$string['invalid_quiz']			= 'Quiz not found';
$string['quizname']				= 'Quiz Name';
$string['quizid']				= 'Quiz Id';
$string['categoryname']			= 'Question Category Name';
$string['categoryid']			= 'Question Category Id';
$string['confirm_info_button']	= 'Confirm Ready to Process';
$string['ok_button']			= 'Add Questions for Quiz';
$string['no_subcategories']		= 'No subcategories';
$string['invalid_category']		= 'Category not found';
$string['too_few_subcategories']= 'Too few subcategories';
$string['quiz_has_questions']	= 'Selected quiz already has questions';
$string['adding_questions']		= 'Adding questions ...';
$string['actions_completed']	= 'Questions added.';
$string['completion_message']	= 'Added questions to quiz: <ul><li>Quiz: {$a->quizid}) {$a->quizname} </li><li> Category: {$a->categoryid}) {$a->categoryname}.</li><li>Question subcategories: {$a->subcatcount}.</li></ul>';
$string['validation_message']	= 'Valid quiz and question category.<br/>The "Confirm" checkbox must be checked to actually delete progress data for:<ul><li>Quiz: {$a->quizid}) {$a->quizname} </li><li> Category: {$a->categoryid}) {$a->categoryname}.</li><li>Question subcategories: {$a->subcatcount}.</li></ul>';
$string['back_to_form']			= '<br/><a href="{$a}">Back to form</a><br/>';