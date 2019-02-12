DELIMITER ;;
DROP FUNCTION IF EXISTS `getIntakeCohort`;;
CREATE FUNCTION `getIntakeCohort`(`p_userid` bigint(10), `p_courseid` bigint(10)) RETURNS varchar(32) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
begin

DECLARE v_result varchar(32);

SET v_result=(SELECT MAX(`ch`.`name`) FROM `mdl_cohort` `ch` 
  JOIN `mdl_cohort_members` `m` ON `m`.`cohortid`=`ch`.`id` 
  WHERE `ch`.`idnumber` regexp CONCAT('^C',p_courseid,'_2[0-9]{5}$') AND `m`.`userid`=`p_userid`);

IF ISNULL(`v_result`) THEN
SET v_result='';
END IF;

RETURN `v_result`;
end;;
