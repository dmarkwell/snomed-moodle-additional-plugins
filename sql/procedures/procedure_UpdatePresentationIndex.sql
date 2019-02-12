DROP PROCEDURE IF EXISTS `UpdatePresentationIndex`;;
CREATE PROCEDURE `UpdatePresentationIndex`()
BEGIN
DECLARE `v_done` INT DEFAULT FALSE;
DECLARE `v_typ` varchar(16) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_num` bigint(10) DEFAULT NULL;
DECLARE `v_courseid` bigint(10) DEFAULT NULL;
DECLARE `v_ref` varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_rows_public`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_rows_login`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_table_head`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_table_end`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_output_public`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_output_login`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_ch_name`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_out_tmp_public`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_out_tmp_login`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_out_tmp`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_pres_key`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_page_id` BIGINT(10);
DECLARE `v_scorm_id` BIGINT(10);
DECLARE `v_page_url`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_scorm_url`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_server`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_description_text`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_row_start`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_row_end`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_alink`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
DECLARE `v_public_labelid` BIGINT(10);
DECLARE `v_login_labelid` BIGINT(10);

DECLARE `cur1` CURSOR FOR SELECT `t1`.`pagenum`,`t1`.`modtype`, `t1`.`modid`, `t1`.`reference`
		FROM `tmp_chapter_out` `t1` order by `pagenum`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `v_done` = TRUE;

# VARIABLES THAT SHOULD REALLY BE FROM CONFIGURATION DATA
SET `v_public_labelid`=440;
SET `v_login_labelid`=445;
SET `v_courseid`=22;

# HTML FRAGMENTS
SET `v_row_start`='<tr><td class="elp-cellvalue"><div class="elp-valuetext">';
SET `v_row_end`='</div></td></tr>';
SET `v_alink`='<a href="$URL$">$TEXT$</a>';

CREATE TEMPORARY TABLE `tmp_chapter_data`
(
`modtype` varchar(16),`modid` bigint(10),`section` bigint(10),`name` varchar(255), `pos` bigint(10), `reference` varchar(255), `text` longtext, `scoid` bigint(10)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TEMPORARY TABLE `tmp_chapter_out`
(
`pagenum`bigint(10) not null auto_increment, `modtype` varchar(16),`modid` bigint(10),`section` bigint(10),`name` varchar(255), `pos` bigint(10), `reference` varchar(255),`text` longtext, primary key (`pagenum`), `scoid` bigint(10)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tmp_chapter_data` (`modtype`,`modid`,`section`,`name`,`pos`,`text`)
SELECT 'section',0,`section`,`name`,0,`summary` 
FROM `mdl_course_sections`
WHERE `course`=`v_courseid` and `section`>0;



INSERT INTO `tmp_chapter_data` (`modtype`,`modid`,`section`,`name`,`pos`, `reference`,`text`, `scoid`)
SELECT 'scorm',`m`.`id`,`s`.`section`,`sc`.`name`,FIND_IN_SET(`m`.`id`,`s`.`sequence`), SUBSTRING_INDEX(`sc`.`reference`,'.',1),
	SUBSTRING_INDEX( MID(`sc`.`intro`, INSTR(`sc`.`intro`, 'class="elp-cellvalue"')+22),'</td>',1),`ss`.`id`
	FROM `mdl_course_sections` `s`
	JOIN `mdl_course_modules` `m` ON FIND_IN_SET(`m`.`id`,`s`.`sequence`) !=0
	JOIN `mdl_scorm` `sc` ON `sc`.`id`=`m`.`instance` AND `m`.`module`=18
	JOIN `mdl_scorm_scoes` `ss` ON `ss`.`scorm` = `sc`.`id` AND `ss`.`scormtype` = 'sco'
	WHERE `s`.`course`=`v_courseid`;


INSERT INTO `tmp_chapter_out` (`modtype`,`modid`,`section`,`name`, `pos`, `reference`,`text`, `scoid`)
SELECT `modtype`,`modid`,`section`,`name`, `pos`, `reference`,`text`, `scoid` FROM `tmp_chapter_data`
ORDER BY `section`,`pos`;
	
  OPEN `cur1`;

	cur_loop: LOOP
	FETCH `cur1` INTO `v_num`,`v_typ`,`v_scorm_id`, `v_ref`;
	
	set `v_ch_name` = (select `name`from `tmp_chapter_out` where `pagenum`=`v_num`);
	
	IF `v_done` THEN
		LEAVE cur_loop;
	END IF;
	
	IF `v_typ` = "scorm"  THEN
		SET `v_pres_key` = SUBSTRING_INDEX(`v_ref`, '_', 1);
		SET `v_page_id`=(SELECT MIN(`id`) FROM `mdl_course_modules` WHERE `course`=`v_courseid` AND `module`=15 AND SUBSTRING_INDEX(`idnumber`,'/',-1)=`v_pres_key`);
		SET `v_page_url`=CONCAT(`v_server`,'/mod/page/view.php?id=',`v_page_id`);
		SET `v_scorm_url`=CONCAT(`v_server`,'/mod/scorm/view.php?id=',`v_scorm_id`);
		SET `v_description_text` = (select `text`from `tmp_chapter_out` where `pagenum`= `v_num`);
		SET `v_out_tmp_public` = CONCAT(`v_row_start`,replace(replace(`v_alink`,'$URL$',`v_page_url`),'$TEXT$', `v_ch_name`), `v_description_text`, `v_row_end`);
		SET `v_out_tmp_login` = CONCAT(`v_row_start`,replace(replace(`v_alink`,'$URL$',`v_scorm_url`),'$TEXT$', `v_ch_name`), `v_description_text`, `v_row_end`);
		SET `v_rows_public` = CONCAT(`v_rows_public`, `v_out_tmp_public`);	
		SET `v_rows_login` = CONCAT(`v_rows_login`, `v_out_tmp_login`);
	END IF;
	
	
	IF `v_typ` = "section" AND `v_ch_name` != "Handouts" THEN
		SET `v_out_tmp` = CONCAT(`v_row_start`,'<p class="elp-sub">',`v_ch_name`,'</p>',`v_row_end`);
		SET `v_rows_public` = CONCAT(`v_rows_public`, `v_out_tmp`);	
		SET `v_rows_login` = CONCAT(`v_rows_login`, `v_out_tmp`);
	END IF;	
END LOOP;

SET `v_table_head` = '<table class="elp-table"><thead><tr><th class="elp-cellname"><p class="elp-main">Presentations</p></th></tr></thead><tbody>';
SET `v_table_end` = '</tbody></table>';


SET `v_output_public` = CONCAT(`v_table_head`, `v_rows_public`, `v_table_end` );
SET `v_output_login` = CONCAT(`v_table_head`, `v_rows_login`, `v_table_end` );

UPDATE `mdl_label` SET
	`intro` = `v_output_public`,
	`timemodified` = UNIX_TIMESTAMP()
	WHERE `id` = `v_public_labelid`;



UPDATE `mdl_label` SET
	`intro` = `v_output_login`,
	`timemodified` = UNIX_TIMESTAMP()
	WHERE `id` = `v_login_labelid`;


UPDATE `mdl_course_sections`
	SET `summary`=replace(`summary`,concat('section=',SUBSTRING_INDEX(SUBSTRING_INDEX(`summary`,'section=',-1),'#',1),'#'),concat('section=',`section`,'#'))
	WHERE `summary` REGEXP concat('id=',`course`,'&(amp;)?section=[0-9]+#') AND `summary` NOT REGEXP concat('id=',`course`,'&(amp;)?section=',`section`,'#');


DROP TABLE  `tmp_chapter_data`;
DROP TABLE  `tmp_chapter_out`;

END;;
