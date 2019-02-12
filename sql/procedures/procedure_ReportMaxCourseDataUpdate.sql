DELIMITER ;;
DROP PROCEDURE IF EXISTS `ReportMaxCourseDataUpdate`;;
CREATE PROCEDURE `ReportMaxCourseDataUpdate`()
BEGIN

DELETE FROM `mdl_elp_management_course`;

INSERT INTO `mdl_elp_management_course` (`userid`,`courseid`,`intake_cohort`,`course_group`,`status_group`,`grade`,`status`,`complete_date`,`feedback_rating`,`feedback_recommend`,`feedback_date`)
SELECT `p`.`userid`,`p`.`courseid`,MAX(`p`.`intake_cohort`),MAX(`p`.`course_group`),MAX(`p`.`status_group`),MAX(`p`.`grade`),MAX(`p`.`course_status`),MAX(FROM_UNIXTIME(`p`.`date_completed`)),MAX(`rr`.`rank`+1),MAX(IF(`rc`.`value`=1,1,0)),MAX(FROM_UNIXTIME(`r`.`submitted`))
FROM `mdl_elp_progress_report` `p`
JOIN `mdl_elp_course_variables` `v` ON `v`.`courseid`=`p`.`courseid`
LEFT OUTER JOIN `mdl_questionnaire_response` `r` ON `r`.`userid`=`p`.`userid` AND `r`.`survey_id`=`v`.`feedback_survey`
LEFT OUTER JOIN `mdl_questionnaire_response_rank` `rr` ON `r`.`id`= `rr`.`response_id` AND `rr`.`question_id`=`v`.`feedback_overall` AND `r`.`complete`='y' 
LEFT OUTER JOIN `mdl_questionnaire_resp_single` `ra`  ON `r`.`id`= `ra`.`response_id` AND `ra`.`question_id`=`v`.`feedback_recommend` AND `r`.`complete`='y' 
LEFT OUTER JOIN `mdl_questionnaire_quest_choice` `rc` ON `rc`.`id`=`ra`.`choice_id`
GROUP BY `userid`,`courseid`;

END;;
