DELIMITER ;;
DROP PROCEDURE IF EXISTS `UpdateMetadata` ;;
CREATE PROCEDURE `UpdateMetadata`()
begin

DECLARE v_PDF varchar(10);
DECLARE v_VID varchar(10);
DECLARE v_SVR varchar(255);


SET v_PDF=(SELECT `value` FROM `mdl_elp_lookup` WHERE `group`='meta_info' AND `item`='pdf_folder');
SET v_VID=(SELECT `value` FROM `mdl_elp_lookup` WHERE `group`='meta_info' AND `item`='video_folder');
SET v_SVR=(SELECT `value` FROM `mdl_elp_lookup` WHERE `group`='meta_info' AND `item`='server');

UPDATE `mdl_page` `p`, `mdl_elp_metadata` `t`,`mdl_course_modules` `m`, `mdl_course_sections` `s`
SET 
`p`.`name`=`t`.`title`,
`p`.`content`= REPLACE(REPLACE(REPLACE(REPLACE(`t`.`metadata`,"$VID$",v_VID),"$SVR$",v_SVR),"$PDF$",v_PDF),"$CMID$",`m`.`id`),
`p`.`displayoptions`='a:2:{s:12:"printheading";s:1:"0";s:10:"printintro";s:1:"0";}',
`p`.`timemodified`=unix_timestamp(),
`m`.`completion`=2,
`m`.`completionview`=1,
`m`.`idnumber`=concat('vid_',replace(LOWER(IFNULL(`s`.`name`,`s`.`id`)),' ','-'),'/',substring_index(`t`.`fileref`,'_',1))
WHERE `t`.`filekey` regexp 'ELV[0-9]{4}[a-z]{0,2}'  AND `t`.`title`!=''
    AND (`m`.`idnumber` regexp concat('(^|/|_)?',substring_index(`t`.`fileref`,'_',1),'(_.*)?$')
       OR `p`.`name` regexp concat('(^|/|_)',substring_index(`t`.`fileref`,'_',1),'(_.*)$'))
   AND (`m`.`module`=15 AND `m`.`instance`=`p`.`id` AND `s`.`id`=`m`.`section` and `s`.`course`=`m`.`course`);

UPDATE `mdl_scorm` `sc`,`mdl_elp_metadata` `t`,`mdl_course_modules` `m`, `mdl_course_sections` `s`
SET 
`sc`.`name`=`t`.`title`,
`sc`.`intro`=REPLACE(REPLACE(`t`.`metadata`,"$PDF$",v_PDF),"$SVR$",v_SVR),
`m`.`idnumber`=concat('scorm_',replace(LOWER(IFNULL(`s`.`name`,`s`.`id`)),' ','-'),'/',substring_index(`t`.`fileref`,'_',1))
WHERE `t`.`filekey` regexp 'ELP[0-9]{4}[a-z]{0,2}'  AND `t`.`title`!=''
   AND (`m`.`idnumber` regexp concat('(^|/|_)',substring_index(`t`.`fileref`,'_',1),'(_.*)?$') 
       OR `sc`.`reference` regexp concat('(^|/|_)',substring_index(`t`.`fileref`,'_',1),'(_.*)?$'))
   AND (`m`.`module`=18 AND `m`.`instance`=`sc`.`id` AND `s`.`id`=`m`.`section` and `s`.`course`=`m`.`course`);

DROP TABLE IF EXISTS `tmp_elp_filedate`;
CREATE TEMPORARY TABLE `tmp_elp_filedate` (
   `filekey` varchar(12) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `updated` bigint(10) NOT NULL,
  PRIMARY KEY (`filekey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `tmp_elp_filedate` (`filekey`,`filename`,`updated`)
SELECT SUBSTRING_INDEX(`filename`,'_',1),`filename`,max(`timemodified`) FROM `mdl_files`
WHERE `filename` regexp '^elp[0-9]{4}[a-z]{0,2}_.*\.zip$'
GROUP BY `filename`;


UPDATE `mdl_scorm` `s`,  `tmp_elp_filedate` `fd`
SET `s`.`intro`=REPLACE(`s`.`intro`,"$UPDATED$",DATE_FORMAT(FROM_UNIXTIME(`fd`.`updated`),'%Y-%m-%d'))
WHERE `fd`.`filename` = `s`.`reference`;

DROP TABLE IF EXISTS `tmp_elp_filedate`;



UPDATE `mdl_scorm` `sc`
SET `sc`.`name`=MID(`sc`.`name`,LOCATE(')',`sc`.`name`)+2)
WHERE `sc`.`name` regexp '^[1-9][0-9]?\\)' AND `sc`.`course` IN (2,3,16);

UPDATE `mdl_scorm` `sc`,
(SELECT `s`.`id`,group_concat(`sc`.`id` ORDER BY find_in_set(`m`.`id`,`s`.`sequence`) SEPARATOR ',') `scseq`
FROM `mdl_course_sections` `s`
JOIN `mdl_course_modules` `m` ON `m`.`course`= `s`.`course` AND `m`.`section`= `s`.`id`
JOIN `mdl_scorm` `sc` ON `sc`.`id`=`m`.`instance`
WHERE `s`.`course` IN (2,3,16) AND `m`.`module`=18 AND `s`.`section`>0
GROUP BY `s`.`id`
ORDER BY `s`.`course`,`s`.`section`, find_in_set(`m`.`id`,`s`.`sequence`)) `sp` 
SET `sc`.`name`=CONCAT(find_in_set(`sc`.`id`,`sp`.`scseq`),') ', `sc`.`name`)
WHERE  find_in_set(`sc`.`id`,`sp`.`scseq`)>0;

end;;