DELIMITER ;;
DROP PROCEDURE IF EXISTS `ReportMaxBaseDataUpdate`;;
CREATE PROCEDURE `ReportMaxBaseDataUpdate`()
BEGIN

DECLARE `v_role_field` bigint(10);
DECLARE `v_expert_field` bigint(10);
DECLARE `v_interest_field` bigint(10);

SET `v_role_field`=(SELECT `id` FROM `mdl_user_info_field` WHERE `shortname`='role');
SET `v_expert_field`=(SELECT `id` FROM `mdl_user_info_field` WHERE `shortname`='expertise');
SET `v_interest_field`=(SELECT `id` FROM `mdl_user_info_field` WHERE `shortname`='interests');

DELETE FROM `mdl_elp_management_base`;

INSERT INTO `mdl_elp_management_base` (`userid`,`info_country`,`info_organization`,`info_role`,`info_expertise`,`info_interests`,`info_last_date`,`view_count`,`view_first_date`,`view_last_date`)
SELECT `u`.`id`,`u`.`country`,`u`.`institution`, IFNULL(`rl`.`data`,''),IFNULL(`exp`.`data`,''),IFNULL(`int`.`data`,''),FROM_UNIXTIME(`u`.`timemodified`),count(`vw`.`id`),min(FROM_UNIXTIME(`vw`.`modified`)),max(FROM_UNIXTIME(`vw`.`modified`))
	FROM `mdl_user` `u`
        JOIN `mdl_elp_scorm_track` `vw` ON `vw`.`userid`=`u`.`id`
	LEFT OUTER JOIN `mdl_user_info_data` `rl` ON `rl`.`userid`=`u`.`id` AND `rl`.`fieldid`=`v_role_field`
	LEFT OUTER JOIN `mdl_user_info_data` `exp` ON `exp`.`userid`=`u`.`id` AND `exp`.`fieldid`=`v_expert_field`
	LEFT OUTER JOIN `mdl_user_info_data` `int` ON `int`.`userid`=`u`.`id` AND `int`.`fieldid`=`v_interest_field`
	GROUP BY `u`.`id`;

END;;
