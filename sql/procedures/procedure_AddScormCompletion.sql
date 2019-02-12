DROP PROCEDURE IF EXISTS `AddScormCompletion`;;
CREATE PROCEDURE `AddScormCompletion`(IN `p_presref` varchar(255), IN `p_coursename` varchar(255), IN `p_users` longtext)
PROC: begin





















   
DECLARE v_presrefid bigint(10);
DECLARE v_moduleid bigint(10);
DECLARE v_scormid bigint(10);
DECLARE v_scoid bigint(10);
DECLARE v_course bigint(10);



IF p_presref not rlike '^ELP[0-9]{4}[a-z]{0,3}_' THEN
   SELECT 'ERROR: No matching presentation. NOTE: p_presref must match regular expression with ELP[0-9]{4}[a-z]{0,3}_.* (e.g ELP0001_)';
   LEAVE PROC;
END IF;


SET v_presrefid=(SELECT `id` FROM `mdl_elp_scorm_ref` WHERE `reference` rlike CONCAT('^',`p_presref`));
SET v_course=(SELECT `id` FROM `mdl_course` WHERE `shortname`=`p_coursename`);

SELECT `v_presrefid`,`v_course`;

IF `v_course` IS NULL THEN 
SELECT 'A';
SET v_moduleid=(SELECT MIN(`l`.`moduleid`) FROM `mdl_elp_scorm_link` `l` WHERE `l`.`refid`=`v_presrefid`);
ELSE
SET v_moduleid=(SELECT MIN(`l`.`moduleid`) FROM `mdl_elp_scorm_link` `l` JOIN `mdl_course_modules` `m` ON `m`.`id`=`l`.`moduleid` WHERE `l`.`refid`=`v_presrefid` AND `m`.`course`=`v_course`);
END IF;

SET v_scormid=(SELECT `scormid` FROM `mdl_elp_scorm_link` WHERE `refid`=`v_presrefid` AND `moduleid`=`v_moduleid`);
SET v_scoid=(SELECT `scoid` FROM `mdl_elp_scorm_link` WHERE `refid`=`v_presrefid` AND `moduleid`=`v_moduleid`);

SELECT `v_presrefid`, `v_course`,`v_moduleid`,`v_scormid`,`v_scoid`;

INSERT INTO `mdl_scorm_scoes_track` (`userid`,`scormid`,`scoid`,`attempt`,`element`,`value`,`timemodified`)
SELECT distinct `id`,`v_scormid`,`v_scoid`,1,'cmi.core.lesson_status','complete',unix_timestamp()
FROM `mdl_user` WHERE find_in_set(id,p_users) OR find_in_set(username,p_users) OR find_in_set(email,p_users) 
ON DUPLICATE KEY UPDATE `value`='completed',`timemodified`=unix_timestamp();

SELECT distinct 'UPDATED VIEW RECORD FOR', id,username,firstname,lastname,email FROM `mdl_user` WHERE find_in_set(id,p_users) OR find_in_set(username,p_users) OR find_in_set(email,p_users) ;

CALL scorm_completion_update_full();

SELECT 'COMPLETE - You may need to clear caches to see the correct status from the login as student option.';

end;;
