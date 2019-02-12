DELIMITER ;;
DROP PROCEDURE IF EXISTS `ClearStudentCourseProgress`;;
CREATE PROCEDURE `ClearStudentCourseProgress`(IN `p_courseid` bigint(10), IN `p_userid` bigint(10), IN `p_added` bigint(10))
CLEARPROGRESS: BEGIN

DECLARE `v_rowcount` bigint(10);
DECLARE `v_scormids` longtext;
DECLARE `v_refids` longtext;
DECLARE `v_moduleids` longtext;
DECLARE `v_quizids` longtext;
DECLARE `v_question_usageids` longtext;
DECLARE `v_question_attemptids` longtext;
DECLARE `v_question_attempt_stepids` longtext;


SET `v_scormids`=(SELECT GROUP_CONCAT(`id`) FROM `mdl_scorm`
WHERE `course`=`p_courseid`); 

SET `v_refids`=(SELECT GROUP_CONCAT(`refid`) FROM `mdl_elp_scorm_link`
WHERE FIND_IN_SET(`scormid`,`v_scormids`));

SET `v_moduleids`=(SELECT GROUP_CONCAT(`moduleid`) FROM `mdl_elp_scorm_link`
WHERE FIND_IN_SET(`refid`,`v_refids`));

IF `p_added`>unix_timestamp()+10 OR`p_added`<unix_timestamp()-10 THEN
    INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress','Invalid timestamp parameter',`p_courseid`,`p_userid`,unix_timestamp());
	LEAVE CLEARPROGRESS;
END IF;


INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Started in course:',`p_courseid`,'for userid: ',`p_userid`),`p_courseid`,`p_userid`);

SET `v_quizids`=(SELECT GROUP_CONCAT(`id`) FROM `mdl_quiz` WHERE `course`=`p_courseid`);

SET `v_question_usageids`=(SELECT GROUP_CONCAT(`uniqueid`) FROM `mdl_quiz_attempts` 
	WHERE `userid`=`p_userid` 
	AND  FIND_IN_SET(`quiz`,`v_quizids`));

SET `v_question_attemptids`=(SELECT GROUP_CONCAT(`id`) FROM `mdl_question_attempts`
	WHERE FIND_IN_SET(`questionusageid`,`v_question_usageids`));

SET `v_question_attempt_stepids`=(SELECT GROUP_CONCAT(`id`) FROM `mdl_question_attempt_steps`
WHERE FIND_IN_SET(`questionattemptid`,`v_question_attemptids`));

DELETE FROM `mdl_question_attempt_step_data` WHERE FIND_IN_SET(`attemptstepid`,`v_question_attemptids`); 

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	 ' question_attempt_steps' ),`p_courseid`,`p_userid`,`v_rowcount`);

DELETE FROM `mdl_question_attempt_steps` WHERE FIND_IN_SET(`id`,`v_question_attemptids`);  

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	' question_attempt_steps' ),`p_courseid`,`p_userid`,`v_rowcount`);

DELETE FROM `mdl_question_attempts` WHERE FIND_IN_SET(`id`,`v_question_attemptids`);  

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	' question_attempts' ),`p_courseid`,`p_userid`,`v_rowcount`);

DELETE FROM `mdl_question_usages` WHERE FIND_IN_SET(`id`,`v_question_usageids`);  

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	' question_usages' ),`p_courseid`,`p_userid`,`v_rowcount`);

DELETE FROM `mdl_quiz_attempts` WHERE `userid`=`p_userid` AND FIND_IN_SET(`quiz`,`v_quizids`);

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	' quiz_attempts' ),`p_courseid`,`p_userid`,`v_rowcount`);

DELETE FROM `mdl_quiz_grades` WHERE `userid`=`p_userid` AND FIND_IN_SET(`quiz`,`v_quizids`);

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	' quiz_grades' ),`p_courseid`,`p_userid`,`v_rowcount`);

UPDATE `mdl_grade_items` `i`,`mdl_grade_grades` `g`
	SET `g`.`rawgrade`=NULL,
		`g`.`finalgrade`=NULL
	WHERE `i`.`id`=`g`.`itemid`
		AND `g`.`userid`  =`p_userid`
		AND `i`.`courseid` = `p_courseid`;

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Cleared grades: ',`v_rowcount`,
	' grade_grades' ),`p_courseid`,`p_userid`,`v_rowcount`);

UPDATE `mdl_course_modules_completion`
 SET `completionstate`=0, 
     `viewed`=0
 WHERE `userid` =`p_userid`
   AND FIND_IN_SET(`coursemoduleid`,`v_moduleids`);

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Cleared: ',`v_rowcount`,
	' course_modules_completion' ),`p_courseid`,`p_userid`,`v_rowcount`);

UPDATE  `mdl_scorm_scoes_track`
	SET `value`='incomplete'
	WHERE `userid` = `p_userid`
		AND `element`='cmi.core.lesson_status'
		AND FIND_IN_SET(`scormid`,`v_scormids`);

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Cleared: ',`v_rowcount`,
	' scorm_scoes_track' ),`p_courseid`,`p_userid`,`v_rowcount`);

DELETE FROM `mdl_elp_scorm_track`
	WHERE `userid`=`p_userid` 
	AND FIND_IN_SET(`refid`,`v_refids`);

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	' mdl_elp_scorm_track' ),`p_courseid`,`p_userid`,`v_rowcount`);

DELETE FROM `mdl_scheduler_appointment`
	WHERE `slotid` IN (SELECT `sl`.`id`
			FROM `mdl_scheduler` `sc`
			JOIN `mdl_scheduler_slots` `sl` ON `sl`.`schedulerid`=`sc`.`id`
			WHERE `sc`.`course` = `p_courseid`)
	AND `studentid`=`p_userid`;

SET `v_rowcount`=ROW_COUNT();

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
VALUES (`p_added`,'ClearStudentCourseProgress',concat('Courseid: ',`p_courseid`,' Userid: ',`p_userid`,' Deleted: ',`v_rowcount`,
	' mdl_scheduler_appointment' ),`p_courseid`,`p_userid`,`v_rowcount`);

INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`)
    VALUES (`p_added`,'ClearStudentCourseProgress',concat('Completed in course:',`p_courseid`,'for userid: ',`p_userid`),`p_courseid`,`p_userid`);
	
	END;;
