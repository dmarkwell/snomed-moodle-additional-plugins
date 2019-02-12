DELIMITER ;;
DROP PROCEDURE IF EXISTS `WebinarAttendeeUpdate`;;
CREATE PROCEDURE `WebinarAttendeeUpdate`(IN `p_modified_after` varchar(10))
BEGIN
DECLARE `v_modified_after` bigint(10) DEFAULT 0;
# CATCH INVALID DATE ERROR HERE
DECLARE CONTINUE HANDLER FOR 1292 SET v_modified_after = 0;  

# PARAMETER p_modifiedAfter INCLUDED CAN BE USED TO RESTRICT TO APPTS AFTER A DATE. 
# ADDED FOR GENERAL COMPATIBILITY SO ALL CRON PROCS HAVE A STRING ARGUMENT.
# DATES WITH FORMAT YYYYMMDD or YYYY-MM-DD SHOULD BE USED IF REQUIRED.

SET `v_modified_after`=IFNULL(UNIX_TIMESTAMP(`p_modified_after`),0);

INSERT IGNORE INTO `mdl_groups_members` (`groupid`,`userid`,`timeadded`,`component`,`itemid`)
SELECT `g`.`id`,`sa`.`studentid`,UNIX_TIMESTAMP(),CONCAT('Appt time: ',FROM_UNIXTIME(`ss`.`starttime`),' Grade: ', IFNULL(`sa`.`grade`,'0')),0
FROM `mdl_scheduler_appointment` `sa`
JOIN `mdl_scheduler_slots` `ss` ON `ss`.`id`=`sa`.`slotid`
JOIN `mdl_scheduler` `s` ON `s`.`id`=`ss`.`schedulerid`
JOIN `mdl_groups` `g` ON `s`.`id`=MID(`g`.`idnumber`,5)
WHERE `sa`.`attended`=1 and `sa`.`timemodified`>=`v_modified_after` and `sa`.`studentid` NOT IN (SELECT `userid` FROM `mdl_groups_members` WHERE `g`.`id`=`groupid`);

END;;
