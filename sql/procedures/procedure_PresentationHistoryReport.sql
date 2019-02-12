DELIMITER ;;
DROP PROCEDURE IF EXISTS `PresentationHistoryReport`;;
CREATE PROCEDURE `PresentationHistoryReport`(IN `p_period` varchar(6))
BEGIN

DECLARE `done` INT DEFAULT FALSE;
DECLARE `v_filekey` varchar(12) DEFAULT NULL;
DECLARE `v_fileref` longtext DEFAULT '';
DECLARE `v_scorm_size` bigint(10) DEFAULT NULL;
DECLARE `v_scorm_prevsize` bigint(10) DEFAULT NULL;
DECLARE `v_pptx_size` bigint(10) DEFAULT NULL;
DECLARE `v_pptx_prevsize` bigint(10) DEFAULT NULL;
DECLARE `v_pdf_size` bigint(10) DEFAULT NULL;
DECLARE `v_pdf_prevsize` bigint(10) DEFAULT NULL;
DECLARE `v_scorm_created` date DEFAULT NULL;
DECLARE `v_scorm_modified` date DEFAULT NULL;
DECLARE `v_pptx_created` date DEFAULT NULL;
DECLARE `v_pptx_modified` date DEFAULT NULL;
DECLARE `v_pdf_created` date DEFAULT NULL;
DECLARE `v_pdf_modified` date DEFAULT NULL;
DECLARE `i_scorm_created` bigint(10) DEFAULT NULL;
DECLARE `i_scorm_modified` bigint(10) DEFAULT NULL;
DECLARE `i_pptx_created` bigint(10) DEFAULT NULL;
DECLARE `i_pptx_modified` bigint(10) DEFAULT NULL;
DECLARE `i_pdf_created` bigint(10) DEFAULT NULL;
DECLARE `i_pdf_modified` bigint(10) DEFAULT NULL;

DECLARE `v_pageid` BIGINT(10) ;
DECLARE `v_linkid` BIGINT(10) ;
DECLARE `v_link` longtext  DEFAULT '';

DECLARE `v_column_head` longtext  DEFAULT '';
DECLARE `v_group_head` longtext  DEFAULT '';

DECLARE `v_month_name` longtext  DEFAULT '';
DECLARE `v_month_rep` longtext  DEFAULT '';
DECLARE `v_month_modified` longtext  DEFAULT '';
DECLARE `v_name` longtext  DEFAULT '';

DECLARE `v_startDate` DATE DEFAULT NULL;
DECLARE `v_endDate` DATE DEFAULT NULL;

DECLARE `v_isnewpres` BIGINT(10) ;
DECLARE `v_modid` longtext  DEFAULT '';
DECLARE `v_report` longtext  DEFAULT '';

DECLARE `v_created_text` longtext  DEFAULT '';
DECLARE `v_updated_text` longtext DEFAULT '';
DECLARE `v_minor_text` longtext DEFAULT '';

DECLARE `v_rows_created` longtext  DEFAULT '';
DECLARE `v_rows_updated` longtext  DEFAULT '';
DECLARE `v_rows_minor` longtext  DEFAULT '';

DECLARE `v_report_created` longtext  DEFAULT '';
DECLARE `v_report_updated` longtext  DEFAULT '';
DECLARE `v_report_minor` longtext  DEFAULT '';

DECLARE `v_sequence` longtext  DEFAULT '';

DECLARE `v_title` longtext  DEFAULT '';
DECLARE `v_visibility` tinyint(1) ;

# HTML CONSTANTS

DECLARE `v_table_start` text DEFAULT '<table class="elp-table"><thead/><tbody>';


DECLARE `v_tablehead_start` text DEFAULT '<tr><th colspan="2" class="elp-cellname"><p class="elp-main">';
DECLARE `v_headrow_start` text DEFAULT '<tr><th class="elp-cellname"><p class="elp-cellnametext">';
DECLARE `v_headrow_mid` text DEFAULT '</p></th><th class="elp-cellname"><p class="elp-cellnametext">';
DECLARE `v_headrow_end` text DEFAULT '</p></th></tr>';

DECLARE `v_datarow_start` text DEFAULT '<tr><td class="elp-cellname"><div class="elp-valuetext">';
DECLARE `v_datarow_start_merged` text DEFAULT '<tr><td colspan="2" class="elp-cellname"><div class="elp-valuetext">';

DECLARE `v_datarow_mid` text DEFAULT '</div></td><td class="elp-cellname"><div class="elp-valuetext">';
DECLARE `v_datarow_end` text DEFAULT '</div></td></tr>';

DECLARE `v_table_end` text DEFAULT  '</tbody></table>';

# SERVER CONSTANTS
DECLARE `v_serverURL` text DEFAULT 'https://elearning.ihtsdotools.org';
DECLARE `v_course` bigint(10) DEFAULT 22;
DECLARE `v_section` bigint(10) DEFAULT 99; 

DECLARE `cur1` CURSOR FOR SELECT `s`.`filekey`,`s`.`fileref`, `scorm_created`,`scorm_updated` ,`scorm_filesize`,`scorm_prevsize`,`pptx_created`, `pptx_updated`,`pptx_filesize`,`pptx_prevsize`,`pdf_created`,`pdf_updated`,`pdf_filesize`,`pdf_prevsize`
	FROM `mdl_elp_fileupdate_summaries` `s` WHERE `yearmonth` = `p_period` ORDER BY `s`.`scorm_updated`;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` = TRUE;


IF `p_period`='' THEN
	SET `p_period`=DATE_FORMAT(Now(),"%Y%m");
	SET `v_startDate`=DATE(CONCAT(DATE_FORMAT(Now(),"%Y%m"),'01'));
	SET `v_endDate`=ADDDATE(DATE(CONCAT(DATE_FORMAT(Now(),"%Y%m"),'01')), INTERVAL 1 MONTH);

ELSEIF `p_period` rlike '^[0-9]{6}$' THEN
	
	SET `v_startDate`=CONCAT(`p_period`,'01');
	SET `v_endDate`=ADDDATE(`v_startDate`, INTERVAL 1 MONTH);

ELSEIF `p_period` rlike '^[0-9]{4}$' THEN
	
	SET `v_startDate`=CONCAT(`p_period`,'0101');
	SET `v_endDate`=ADDDATE(`v_startDate`, INTERVAL 1 YEAR);

ELSEIF `p_period` rlike '^[0-9]{4}Q[1-4]$' THEN
	
	SET `v_startDate`=CONCAT(LEFT(`p_period`,4),LPAD(RIGHT(`p_period`,1)*3-2,2,'0'),'01');
	SET `v_endDate`=ADDDATE(`v_startDate`, INTERVAL 3 MONTH);

END IF;

OPEN `cur1`;
cur_loop: LOOP
	FETCH `cur1` INTO `v_filekey`,`v_fileref`, `i_scorm_created`, `i_scorm_modified`, `v_scorm_size`, 
	`v_scorm_prevsize`, `i_pptx_created`, `i_pptx_modified`, `v_pptx_size`, `v_pptx_prevsize`, `i_pdf_created`, `i_pdf_modified`,`v_pdf_size`,`v_pdf_prevsize`;	
	
	IF `done` THEN
		LEAVE cur_loop;
	END IF;
	
	SET `v_scorm_created`=IF(`i_scorm_created`=0,NULL,FROM_UNIXTIME(`i_scorm_created`));
	SET `v_scorm_modified`=IF(`i_scorm_modified`=0,NULL,FROM_UNIXTIME(`i_scorm_modified`));
	SET `v_pptx_created`=IF(`i_pptx_created`=0,NULL,FROM_UNIXTIME(`i_pptx_created`));
	SET `v_pptx_modified`=IF(`i_pptx_modified`=0,NULL,FROM_UNIXTIME(`i_pptx_modified`));
	SET `v_pdf_created`=IF(`i_pdf_created`=0,NULL,FROM_UNIXTIME(`i_pdf_created`));
	SET `v_pdf_modified`=IF(`i_pdf_modified`=0,NULL,FROM_UNIXTIME(`i_pdf_modified`));
	
	SET `v_isnewpres` = 0; 
	SET `v_title` = (SELECT `title` FROM `mdl_elp_metadata` WHERE `filekey` = `v_filekey`);
	SET `v_title` = IF(`v_title` IS NULL OR `v_title`='',`v_fileref`,`v_title`);
		
	SET `v_linkid`=(SELECT MIN(`id`) FROM `mdl_course_modules` WHERE `course`=`v_course` AND `module`=15 AND SUBSTRING_INDEX(`idnumber`,'/',-1)=`v_filekey`);
	
	IF `v_linkid` IS NULL THEN
		SET `v_link`='';
	ELSE	
		SET `v_link`=CONCAT(`v_serverURL`,"/mod/page/view.php?id=",`v_linkid`);
	END IF;
	
# DETECT AMD PROCESS NEWLY CREATED ITEMS

	IF ((`v_scorm_created`>=`v_scorm_modified` AND `v_scorm_prevsize` = 0) AND (`v_scorm_size` != 0)) THEN
		SET `v_scorm_modified`=0;
	END IF;

	IF (`v_scorm_created`>=`v_startDate` and `v_scorm_created`<`v_endDate`) THEN
		SET `v_isnewpres` = 1;	
		SET `v_created_text` = CONCAT(`v_datarow_start`, IF(`v_link` = "", `v_title`, CONCAT('<a href="', `v_link`,'">', `v_title`, '</a>')), `v_datarow_mid`, `v_scorm_created`,`v_datarow_end`);
		SET `v_rows_created` = concat(`v_rows_created`, `v_created_text`);	
		
	END IF;	


# DETECT AMD PROCESS UPDATED ITEMS

	SET `v_month_modified` = (select month(`v_scorm_modified`));
	SET `v_month_rep` = (select MONTH(concat(`p_period`,11)));
	
	IF (`v_scorm_modified`>=`v_startDate` and `v_scorm_modified`<`v_endDate`) 
		AND (`v_isnewpres` = 0) AND ((ABS(`v_scorm_size` - `v_scorm_prevsize`) > 0 ) 
		OR (ABS(`v_pdf_size` - `v_pdf_prevsize`) > 0)) THEN
			SET `v_updated_text` = CONCAT(`v_datarow_start`, IF(`v_link` = "", `v_title`, CONCAT('<a href="', `v_link`,'">', `v_title`, "</a>")),`v_datarow_mid`, `v_scorm_modified`,`v_datarow_end`);
			SET `v_rows_updated` = concat(`v_rows_updated`, `v_updated_text`);	

	END IF;

END LOOP;

SET `v_group_head` = CONCAT(`v_tablehead_start`,"New Presentations",`v_headrow_end`);	
IF (`v_rows_created` = "") THEN
	SET `v_report_created` = CONCAT(`v_group_head`,`v_datarow_start_merged`,"There are no new presentations.",`v_datarow_end`);
ELSE
	SET `v_column_head` = CONCAT(`v_headrow_start`,"Presentation",`v_headrow_mid`,"Presentation Created",`v_headrow_end`);
	SET `v_report_created` = CONCAT(`v_group_head`,`v_column_head`, `v_rows_created`);
END IF;

SET `v_group_head` = CONCAT(`v_tablehead_start`,"Updated Presentations",`v_headrow_end`);	
IF (`v_rows_updated` = "") THEN
	SET `v_report_updated` = CONCAT(`v_group_head`,`v_datarow_start_merged`,"There are no presentations with significant updates.",`v_datarow_end`);
ELSE
	SET `v_column_head` = CONCAT(`v_headrow_start`,"Presentation",`v_headrow_mid`,"Presentation Updated",`v_headrow_end`);
	SET `v_report_updated` = CONCAT(`v_group_head`,`v_column_head`, `v_rows_updated`);
END IF;

SET `v_group_head` = CONCAT(`v_tablehead_start`,"Presentations with Minor Updates",`v_headrow_end`);	
IF (`v_rows_minor` = "") THEN
	SET `v_report_minor` = CONCAT(`v_group_head`,`v_datarow_start_merged`,"There are no presentations with minor updates.",`v_datarow_end`);
ELSE
	SET `v_column_head` = CONCAT(`v_headrow_start`,"Presentation",`v_headrow_mid`,"Presentation Updated",`v_headrow_end`);
	SET `v_report_minor` = CONCAT(`v_group_head`,`v_column_head`, `v_rows_minor`);
END IF;

SET `v_report` = concat(`v_table_start`,`v_report_created`, `v_report_updated`, `v_table_end`);
SET `v_visibility` = 1; 
SET `v_month_name` = (select MONTHNAME(concat(`p_period`,11)));
SET `v_name` = concat("Presentations Update Report for ", `v_month_name`, " ", SUBSTRING(`p_period`, 1, 4));

UPDATE `mdl_course_modules`
	SET `showdescription` = 0
	WHERE `course` = v_course AND `module`= 15 AND 'section' = `v_section`;
	
SET `v_modid` = AddOrUpdatePage(-1,`v_course`, `v_section`, concat("report_",`p_period`), `v_report`, `v_visibility`, 0,`v_name`);

SET `v_pageid`= (select `instance` FROM `mdl_course_modules` WHERE id = `v_modid`);

UPDATE `mdl_page` SET 
	`intro` = SUBSTRING_INDEX(`content`,'</h3>',-1),
	`content`=CONCAT('<h3>',`v_name`,'</h3>',`content`)
	WHERE `id`= `v_pageid`;

UPDATE `mdl_course_modules` SET 
	`showdescription` =  1 WHERE `id` = `v_modid`;

SET `v_sequence` = (select `sequence` FROM `mdl_course_sections` WHERE `course`=`v_course` AND `id`= `v_section`);

UPDATE `mdl_course_sections` SET
	`sequence` = concat(`v_modid`,",",`v_sequence`)
	WHERE `course`=`v_course` AND `id`= `v_section`
	AND FIND_IN_SET(`v_modid`,`v_sequence`)=0;
END;;
