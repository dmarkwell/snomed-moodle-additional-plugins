DROP PROCEDURE IF EXISTS `ProcessCourseInfo`;;
CREATE PROCEDURE `ProcessCourseInfo`(IN `p_course_title` varchar(255))
ADDINFO: BEGIN

DECLARE `v_id` bigint(10);
DECLARE `v_course_id` bigint(10);
DECLARE `v_course_idnumber` varchar(16);
DECLARE `v_section_id` bigint(10);
DECLARE `v_section_order` int(6);
DECLARE `v_subsection_id` bigint(10);
DECLARE `v_subsection_order` int(6);
DECLARE `v_subsection_title` varchar(255);
DECLARE `v_section_title` varchar(255);
DECLARE `v_module_id` bigint(10);
DECLARE `v_module_title` varchar(255);
DECLARE `v_html` longtext;
DECLARE `v_sequence` longtext;

DECLARE `v_key` varchar(96) DEFAULT 'section';
DECLARE `v_fullkey` varchar(100);
DECLARE `v_rowtype` varchar(16);
DECLARE `v_visible` tinyint(1) DEFAULT 1;
DECLARE `v_indent` smallint(3) DEFAULT 1;
declare `v_htmla` longtext;
declare `v_htmlb`longtext;
declare `v_htmlok` longtext;
declare `v_server` varchar(255);

DECLARE done BOOLEAN DEFAULT FALSE;
DECLARE cur CURSOR FOR SELECT `id`, `section_id`,`subsection_id`,`subsection_title`,`subsection_order`,`module_id`,`module_title`, `fullkey`, `html` FROM `mdl_elp_course_info` WHERE `row_type` = `v_rowtype` AND `course_id`=`v_course_id`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := TRUE;

SET  `v_server`=(SELECT `value` FROM `mdl_elp_lookup` WHERE `group`='meta_info' AND `item`='server');



SET `v_course_id`=(SELECT `id` FROM `mdl_course` WHERE `shortname`=`p_course_title`);
IF `v_course_id` IS NULL THEN
     Select 'Could not resolve course name',`p_course_title`;
    LEAVE ADDINFO;
END IF;
SET `v_course_idnumber`=(SELECT `idnumber` FROM `mdl_course` WHERE `id`=`v_course_id`);



SET `v_rowtype`='SUBSECTION';
SET `done`=FALSE;


OPEN cur;

subsectionLoop: LOOP
    FETCH cur INTO `v_id`,`v_section_id`,`v_subsection_id`,`v_subsection_title`, `v_subsection_order`,`v_module_id`,`v_module_title`, `v_fullkey`,`v_html`;
    IF done THEN
      LEAVE subsectionLoop;
    END IF;

    SET `v_subsection_id` = AddOrUpdateLabel(`v_subsection_id`,`v_course_id`, `v_section_id`, `v_fullkey`, `v_html`, `v_visible`, `v_indent`);
	
	
	UPDATE `mdl_elp_course_info`
		SET `module_id`=`v_subsection_id`
		WHERE `id`=`v_id`;
		
	
	UPDATE `mdl_elp_course_info`
		SET `subsection_id`=`v_subsection_id`
		WHERE `course_id`=`v_course_id` AND `section_id`=`v_section_id` AND `subsection_order`=`v_subsection_order`;
END LOOP subsectionLoop;

CLOSE cur;


SET `v_rowtype`='REF';
SET `done`=FALSE;


OPEN cur;

refLoop: LOOP
    FETCH cur INTO `v_id`,`v_section_id`,`v_subsection_id`,`v_subsection_title`, `v_subsection_order`,`v_module_id`,`v_module_title`, `v_fullkey`,`v_html`;
    IF done THEN
      LEAVE refLoop;
    END IF;

    SET `v_indent`=IF(`v_subsection_order`>0,2,1);
    SET `v_module_id` = AddOrUpdateLabel(`v_module_id`,`v_course_id`, `v_section_id`, `v_fullkey`, `v_html`, `v_visible`, `v_indent`);
	
	UPDATE `mdl_elp_course_info`
		SET `module_id`=`v_module_id`
		WHERE `id`=`v_id`;
END LOOP refLoop;

CLOSE cur; 


SET `v_rowtype`='ELP';
SET `done`=FALSE;

OPEN cur;

scormLoop: LOOP
    FETCH cur INTO `v_id`,`v_section_id`,`v_subsection_id`,`v_subsection_title`, `v_subsection_order`,`v_module_id`,`v_module_title`, `v_fullkey`,`v_html`;
    IF done THEN
      LEAVE scormLoop;
    END IF;
    SET `v_indent`=IF(`v_subsection_order`>0,2,1);
	SET `v_module_id` = AddOrUpdateScorm(`v_module_id`,`v_course_id`, `v_section_id`, `v_fullkey`, `v_html`, `v_visible`, `v_indent`,`v_module_title`);

	
	UPDATE `mdl_elp_course_info`
		SET `module_id`=`v_module_id`
		WHERE `id`=`v_id`;
	
END LOOP scormLoop;

CLOSE cur; 
 
SELECT "SCORM LOOP DONE";


SET `v_rowtype`='page';
SET `done`=FALSE;

OPEN cur;

pageLoop: LOOP
    FETCH cur INTO `v_id`,`v_section_id`,`v_subsection_id`,`v_subsection_title`, `v_subsection_order`,`v_module_id`,`v_module_title`, `v_fullkey`,`v_html`;
    IF done THEN
      LEAVE pageLoop;
    END IF;
    SET `v_indent`=IF(`v_subsection_order`>0,3,2);

SELECT 'TEST: CALL AddOrUpdatePage';
SELECT `v_module_id`,`v_course_id`, `v_section_id`, `v_fullkey`, `v_html`, `v_visible`, `v_indent`,`v_module_title`;

	SET `v_module_id` = AddOrUpdatePage(`v_module_id`,`v_course_id`, `v_section_id`, `v_fullkey`, `v_html`, `v_visible`, `v_indent`,`v_module_title`);

	
	UPDATE `mdl_elp_course_info`
		SET `module_id`=`v_module_id`
		WHERE `id`=`v_id`;
	
END LOOP pageLoop;

CLOSE cur; 
 
SELECT "VIDEO LOOP DONE";


  SET `v_rowtype`='SECTION';
SET `done`=FALSE;


  OPEN cur;

SELECT "SECTION LOOP STARTED";

  sectionLoop: LOOP
    FETCH cur INTO `v_id`,`v_section_id`,`v_subsection_id`,`v_subsection_title`, `v_subsection_order`,`v_module_id`,`v_module_title`, `v_fullkey`,`v_html`;
    IF done THEN
      LEAVE sectionLoop;
    END IF;
  	
        SET `v_section_title`=(SELECT 'section_title' FROM `mdl_elp_course_info`WHERE `course_id`=`v_course_id` AND `section_id`=`v_section_id` AND `row_type`='SECTION');
	SET `v_sequence`=(SELECT Group_Concat(`module_id`) FROM `mdl_elp_course_info` WHERE `course_id`=`v_course_id` AND `section_id`=`v_section_id` AND `row_type`!='SECTION' ORDER BY `module_order`);

    SELECT 'SEQUENCE-UPDATE',`v_course_id`,`v_section_id`,`v_sequence`;


	UPDATE `mdl_course_sections`
		SET `sequence`=`v_sequence`
		WHERE `id`=`v_section_id` AND `course`=`v_course_id`;
	
	IF `v_fullkey`='' THEN
		SET `v_fullkey`=LOWER(CONCAT('section','_',REPLACE(`v_section_title`,' ','-')));
	END IF;
	IF trim(v_html) rlike '^<(p|h[1-6])' THEN
	 	SET `v_html`=CONCAT('<div id="',`v_fullkey`,'">',`v_html`,'</div>');
	ELSE
		SET `v_html`=CONCAT('<p id="',`v_fullkey`,'">',`v_html`,'</p>');
	END IF;
	

	UPDATE `mdl_course_sections`
		SET `summary`=REPLACE(REPLACE(`v_html`,'\$CRS\$',`v_course_id`),
	'\$SVR\$',`v_server`)
		WHERE `id`=`v_section_id` AND `course`=`v_course_id` AND `v_html`!='';
	
			
END LOOP sectionLoop;

CLOSE cur; 

CALL UpdateMetadata();


SET `v_rowtype`='ELP';
SET `done`=FALSE;

OPEN cur;

scormFileLoop: LOOP
    FETCH cur INTO `v_id`,`v_section_id`,`v_subsection_id`,`v_subsection_title`, `v_subsection_order`,`v_module_id`,`v_module_title`, `v_fullkey`,`v_html`;
    IF done THEN
      LEAVE scormFileLoop;
    END IF;



     CALL AddScormFiles(`v_module_id`);	


END LOOP scormFileLoop;


SELECT "Completed - ProcessCourseInfo and UpdateMetadata and SCORM File Loop";

END;;
