DELIMITER ;;
DROP PROCEDURE IF EXISTS `AddScormFiles`;;
CREATE PROCEDURE `AddScormFiles`(IN `i_module_id` bigint(10))
proc:begin
declare `v_scorm_id` bigint(10) default 0;
declare `v_sco_id` bigint(10) default 0;
declare `v_module_id` bigint(10) default 0;
declare `v_context_id` bigint(10) default 0;
declare `v_prev_context_id` bigint(10) default 0;
declare `v_subsection_id` bigint(10) default 0;
declare `v_prev_scorm_id` bigint(10) default 0;
declare `v_prev_sco_id` bigint(10) default 0;
declare `v_filename` varchar(255) default '';
declare `v_count` int(6) default 0;
declare `v_fcount` int(6) default 0;


SET `v_count`=(SELECT COUNT(`id`) FROM `mdl_course_modules` WHERE `id`=`i_module_id` AND `module`=18);
IF `v_count`=0 THEN
	SELECT "NOT A SCORM ACTIVITY";
        INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`) VALUES (unix_timestamp(),'add_scorm_file','ERR: Not a Scorm Activity',`i_module_id`,1);
	LEAVE proc;
END IF;


SET `v_scorm_id`=(SELECT `instance` FROM `mdl_course_modules` WHERE `id`=`i_module_id` AND `module`=18);
SELECT `v_scorm_id`;


SET `v_filename`=(SELECT `reference` FROM `mdl_scorm` WHERE `id`=`v_scorm_id`);
SELECT `v_filename`;


SET `v_context_id`=(SELECT `id` FROM `mdl_context`
WHERE `instanceid` = `i_module_id` AND `contextlevel` = 70
LIMIT 1);
SELECT `v_context_id`;

IF `v_context_id` IS NULL THEN
	SELECT "NEW CONTEXT COULD NOT BE FOUND";
        INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`) VALUES (unix_timestamp(),'add_scorm_file','ERR: New Context NOT FOUND!',`i_module_id`,6);
        LEAVE proc;
END IF;



SET `v_fcount`=(SELECT COUNT(`id`) FROM `mdl_files` WHERE `contextid`=`v_context_id`);
IF `v_fcount`>0 THEN
	SELECT "NEW CONTEXT ALREADY HAS FILES";
        INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`) VALUES (unix_timestamp(),'add_scorm_file','ERR: New Context Already Has Files',`i_module_id`,2);
	LEAVE proc;
END IF;


SET `v_prev_context_id`=(select `contextid` from `mdl_files`
WHERE `component` = 'mod_scorm' AND `filename` = `v_filename`
LIMIT 1);
IF `v_prev_context_id`IS NULL THEN
	SELECT "SCORM File not referenced from another activity";
        INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`) VALUES (unix_timestamp(),'add_scorm_file',CONCAT('ERR: NO existing file references for FILE: ',`v_filename`),`i_module_id`,3);
	LEAVE proc;
END IF;


SET `v_prev_scorm_id`=(SELECT `m`.`instance` FROM `mdl_course_modules` `m` JOIN `mdl_context` `cx` ON `m`.`id`=`cx`.`instanceid` WHERE `cx`.`id`=`v_prev_context_id` AND `cx`.`contextlevel`=70);


SELECT `v_prev_context_id` 'prev_context', `v_context_id` 'context',`v_prev_scorm_id` 'prev_scorm',`v_scorm_id` 'scorm';


IF true THEN
INSERT INTO `mdl_files` (`contenthash`, `pathnamehash`, `contextid`, `component`, `filearea`, `itemid`, `filepath`, `filename`, `userid`, `filesize`, `mimetype`, `status`, `source`, `author`, `license`, `timecreated`, `timemodified`, `sortorder`, `referencefileid`)
SELECT `contenthash`,sha1(concat('/',`v_context_id`,'/',`component`,'/',`filearea`,'/',`itemid`,`filepath`,`filename`)), `v_context_id`, `component`, `filearea`, `itemid`, `filepath`, `filename`, `userid`, `filesize`, `mimetype`, `status`, `source`, `author`, `license`, unix_timestamp(), unix_timestamp(), `sortorder`, `referencefileid` 
 FROM `mdl_files` WHERE `contextid`=`v_prev_context_id`;
       SELECT "GENERATED mdl_files ROWS";
END IF;


IF true THEN




	insert into `mdl_scorm_scoes` (`scorm`, `manifest`, `organization`, `parent`, `identifier`, `launch`, `scormtype`, `title`, `sortorder`)
	select `v_scorm_id`, `manifest`, `organization`, `parent`, `identifier`, `launch`, `scormtype`, `title`, `sortorder` from `mdl_scorm_scoes` where `scorm`=`v_prev_scorm_id` and `sortorder`=1;


	SET `v_sco_id`=LAST_INSERT_ID();
	SET `v_prev_sco_id`=(SELECT `id` FROM `mdl_scorm_scoes` where `scorm`=`v_prev_scorm_id` and `sortorder`=1);





	insert into `mdl_scorm_scoes_data` (`scoid`, `name`, `value`)
	select `v_sco_id`, `name`, `value`
	from mdl_scorm_scoes_data where id =`v_prev_sco_id`;
	

	insert into `mdl_scorm_scoes` (`scorm`, `manifest`, `organization`, `parent`, `identifier`, `launch`, `scormtype`, `title`, `sortorder`)
	select `v_scorm_id`, `manifest`, `organization`, `parent`, `identifier`, `launch`, `scormtype`, `title`, `sortorder` from `mdl_scorm_scoes` where `scorm`=`v_prev_scorm_id` and `sortorder`=2;
	

	SET `v_sco_id`=LAST_INSERT_ID();
	SET `v_prev_sco_id`=(SELECT `id` FROM `mdl_scorm_scoes` where `scorm`=`v_prev_scorm_id` and `sortorder`=2);



	

	insert into `mdl_scorm_scoes_data` (`scoid`, `name`, `value`)
	select `v_sco_id`, `name`, `value`
	from `mdl_scorm_scoes_data` where `id` =`v_prev_sco_id`;
	
	

	update `mdl_scorm`
		SET `launch`=`v_sco_id`
		WHERE `id`=`v_scorm_id`;
        INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`) VALUES (unix_timestamp(),'add_scorm_file',CONCAT('OK: Completed for FILE: ',`v_filename`),`i_module_id`,0);
        SELECT CONCAT('File: ',`v_filename`,' COMPLETED OK'),`i_module_id`,`v_context_id`;
END IF;
		
end;;
