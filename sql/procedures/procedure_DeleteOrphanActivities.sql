DELIMITER ;;
DROP PROCEDURE IF EXISTS `DeleteOrphanActivities`;;
CREATE PROCEDURE `DeleteOrphanActivities`()
begin

DROP TABLE IF EXISTS `tmp_orphan_pages`;
DROP TABLE IF EXISTS `tmp_orphan_labels`;
DROP TABLE IF EXISTS `tmp_orphan_scorm`;

select `pg`.`id`,`pg`.`name`,`m`.`id`,from_unixtime(`pg`.`timemodified`),`m`.`section`,`s`.`id`,FIND_IN_SET(`m`.`id`,`s`.`sequence`)<>0
FROM `mdl_page` `pg`
LEFT OUTER JOIN `mdl_course_modules` `m` ON `m`.`instance`=`pg`.`id` AND `m`.`module`=15
LEFT OUTER JOIN  `mdl_course_sections` `s` ON `s`.`id`=`m`.`section`
WHERE FIND_IN_SET(`m`.`id`,`s`.`sequence`)=0 OR ISNULL(`m`.`id`)
ORDER BY `pg`.`name`;

CREATE TEMPORARY TABLE `tmp_orphan_pages`
(
`pageid` bigint(10) not null, `moduleid` bigint(10)
);

INSERT INTO tmp_orphan_pages(`pageid`,`moduleid`)
select `pg`.`id` ,`m`.`id`
FROM `mdl_page` `pg`
LEFT OUTER JOIN `mdl_course_modules` `m` ON `m`.`instance`=`pg`.`id` AND `m`.`module`=15
LEFT OUTER JOIN  `mdl_course_sections` `s` ON `s`.`id`=`m`.`section` 
WHERE FIND_IN_SET(`m`.`id`,`s`.`sequence`)=0 OR ISNULL(`m`.`id`);

DELETE FROM `mdl_course_modules`
WHERE `id` in (SELECT`moduleid` FROM `tmp_orphan_pages`);

DELETE FROM `mdl_page`
WHERE `id` in (SELECT `pageid` FROM `tmp_orphan_pages`);

#LABELS

select `lb`.`id`,lb.intro,`m`.`id`,from_unixtime(`lb`.`timemodified`),`m`.`section`,`s`.`id`,FIND_IN_SET(`m`.`id`,`s`.`sequence`)<>0,s.sequence
FROM `mdl_label` `lb`
LEFT OUTER JOIN `mdl_course_modules` `m` ON `m`.`instance`=`lb`.`id` AND `m`.`module`=12
LEFT OUTER JOIN  `mdl_course_sections` `s` ON `s`.`id`=`m`.`section`
WHERE FIND_IN_SET(`m`.`id`,`s`.`sequence`)=0 OR ISNULL(`m`.`id`)
ORDER BY `lb`.`name`;

CREATE TEMPORARY TABLE `tmp_orphan_labels`
(
`labelid` bigint(10) not null, `moduleid` bigint(10)
);

INSERT INTO `tmp_orphan_labels`(labelid,moduleid)
select `lb`.`id`,`m`.`id`
FROM `mdl_label` `lb`
LEFT OUTER JOIN `mdl_course_modules` `m` ON `m`.`instance`=`lb`.`id` AND `m`.`module`=12
LEFT OUTER JOIN  `mdl_course_sections` `s` ON `s`.`id`=`m`.`section` 
WHERE FIND_IN_SET(`m`.`id`,`s`.`sequence`)=0 OR ISNULL(`m`.`id`);

DELETE FROM `mdl_course_modules`
WHERE `id` in (SELECT`moduleid` FROM `tmp_orphan_labels`);

DELETE FROM `mdl_label`
WHERE `id` in (SELECT `labelid` FROM `tmp_orphan_labels`);

#SCORM

select sc.`id`,sc.intro,`m`.`id`,from_unixtime(`sc`.`timemodified`),`m`.`section`,`s`.`id`,FIND_IN_SET(`m`.`id`,`s`.`sequence`)<>0,s.sequence
FROM mdl_scorm sc
LEFT OUTER JOIN `mdl_course_modules` `m` ON `m`.`instance`=sc.`id` AND `m`.`module`=18
LEFT OUTER JOIN  `mdl_course_sections` `s` ON `s`.`id`=`m`.`section`
WHERE FIND_IN_SET(`m`.`id`,`s`.`sequence`)=0 OR ISNULL(`m`.`id`)
ORDER BY sc.`name`;

CREATE TEMPORARY TABLE `tmp_orphan_scorm`
(
`scormid` bigint(10) not null, `moduleid` bigint(10)
);

INSERT INTO `tmp_orphan_scorm`(`scormid`,`moduleid`)
select `sc`.`id` ,`m`.`id`
FROM `mdl_scorm` `sc`
LEFT OUTER JOIN `mdl_course_modules` `m` ON `m`.`instance`=`sc`.`id` AND `m`.`module`=`18`
LEFT OUTER JOIN  `mdl_course_sections` `s` ON `s`.`id`=`m`.`section` 
WHERE FIND_IN_SET(`m`.`id`,`s`.`sequence`)=0 OR ISNULL(`m`.`id`);

DELETE FROM `mdl_course_modules`
WHERE `id` in (SELECT`moduleid` FROM `tmp_orphan_scorm`);

DELETE FROM `mdl_scorm`
WHERE `id` in (SELECT `scormid` FROM `tmp_orphan_scorm`);

DROP TABLE IF EXISTS `tmp_orphan_pages`;
DROP TABLE IF EXISTS `tmp_orphan_labels`;
DROP TABLE IF EXISTS `tmp_orphan_scorm`;

end;;
