DELIMITER ;;
DROP PROCEDURE IF EXISTS `merge_assignment_groups`;;
CREATE PROCEDURE `merge_assignment_groups`(IN `course_shortname` varchar(255), IN `groupname_source` varchar(255), IN `groupname_target` varchar(255))
proc: begin

DECLARE `course_id` bigint(10) DEFAULT NULL;
DECLARE `group_source` bigint(10) DEFAULT NULL;
DECLARE `discussion_source` bigint(10) DEFAULT NULL;
DECLARE `discussion_name` varchar(255) DEFAULT '';
DECLARE `group_target` bigint(10) DEFAULT NULL;
DECLARE `discussion_target` bigint(10) DEFAULT NULL;
DECLARE `parent_target` bigint(10) DEFAULT NULL;
DECLARE `parent_source` bigint(10) DEFAULT NULL;
DECLARE `done` INT DEFAULT FALSE;
DECLARE `forum_id` BIGINT(10) DEFAULT NULL;

DECLARE `cur1` CURSOR FOR SELECT `f`.`id`,`d`.`id`,`d`.`name` FROM `mdl_forum` `f` JOIN `mdl_forum_discussions` `d` ON `f`.`id`=`d`.`forum`
         WHERE `f`.`name` rlike 'Assignment' AND `f`.`course`=`course_id` and `d`.`groupid`=`group_target`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` = TRUE;

IF `groupname_source`=`groupname_target` THEN
	SELECT 'SOURCE AND TARGET IDENTICAL' `Error`;
	LEAVE proc;
END IF;

IF `groupname_source` NOT rlike CONCAT('^[A-Z]{3}_Assign_20[1-3][0-9]{3}_[A-Z]$') THEN
	SELECT 'INVALID SOURCE GROUP NAME' `Error`;
	LEAVE proc;
END IF;
SET @CCODE=(SELECT LEFT(`groupname_source`,3));
SET @INTAKE=(SELECT MID(`groupname_source`,12,6));

SELECT @CCODE, @INTAKE;

IF `groupname_target` NOT rlike CONCAT('^',@CCODE,'_Assign_',@INTAKE,'_[A-Z]$') THEN
	SELECT 'UNMATCHED TARGET GROUP NAME' `Error`;
	LEAVE proc;
END IF;


SET `course_id`=(SELECT `id` FROM `mdl_course` WHERE `shortname`=`course_shortname`);
IF `course_id` IS NULL THEN
	SELECT 'COURSE NOT FOUND'  `Error`;
	LEAVE proc;
END IF;
SET `group_source`=(SELECT `id` FROM `mdl_groups` WHERE `courseid`=`course_id` AND `name`=`groupname_source`);
IF `group_source` IS NULL THEN
	SELECT 'SOURCE GROUP NOT FOUND'  `Error`;
	LEAVE proc;
END IF;

SET `group_target`=(SELECT `id` FROM `mdl_groups` WHERE `courseid`=`course_id` AND `name`=`groupname_target`);
IF `group_target` IS NULL THEN
	SELECT 'TARGET GROUP NOT FOUND'  `Error`;
	LEAVE proc;
END IF;

SET @NO_DELETE_GROUP = FALSE;

OPEN `cur1`;

cur_loop: LOOP
	FETCH `cur1` INTO `forum_id`,`discussion_target`,`discussion_name`;
	IF `done` THEN
		LEAVE cur_loop;
	END IF;
	SET `discussion_source`=(SELECT `id` FROM `mdl_forum_discussions` WHERE `forum`=`forum_id` AND `groupid`=`group_source` AND `name`=`discussion_name`);
	IF `discussion_source` IS NULL THEN
		SELECT 'ERROR NO MATCHING SOURCE DISCUSSION THREAD FOR'  `Error`,`discussion_name` 'info';
		SET @NO_DELETE_GROUP = TRUE;
	END IF;
	SELECT `name`,`discussion_name`, `group_source`,`discussion_source`,`group_target`,`discussion_target` FROM `mdl_forum` WHERE `id`=`forum_id`;		

	
	SET `parent_target`=(SELECT `firstpost` FROM `mdl_forum_discussions` WHERE `id`=`discussion_target`);
	SET `parent_source`=(SELECT `firstpost` FROM `mdl_forum_discussions` WHERE `id`=`discussion_source`);
	
	
	UPDATE `mdl_groups_members`
	SET `groupid`=`group_target`
	WHERE `groupid`=`group_source`;
	
	
	
	UPDATE `mdl_forum_posts`
	SET `discussion`=`discussion_target`,
		`parent`=`parent_target`
	WHERE `discussion`=`discussion_source` AND `parent`=`parent_source`;
	
	
	
	UPDATE `mdl_forum_posts`
	SET `discussion`=`discussion_target`
	WHERE `discussion`=`discussion_source`;
	
	
	DELETE FROM `mdl_forum_posts`
	WHERE `id`=`parent_source`;
	
	
	DELETE FROM `mdl_forum_discussions` 
	WHERE `id`=`discussion_source`;
	
END LOOP;

IF @NO_DELETE_GROUP = FALSE THEN
	
	DELETE FROM `mdl_groups` 
	WHERE `id`=`group_source`;
END IF;
	
end;;
