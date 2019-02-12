DROP PROCEDURE IF EXISTS `ScormCompletionUpdate`;;
CREATE PROCEDURE `ScormCompletionUpdate`(IN `p_option` varchar(6) CHARACTER SET 'utf8mb4')
proc:begin

# PARAMETER p_option 'full' checks views for all times
# ANY OTHER VALUE only checks views since last run (logs the option as 'recent')

DECLARE `last_run_time` bigint(10) DEFAULT 0;
DECLARE `this_run_time` bigint(10) DEFAULT 0;

IF (SELECT COUNT(`id`) FROM `mdl_elp_scorm_track` WHERE `refid`=0 and `userid`=0)=0 THEN
	INSERT IGNORE INTO `mdl_elp_scorm_track`
		(`refid`,`userid`,`modified`) VALUES (0,0,0);
END IF;

SET `p_option`=LOWER(`p_option`);
IF `p_option` = 'full' THEN
    SET `last_run_time`=0;

ELSE
    SET `p_option`='recent'; 
	SET `last_run_time` = (SELECT `modified` FROM `mdl_elp_scorm_track` WHERE `refid`=0 and `userid`=0);
END IF;

SET `this_run_time` = unix_timestamp();

INSERT IGNORE INTO `mdl_elp_scorm_ref` (`reference`)
SELECT DISTINCT `reference`
FROM `mdl_scorm` `s` 
WHERE `s`.`reference` rlike '^ELP[0-9]{4}' AND `s`.`launch`!=0;

# REBUILD SCORM LINK FROM SCRATCH EACH TIME

DELETE FROM `mdl_elp_scorm_link`; 

INSERT INTO `mdl_elp_scorm_link`
(`refid`,`scormid`,`scoid`,`moduleid`)
SELECT `r`.`id`,`s`.`id`,`s`.`launch`,`m`.`id`
FROM  `mdl_elp_scorm_ref` `r`
JOIN `mdl_scorm` `s` ON `s`.`reference`=`r`.`reference`
JOIN `mdl_course_modules` `m` ON `m`.`module`=18 AND `m`.`instance`=`s`.`id`
WHERE `s`.`launch`!=0;

# ADD ROWS TO THE SCORM TRACK TABLE FROM mdl_course_modules_completion
# This is one way of knowing the presentations completed by a student

INSERT IGNORE INTO `mdl_elp_scorm_track`
(`refid`,`userid`,`modified`)
SELECT `l`.`refid`,`m`.`userid`,MIN(`m`.`timemodified`)   
FROM `mdl_course_modules_completion` `m`
JOIN `mdl_elp_scorm_link` `l` ON `l`.`moduleid`=`m`.`coursemoduleid`
WHERE `m`.`completionstate`>=1
AND `m`.`timemodified` > last_run_time
GROUP BY `l`.`id`,`m`.`userid`;

# ADD ROWS TO THE SCORM TRACK TABLE FROM mdl_scorm_scoes_track
# This is another way of knowing the presentations completed by a student

INSERT IGNORE INTO `mdl_elp_scorm_track`
(`refid`,`userid`,`modified`)
SELECT `l`.`refid`, `t`.`userid`,`t`.`timemodified`
FROM `mdl_scorm_scoes_track` `t`
JOIN `mdl_course_modules` `m` ON `m`.`module`=18 AND `m`.`instance`=`t`.`scormid`
JOIN `mdl_elp_scorm_link` `l` ON `l`.`moduleid`=`m`.`id`
WHERE `t`.`element` = 'cmi.core.lesson_status' AND `t`.`value` IN ('passed','completed') 
AND `t`.`timemodified` > last_run_time
GROUP BY `m`.`id`,`t`.`userid`;

# ADD ROWS TO mdl_course_modules_completion FROM the SCORM TRACK TABLE
# This shows the completion marks for same presentation in other course areas

INSERT INTO `mdl_course_modules_completion`
(`coursemoduleid`,`userid`,`completionstate`,`viewed`,`timemodified`)
SELECT `l`.`moduleid`,`t`.`userid`,1,1,`t`.`modified`
FROM `mdl_elp_scorm_track` `t`
JOIN `mdl_elp_scorm_link` `l` ON `l`.`refid`=`t`.`refid`
WHERE `t`.`modified` > `last_run_time` AND `t`.`refid`!=0 AND `t`.`userid`!=0
ON DUPLICATE KEY UPDATE
`completionstate`=1,`viewed`=1;

# Set a record of the current run time as the new last_run_time

UPDATE `mdl_elp_scorm_track`
SET `modified`=`this_run_time`
WHERE `refid`=0 AND `userid`=0;

# Create a log record
INSERT INTO mdl_elp_log (`added`,`task`,`info`,`value1`,`value2`) VALUES (unix_timestamp(),'scorm_update',`p_option`,`last_run_time`,`this_run_time`);

end;;
