DROP PROCEDURE IF EXISTS `PresentationHistoryUpdate`;;
CREATE PROCEDURE `PresentationHistoryUpdate`(IN `p_resetStartYear` varchar(6) CHARACTER SET 'utf8mb4')
begin

DECLARE `v_startDate` bigint(10); 
DECLARE `v_endDate` bigint(10); 
DECLARE `v_period` varchar(6);
DECLARE `v_now` DATE;
DECLARE `v_prev` DATE;
DECLARE `done` tinyint(2) DEFAULT 0;


DECLARE `cur1` CURSOR FOR SELECT `period`,`startDate`,`endDate`
	FROM `tmp_DateRanges`;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` = TRUE;

SET `v_now`=Now();

IF `p_resetStartYear` regexp '20[0-9]{2}' THEN
	SET `v_prev`=DATE(CONCAT(`p_resetStartYear`,'0101'));
ELSEIF `p_resetStartYear` regexp '20[0-9]{4}' THEN
	SET `v_prev`=DATE(CONCAT(`p_resetStartYear`,'01'));
ELSE
	SET `v_prev`=(SELECT FROM_UNIXTIME(max(logtime)) FROM `mdl_elp_fileupdates`);
END IF;
	
DROP TABLE  IF EXISTS `tmp_DateRanges`;

CREATE TABLE `tmp_DateRanges`
(
`period` varchar(6),
`startDate` bigint(10),
`endDate` bigint(10),
primary key (`period`)
);


# GET ALL YEARS, MONTH AND QUARTERS SINCE PREVIOUS DATE

WHILE `v_prev`<`v_now` DO

	INSERT IGNORE INTO `tmp_DateRanges` (`period`,`startDate`,`endDate`) VALUES
	(DATE_FORMAT(`v_now`,"%Y"),UNIX_TIMESTAMP(CONCAT(DATE_FORMAT(`v_now`,"%Y"),'0101')),UNIX_TIMESTAMP(ADDDATE(DATE(CONCAT(DATE_FORMAT(`v_now`,"%Y"),'0101')), INTERVAL 1 YEAR))),
	(DATE_FORMAT(`v_now`,"%Y%m"),UNIX_TIMESTAMP(CONCAT(DATE_FORMAT(`v_now`,"%Y%m"),'01')),UNIX_TIMESTAMP(ADDDATE(DATE(CONCAT(DATE_FORMAT(`v_now`,"%Y%m"),'01')), INTERVAL 1 MONTH))),
	(CONCAT(DATE_FORMAT(`v_now`,"%Y"),'Q',TRUNCATE(((MONTH(`v_now`)+2)/3),0)),UNIX_TIMESTAMP(CONCAT(DATE_FORMAT(`v_now`,"%Y"),LPAD(TRUNCATE(((MONTH(`v_now`)+2)/3),0)*3-2,2,'0'),'01')),UNIX_TIMESTAMP(ADDDATE(DATE(CONCAT(DATE_FORMAT(`v_now`,"%Y"),LPAD(TRUNCATE(((MONTH(`v_now`)+2)/3),0)*3-2,2,'0'),'01')), INTERVAL 3 MONTH))),
	(DATE_FORMAT(`v_prev`,"%Y"),UNIX_TIMESTAMP(CONCAT(DATE_FORMAT(`v_prev`,"%Y"),'0101')),UNIX_TIMESTAMP(ADDDATE(DATE(CONCAT(DATE_FORMAT(`v_prev`,"%Y"),'0101')), INTERVAL 1 YEAR))),
	(DATE_FORMAT(`v_prev`,"%Y%m"),UNIX_TIMESTAMP(CONCAT(DATE_FORMAT(`v_prev`,"%Y%m"),'01')),UNIX_TIMESTAMP(ADDDATE(DATE(CONCAT(DATE_FORMAT(`v_prev`,"%Y%m"),'01')), INTERVAL 1 MONTH))),
	(CONCAT(DATE_FORMAT(`v_prev`,"%Y"),'Q',TRUNCATE(((MONTH(`v_prev`)+2)/3),0)),UNIX_TIMESTAMP(CONCAT(DATE_FORMAT(`v_prev`,"%Y"),LPAD(TRUNCATE(((MONTH(`v_prev`)+2)/3),0)*3-2,2,'0'),'01')),UNIX_TIMESTAMP(ADDDATE(DATE(CONCAT(DATE_FORMAT(`v_prev`,"%Y"),LPAD(TRUNCATE(((MONTH(`v_prev`)+2)/3),0)*3-2,2,'0'),'01')), INTERVAL 3 MONTH)));
	
	SET `v_prev`=ADDDATE(`v_prev`, INTERVAL 1 MONTH);

END WHILE;

# GET THE FILE UPDATE DATA

INSERT IGNORE INTO `mdl_elp_fileupdates` (`filekey`,`fileref`,`type`,`created`,`modified`,`filesize`,`logtime`)
SELECT SUBSTRING_INDEX(`filename`,'_',1),SUBSTRING_INDEX(`filename`,'.',1), SUBSTRING_INDEX(`filename`,'.',-1),MIN(`timecreated`), MAX(`timemodified`) , MAX(`filesize`),UNIX_TIMESTAMP()
FROM `mdl_files`
WHERE `filename` RLIKE '^EL[PV][0-9]{4}'
GROUP BY `filename`;

# CREATE THE HISTORY SUMMARY DATA

OPEN `cur1`;
cur_loop: LOOP
FETCH `cur1` INTO `v_period`,`v_startDate`,`v_endDate`;

IF `done` THEN
	LEAVE cur_loop;
END IF;

	DELETE FROM `mdl_elp_fileupdate_summaries` WHERE `yearmonth`=`v_period`;

	INSERT INTO `mdl_elp_fileupdate_summaries` (`yearmonth`, `filekey`,`fileref`, `scorm_created`, `scorm_updated`, 
	    `scorm_filesize`, `scorm_prevsize`, `pptx_created`, `pptx_updated`, `pptx_filesize`, `pptx_prevsize`, `pdf_created`, 
	    `pdf_updated`, `pdf_filesize`, `pdf_prevsize`)
	SELECT `v_period`,`filekey`,`fileref`,
	IFNULL(MIN(`u_scorm_created`),0) `scorm_created`,
	IFNULL(MAX(`u_scorm_updated`),0) `scorm_updated`,
	IFNULL(MAX(`u_scorm_filesize`),0) `scorm_filesize`,
	IFNULL(MAX(`u_scorm_prevsize`),0) `scorm_prevsize`,
	IFNULL(MIN(`u_pptx_created`),0) `pptx_created`,
	IFNULL(MAX(`u_pptx_updated`),0) `pptx_updated`,
	IFNULL(MAX(`u_pptx_filesize`),0) `pptx_filesize`,
	IFNULL(MAX(`u_pptx_prevsize`),0)`pptx_prevsize`,
	IFNULL(MIN(`u_pdf_created`),0) `pdf_created`,
	IFNULL(MAX(`u_pdf_updated`),0)  `pdf_updated`,
	IFNULL(MAX(`u_pdf_filesize`),0)  `pdf_filesize`,
	IFNULL(MAX(`u_pdf_prevsize`),0) `pptx_prevsize`
	FROM (
	SELECT `filekey`,`fileref`,
		`created` as 'u_scorm_created', `modified` as `u_scorm_updated`, `filesize` as `u_scorm_filesize`,Null as `u_scorm_prevsize`,
		Null as `u_pptx_created`,Null as `u_pptx_updated`,Null as `u_pptx_filesize`,Null as `u_pptx_prevsize`,
		Null as `u_pdf_created`,Null as `u_pdf_updated`,Null as `u_pdf_filesize`,Null as `u_pdf_prevsize`
	FROM `mdl_elp_fileupdates` `u`
	WHERE `type` = 'zip' AND `modified`=(SELECT MAX(`modified`)
				FROM `mdl_elp_fileupdates` 
				WHERE `type`='zip' AND `modified`<`v_endDate`  AND `modified`>=`v_startDate`
				AND `u`.`filekey`=`filekey`)
	
	UNION
	
	SELECT `filekey`,`fileref`,
		Null, Null,Null,Null,
		`created`,`modified`,`filesize`,Null,
		Null,Null,Null,Null
	FROM `mdl_elp_fileupdates` `u`
	WHERE `type` = 'pptx' AND `modified`=(SELECT MAX(`modified`)
				FROM `mdl_elp_fileupdates` 
				WHERE `type`='pptx' AND `modified`<`v_endDate`  AND `modified`>=`v_startDate`
				AND `u`.`filekey`=`filekey`)
	
	UNION
	
	SELECT `filekey`,`fileref`,
		Null,Null,Null,Null,
		Null,Null,Null,Null,
		`created`,`modified`,`filesize`,Null
	FROM `mdl_elp_fileupdates` `u`
	WHERE `type` = 'pdf' AND `modified`=(SELECT MAX(`modified`)
				FROM `mdl_elp_fileupdates` 
				WHERE `type`='pdf' AND `modified`<`v_endDate`  AND `modified`>=`v_startDate`
				AND `u`.`filekey`=`filekey`)
	
	UNION
	
	SELECT `filekey`,`fileref`,
		Null, Null, Null,`filesize`,
		Null,Null,Null,Null,
		Null,Null,Null,Null
	FROM `mdl_elp_fileupdates` `u`
	WHERE `type` = 'zip' AND `modified`=(SELECT MAX(`modified`)
				FROM `mdl_elp_fileupdates` 
				WHERE `type`='zip' AND `modified`<`v_startDate`
				AND `u`.`filekey`=`filekey`)
	
	UNION
	
	SELECT `filekey`,`fileref`,
		Null, Null,Null,Null,
		Null,Null,Null,`filesize`,
		Null,Null,Null,Null
	FROM `mdl_elp_fileupdates` `u`
	WHERE `type` = 'pptx' AND `modified`=(SELECT MAX(`modified`)
				FROM `mdl_elp_fileupdates` 
				WHERE `type`='pptx' AND `modified`<`v_startDate` 
				AND `u`.`filekey`=`filekey`)
	
	UNION
	
	SELECT `filekey`,`fileref`,
		Null, Null,Null,Null,
		Null,Null,Null,Null,
		Null,Null,Null,`filesize`
	FROM `mdl_elp_fileupdates` `u`
	WHERE `type` = 'pdf' AND `modified`=(SELECT MAX(`modified`) 
				FROM `mdl_elp_fileupdates` 
				WHERE `type`='pdf' AND `modified`<`v_startDate` 
				AND `u`.`filekey`=`filekey`)
	) `data`
	GROUP BY `filekey`
	HAVING `scorm_created` >=`v_startDate` OR
	`scorm_updated` >=`v_startDate` OR
	`pptx_created` >=`v_startDate` OR
	`pptx_updated` >=`v_startDate` OR
	`pdf_created` >=`v_startDate` OR
	`pdf_updated` >=`v_startDate`
	ORDER BY `filekey`;
	
END LOOP;

end;;
