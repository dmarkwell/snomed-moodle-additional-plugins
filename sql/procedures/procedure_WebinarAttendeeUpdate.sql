DELIMITER ;;
DROP PROCEDURE IF EXISTS `WebinarAttendeeUpdate`;
CREATE PROCEDURE `WebinarAttendeeUpdate` (IN `p_modified_after` varchar(10))
BEGIN
DECLARE `v_modified_after` bigint(10) DEFAULT 0;
# CATCH INVALID DATE ERROR HERE
DECLARE CONTINUE HANDLER FOR 1292 SET v_modified_after = 0;  

# PARAMETER p_modifiedAfter INCLUDED CAN BE USED TO RESTRICT TO APPTS AFTER A DATE. 
# ADDED FOR GENERAL COMPATIBILITY SO ALL CRON PROCS HAVE A STRING ARGUMENT.
# DATES WITH FORMAT YYYYMMDD or YYYY-MM-DD SHOULD BE USED IF REQUIRED.

SET `v_modified_after`=IFNULL(UNIX_TIMESTAMP(`p_modified_after`),0);

# Create the attendee GROUP for any scheduler that does not have one already
 
INSERT INTO `mdl_groups` (`courseid`,`idnumber`,`name`,`description`,`descriptionformat`,`enrolmentkey`,`picture`,`hidepicture`,`timecreated`,`timemodified`)
SELECT
`course`,CONCAT('WAG_',`id`),CONCAT('WebinarAttended_',
TRIM(Replace(Replace(Replace(`name`,'Module',''),'Webinar',''),'Schedule',''))),'Webinar attendee group used to avoid appt deletions',0,'',0,0,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM `mdl_scheduler` `s`
where CONCAT('WAG_',`id`) NOT IN (SELECT `idnumber` FROM `mdl_groups` WHERE `courseid`=`s`.`course`);
 
# Create the attended GROUPING for any course that contains an attendee GROUP and does not have one already
 
INSERT INTO `mdl_groupings`
(`courseid`,`name`,`idnumber`,`description`,`descriptionformat`,`timecreated`,`timemodified`)
SELECT
 `courseid`,'Webinar Attended Groups','WAG','<p>Used to enable access to Webinars area by those who have already attended a Webinar.</p>',1,UNIX_TIMESTAMP(), UNIX_TIMESTAMP()
FROM `mdl_groups` WHERE `idnumber` REGEXP '^WAG_[0-9]+' AND `courseid` NOT IN (SELECT `courseid` FROM `mdl_groupings` WHERE `idnumber`='WAG')
GROUP BY `courseid`;
 
# Add all attendee GROUPS in a Course to the attended GROUPING unless they are already in the GROUPING.
 
INSERT INTO `mdl_groupings_groups`
(`groupingid`,`groupid`,`timeadded`)
SELECT
 `gs`.`id`,`g`.`id`, UNIX_TIMESTAMP()
FROM `mdl_groupings` `gs`
      JOIN `mdl_groups` `g` ON `g`.`courseid`=`gs`.`courseid`
      WHERE `gs`.`idnumber`='WAG' AND `g`.`idnumber` REGEXP '^WAG_[0-9]+'
        AND `g`.`id` NOT IN (SELECT `groupid` FROM `mdl_groupings_groups` WHERE `groupingid`=`gs`.`id`);

# Updates the groups with new attendees

INSERT IGNORE INTO `mdl_groups_members` (`groupid`,`userid`,`timeadded`,`component`,`itemid`)
SELECT `g`.`id`,`sa`.`studentid`,UNIX_TIMESTAMP(),'',0
FROM `mdl_scheduler_appointment` `sa`
JOIN `mdl_scheduler_slots` `ss` ON `ss`.`id`=`sa`.`slotid`
JOIN `mdl_scheduler` `s` ON `s`.`id`=`ss`.`schedulerid`
JOIN `mdl_groups` `g` ON `s`.`id`=MID(`g`.`idnumber`,5)
WHERE `sa`.`attended`=1 and `sa`.`timemodified`>=`v_modified_after` and `sa`.`studentid` NOT IN (SELECT `userid` FROM `mdl_groups_members` WHERE `g`.`id`=`groupid`);

END;;
