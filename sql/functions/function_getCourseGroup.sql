DROP FUNCTION IF EXISTS `getCourseGroup`;;
CREATE FUNCTION `getCourseGroup`(`p_userid` bigint(10), `p_courseid` bigint(10),`p_idnum_regex` text) RETURNS varchar(32) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
begin

DECLARE v_result varchar(32);

IF `p_idnum_regex`regexp '^[iIcCeE]$' THEN 
SET `p_idnum_regex`='^_2[0-9]{5}$';
ELSEIF `p_idnum_regex` regexp '^[DdPpNnAaSs]$' THEN
SET `p_idnum_regex`='^_(Paused|Alumni|Deferred|Next).*$';
END IF;

SET v_result=(SELECT MAX(`g`.`name`) FROM `mdl_groups` `g` 
  JOIN `mdl_groups_members` `m` ON `m`.`groupid`=`g`.`id` 
  WHERE `g`.`courseid`=`p_courseid` AND `g`.`idnumber` regexp `p_idnum_regex` AND `m`.`userid`=`p_userid`);

IF ISNULL(`v_result`) THEN
SET v_result='';
END IF;

RETURN `v_result`;
end;;
