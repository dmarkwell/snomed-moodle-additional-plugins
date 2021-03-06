DELIMITER ;;
DROP FUNCTION IF EXISTS `testGroup`;;
CREATE FUNCTION `testGroup`(`p_userid` bigint(10), `p_regex` varchar(64), `p_prefix` varchar(12)) RETURNS tinyint(1)
begin

DECLARE v_regex varchar(64);

IF `p_regex`='' THEN
  RETURN 1;
END IF;

IF `p_prefix`='' OR `p_regex` rlike '_' THEN
SET `v_regex`=`p_regex`;
ELSE
SET `v_regex`=CONCAT('^',`p_prefix`,'?_',`p_regex`);
END IF;

RETURN (SELECT IF(COUNT(`g`.`name`)>0,1,0) FROM `mdl_groups` `g` 
  JOIN `mdl_groups_members` `m` ON `m`.`groupid`=`g`.`id` 
  WHERE `g`.`name` rlike `v_regex` AND `m`.`userid`=`p_userid`);

end;;
