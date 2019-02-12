DELIMITER ;;
DROP PROCEDURE IF EXISTS `UpdatePublicMetadataPages`;;
CREATE PROCEDURE `UpdatePublicMetadataPages`()
BEGIN
DECLARE code CHAR(5) DEFAULT '00000';
DECLARE msg  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_courseid` bigint(10);
DECLARE `v_section_id` bigint(10);
DECLARE `v_module_id` bigint(10);
DECLARE `v_module_title`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_sequence` longtext DEFAULT '';
DECLARE `v_visible` tinyint(1) DEFAULT 1;
DECLARE `v_indent` smallint(3) DEFAULT 1;
DECLARE `v_html`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_html_rev`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_html_rev2`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_html_final`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_html_lastrow`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_modtype` varchar(20) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_linkid` varchar(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_link`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_id` bigint(10);
DECLARE `v_pdf` varchar(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_vid` varchar(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_svr` varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_updated` varchar(20) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_key` varchar(100) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_viewbutton`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_storebutton`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_nullbutton`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_courses`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_reference` varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_filekey` varchar(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_done` BOOLEAN DEFAULT FALSE;

DECLARE cur CURSOR FOR SELECT `fileref`, `title`,`metadata` FROM `mdl_elp_metadata` WHERE `filekey` regexp '^EL.[0-9]{4}[a-z]{0,2}' ORDER BY `filekey`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `v_done` := TRUE;

SET `v_courseid`=22; 
SET `v_section_id`=128; 

SET `v_viewbutton`='<div style="clear: both; display: table; margin-top: 10px;">
<div style="float: left; width: 160px;"><a class="btn btn-primary" href="https://elearning.ihtsdotools.org/mod/$MODTYPE$/view.php?id=$MODID$">View Presentation</a>
</div><div style="float: left; width: 70%;">You may be prompted to login or create an account before you view this presentation.  You will then have access to all Open Access presentations.</div></div>';

SET `v_storebutton`='<div style="clear: both; display: table; margin-top: 10px;">
<div style="float: left; width: 70%;">Currently the presentation only available as part of one of the following courses.<ul>$COURSES$</ul></div></div><div style="float: left; width: 160px;"><a class="btn btn-primary" href="https://courses.ihtsdotools.org/">Course Catalogue</a>
</div>';

SET `v_nullbutton`='<div style="clear: both; display: table; margin-top: 10px;">
<div style="float: left; width: 70%;">The presentation is not currently available. It may be under development or revision.
</div>';

SET `v_pdf`=(SELECT `value` FROM `mdl_elp_lookup` WHERE `group`='meta_info' AND `item`='pdf_folder');
SET `v_vid`=(SELECT `value` FROM `mdl_elp_lookup` WHERE `group`='meta_info' AND `item`='video_folder');
SET `v_svr`=(SELECT `value` FROM `mdl_elp_lookup` WHERE `group`='meta_info' AND `item`='server');
SET `v_updated`=(SELECT DATE_FORMAT(NOW(),'%Y-%m-%d'));


DROP TABLE IF EXISTS `tmp_elp_warnings`;
CREATE TEMPORARY TABLE `tmp_elp_warnings` (
  `filekey` varchar(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `title` varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
   PRIMARY KEY (`filekey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `tmp_elp_filedate`;
CREATE TABLE `tmp_elp_filedate` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `filekey` varchar(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `modified` varchar(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
   PRIMARY KEY (`id`),
   KEY `tmp_fdk_ix` (`filekey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tmp_elp_filedate` (`filekey`,`modified`)
SELECT SUBSTRING_INDEX(`filename`,'_',1),DATE_FORMAT(FROM_UNIXTIME(max(`timemodified`)),'%Y-%m-%d') FROM `mdl_files`
WHERE `filename` regexp '^el[pv][0-9]{4}.*\.(zip|mp4)$'
GROUP BY `filename`;

SET `v_done`=FALSE;

OPEN cur;

pageLoop: LOOP
    FETCH cur INTO `v_reference`,`v_module_title`,`v_html`;
    IF `v_done` THEN
      LEAVE pageLoop;
    END IF;
	
	SET `v_filekey`=SUBSTRING_INDEX(`v_reference`,'_',1);
	

	SET `v_updated`=(SELECT MAX(`modified`) FROM `tmp_elp_filedate` WHERE `filekey`=`v_filekey`);
	SET `v_html_rev`=REPLACE(REPLACE(REPLACE(REPLACE(`v_html`,"$VID$",`v_vid`),
		"$SVR$",`v_svr`),"$PDF$",`v_pdf`),"$UPDATED$",`v_updated`);
	SET `v_key`=CONCAT('metadata/',UPPER(SUBSTRING_INDEX(`v_reference`,'_',1)));
	SET `v_modtype`=IF(`v_reference` regexp '^elp[0-9]{4}','scorm','page');
	
	IF `v_modtype`='scorm' THEN 
		SET `v_html_lastrow`=CONCAT('<tr',SUBSTRING_INDEX(LEFT(`v_html_rev`,INSTR(`v_html_rev`,'</tbody>')-1),'<tr',-1));
		SET `v_html_rev2` = REPLACE(`v_html_rev`,`v_html_lastrow`,'');
		
		SET `v_linkid`=(SELECT MIN(`id`) FROM `mdl_course_modules` WHERE `course`=`v_courseid` AND SUBSTRING_INDEX(`idnumber`,'/',-1)=SUBSTRING_INDEX(`v_key`,'/',-1) AND `module`=18);
		IF ISNULL(`v_linkid`) THEN
	
			set `v_courses`=(SELECT CONCAT('<li>',GROUP_CONCAT(CONCAT('<a href="https://elearning.ihtsdotools.org/course/view.php?id=',`c`.`id`,'" target="_blank">',`c`.`shortname`,'</a>') separator '</li><li>'),'</li>')
				FROM `mdl_course` `c`
				JOIN `mdl_course_modules` `m` ON `c`.`id`=`m`.`course`
				WHERE `m`.`module` IN (12,18) and `m`.`course`!=`v_courseid`  and SUBSTRING_INDEX(`m`.`idnumber`,'/',-1) = `v_filekey`);
			set `v_link`=REPLACE(`v_storebutton`,'$COURSES$',`v_courses`);
		ELSE
	
			SET `v_link`=REPLACE(REPLACE(`v_viewbutton`,'$MODTYPE$',`v_modtype`),'$MODID$',`v_linkid`);
		END IF;
		IF ISNULL(`v_link`) THEN
			SET `v_link`=`v_nullbutton`;
		END IF;	
		
		SET `v_html_final`=CONCAT(`v_html_rev2`,`v_link`);
	ELSE
		SET `v_html_final`=`v_html_rev`;
	END IF;

IF ISNULL(`v_html_final`) THEN
	INSERT IGNORE INTO `tmp_elp_warnings` (`filekey`,`title`) VALUES (`v_filekey`,`v_module_title`);
ELSE
	SET `v_module_id`=AddOrUpdatePage(-1,`v_courseid`, `v_section_id`,`v_key`, `v_html_final`, `v_visible`, `v_indent`,`v_module_title`);

	SET `v_sequence`=CONCAT(`v_sequence`,',',`v_module_id`);
END IF;
	
END LOOP pageLoop;

UPDATE `mdl_course_sections`
	SET `sequence`=SUBSTRING(`v_sequence`,2)
	WHERE `id`=`v_section_id`;

# SELECT 'AFTER' info,`sequence` FROM `mdl_course_sections` WHERE `id`=`v_section_id`;
	
# SELECT 'Public Page not created for' `message`,`filekey`,`title` FROM `tmp_elp_warnings` ORDER BY `filekey`;
	
DROP TABLE IF EXISTS `tmp_elp_filedate`;
DROP TABLE IF EXISTS `tmp_elp_warnings`;


END;;
