DROP PROCEDURE IF EXISTS `CommunicationPreferenceUpdate`;;
CREATE PROCEDURE `CommunicationPreferenceUpdate`(IN `p_startDate` varchar(10) CHARACTER SET 'utf8mb4')
BEGIN
DECLARE `v_cpOptionalId` BIGINT(10);
DECLARE `v_cpEssentialId` BIGINT(10);
DECLARE `v_startDate` BIGINT(10);

# PARAMETER p_startDate INCLUDED CAN BE USED TO RESTRICT UPDATES TO THOSE OCCURING AFTER A SPECIFIED DATE 
# ADDED FOR GENERAL COMPATIBILITY SO ALL CRON PROCS HAVE A STRING ARGUMENT.
# DATES WITH FORMAT YYYYMMDD or YYYY-MM-DD SHOULD BE USED IF REQUIRED.
# USE d,w,m (last day,week,month only)


CASE LOWER(LEFT(`p_startDate`,1))
  WHEN 'd' THEN SET `v_startDate`=UNIX_TIMESTAMP(SUBDATE(Now(),INTERVAL 1 DAY));
  WHEN 'w' THEN SET `v_startDate`=UNIX_TIMESTAMP(SUBDATE(Now(),INTERVAL 7 DAY));
  WHEN 'm' THEN SET `v_startDate`=UNIX_TIMESTAMP(SUBDATE(Now(),INTERVAL 1 MONTH));
  ELSE
        SET `v_startDate`=IFNULL(UNIX_TIMESTAMP(DATE(`p_startDate`)),0);
END CASE;


SET `v_cpOptionalId`=(SELECT `id` FROM `mdl_cohort` WHERE `idnumber`='cpOptional');
SET `v_cpEssentialId`=(SELECT `id` FROM `mdl_cohort` WHERE `idnumber`='cpEssential');


DROP TABLE IF EXISTS `tmp_choice`;
DROP TABLE IF EXISTS `tmp_user_choice`;


CREATE TEMPORARY TABLE `tmp_choice`
(`choice` bigint(10),
 `cohort` bigint(10),
 `info_field` bigint(10),
 `value` varchar(20),
 PRIMARY KEY (`choice`));

 
DROP TABLE IF EXISTS `tmp_user_choice`;
CREATE TEMPORARY TABLE `tmp_user_choice` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `userid` bigint(10) NOT NULL,
  `submitted` bigint(10) NOT NULL,
  `cohort` bigint(10) NOT NULL,
  `cohort_member_id` bigint(10) DEFAULT NULL,
  `info_field` bigint(10) DEFAULT NULL,
 `value` varchar(20),
  PRIMARY KEY (`id`),
  UNIQUE KEY `userid_cohort` (`userid`,`cohort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 

INSERT INTO `tmp_choice` (`choice`,`cohort`,`info_field`,`value`)
SELECT `qc`.`id`,`c`.`id`,`f`.`id`,SUBSTRING_INDEX(`qc`.`value`,'=',-1)
FROM `mdl_questionnaire_question` `qq`
JOIN `mdl_questionnaire_quest_choice`  `qc` ON `qc`.`question_id`=`qq`.`id`
JOIN `mdl_cohort` `c` ON `c`.`idnumber`=SUBSTRING_INDEX(`qc`.`value`,'=',1)
JOIN `mdl_user_info_field` `f` ON `f`.`shortname`=SUBSTRING_INDEX(`qc`.`value`,'=',1)
WHERE `qq`.`survey_id`=34;


INSERT INTO `tmp_user_choice` (`userid`,`submitted`,`cohort`,`cohort_member_id`,`info_field`,`value`)
SELECT `qr`.`userid`,`qr`.`submitted`,`tc`.`cohort`,IFNULL(`cm`.`id`,0),`tc`.`info_field`,`tc`.`value`
FROM `mdl_questionnaire_response` `qr`
JOIN `mdl_questionnaire_resp_single` `qs` ON `qr`.`id`=`qs`.`response_id`
JOIN `tmp_choice` `tc` ON `tc`.`choice`=`qs`.`choice_id`
LEFT OUTER JOIN `mdl_cohort_members` `cm` ON `cm`.`cohortid`=`tc`.`cohort` AND `cm`.`userid`=`qr`.`userid`
WHERE `survey_id` = '34' AND `complete` = 'y' 
AND `submitted`>v_startDate
AND `submitted` IN (SELECT MAX(`submitted`) FROM `mdl_questionnaire_response` WHERE `survey_id`=34 AND `userid`=`qr`.`userid`);


INSERT IGNORE INTO `tmp_user_choice` (`userid`,`submitted`,`cohort`,`cohort_member_id`,`info_field`,`value`)
SELECT `pa`.`userid`,`pa`.`timemodified`,`v_cpOptionalId`,IFNULL(`cm`.`id`,0),0,"DEFAULT"
FROM `mdl_tool_policy_acceptances` `pa`
JOIN `mdl_tool_policy_versions` `pv` ON `pv`.`id`=`pa`.`policyversionid`
LEFT OUTER JOIN `mdl_cohort_members` `cm` ON `cm`.`cohortid`=`v_cpOptionalId` AND `cm`.`userid`=`pa`.`userid`
WHERE `pv`.`policyid`=2 AND `pa`.`status`=1
AND `pa`.`timemodified`>v_startDate
AND `pa`.`timemodified` IN (SELECT MAX(`pa2`.`timemodified`) FROM `mdl_tool_policy_acceptances` `pa2`
JOIN `mdl_tool_policy_versions` `pv2` ON `pv2`.`id`=`pa2`.`policyversionid` 
WHERE `pv2`.`policyid`=`pv`.`policyid` AND `pa2`.`userid`=`pa`.`userid`);


INSERT IGNORE INTO `tmp_user_choice` (`userid`,`submitted`,`cohort`,`cohort_member_id`,`info_field`,`value`)
SELECT `pa`.`userid`,`pa`.`timemodified`,`v_cpEssentialId`,IFNULL(`cm`.`id`,0),0,"DEFAULT"
FROM `mdl_tool_policy_acceptances` `pa`
JOIN `mdl_tool_policy_versions` `pv` ON `pv`.`id`=`pa`.`policyversionid`
LEFT OUTER JOIN `mdl_cohort_members` `cm` ON `cm`.`cohortid`=`v_cpEssentialId` AND `cm`.`userid`=`pa`.`userid`
WHERE `pv`.`policyid`=2 AND `pa`.`status`=1
AND `pa`.`timemodified`>v_startDate
AND `pa`.`timemodified` IN (SELECT MAX(`pa2`.`timemodified`) FROM `mdl_tool_policy_acceptances` `pa2`
JOIN `mdl_tool_policy_versions` `pv2` ON `pv2`.`id`=`pa2`.`policyversionid` 
WHERE `pv2`.`policyid`=`pv`.`policyid` AND `pa2`.`userid`=`pa`.`userid`);


DELETE FROM `mdl_cohort_members` WHERE `id` IN
(SELECT `cohort_member_id` FROM `tmp_user_choice` WHERE `value`='NO');


INSERT IGNORE INTO `mdl_cohort_members` (`cohortid`,`userid`,`timeadded`)
SELECT `cohort`,`userid`, UNIX_TIMESTAMP()
FROM `tmp_user_choice` 
WHERE `cohort_member_id`=0 AND `value` IN ('YES','DEFAULT');



INSERT INTO `mdl_user_info_data` (`userid`,`fieldid`,`data`)
SELECT `userid`, `info_field`, `value`
FROM `tmp_user_choice`
WHERE `value` IN ('YES','NO')
ON DUPLICATE KEY UPDATE `data`=`value`;


DROP TABLE IF EXISTS `tmp_choice`;
DROP TABLE IF EXISTS `tmp_user_choice`;

END;;
