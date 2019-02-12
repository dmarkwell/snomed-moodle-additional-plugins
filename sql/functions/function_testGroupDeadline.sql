DROP FUNCTION IF EXISTS `testGroupDeadline`;;
CREATE FUNCTION `testGroupDeadline`(`p_userid` bigint(10), `p_courseid` bigint(10)) RETURNS text CHARSET utf8mb4
proc:begin

DECLARE `v_formal_duration` int(4) DEFAULT '4';
DECLARE `v_group` varchar(20);
DECLARE `v_altgroup` varchar(20);
DECLARE `v_extended_duration` int(4) DEFAULT '0';
DECLARE `v_calcdate` datetime;
DECLARE `v_prestart` int(4) DEFAULT 0;
DECLARE `v_out` text;

	SET `v_group`=getCourseGroup(`p_userid`,`p_courseid`,'I');
	IF `v_group`='' THEN
    	    	SET `v_group`=getIntakeCohort(`p_userid`,`p_courseid`);
	END IF;

        IF `v_group` not regexp '[0-9]{6}' THEN
           RETURN 'No Progress';
           LEAVE proc;
        END IF;

        SET `v_altgroup`=getCourseGroup(`p_userid`,`p_courseid`,'S');

	IF `v_altgroup` regexp 'Deferred|Paused' THEN
		RETURN 'Deferred';
		LEAVE proc;
	END IF;

    	SET `v_prestart`=(SELECT `data` from `mdl_local_metadata` `d` JOIN `mdl_local_metadata_field` `f` ON `f`.`id`=`d`.`fieldid` WHERE `f`.`contextlevel`=50 AND `f`.`shortname`='permitearlystart'  AND `d`.`instanceid`=`p_courseid` );
        SET `v_calcdate`=CONCAT(MID(`v_group`,5,4),'-',MID(`v_group`,9,2),'-01');
        SET `v_formal_duration`=(SELECT `data` from `mdl_local_metadata` `d` JOIN `mdl_local_metadata_field` `f` ON `f`.`id`=`d`.`fieldid` WHERE `f`.`contextlevel`=50 AND `f`.`shortname`='basicduration' AND  `d`.`instanceid`=`p_courseid` );
	SET `v_extended_duration`=(SELECT `data` from `mdl_local_metadata` `d` JOIN `mdl_local_metadata_field` `f` ON `f`.`id`=`d`.`fieldid` WHERE `f`.`contextlevel`=50 AND `f`.`shortname`='extendedduration' AND  `d`.`instanceid`=`p_courseid` );
        
	IF SUBDATE(`v_calcdate`, INTERVAL `v_prestart` MONTH)>now() THEN
		RETURN 'Pending';
	ELSEIF ADDDATE(`v_calcdate`, INTERVAL `v_formal_duration` MONTH) >now() THEN
		RETURN 'Active';
	ELSEIF ADDDATE(`v_calcdate`, INTERVAL `v_extended_duration` MONTH) >now() AND `v_altgroup` regexp 'Next' THEN
		RETURN 'Extended';
	ELSE
		RETURN 'Time Expired';
	END IF;

	end;;
