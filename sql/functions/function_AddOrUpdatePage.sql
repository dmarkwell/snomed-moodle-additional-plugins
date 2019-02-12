DROP FUNCTION IF EXISTS `AddOrUpdatePage`;;
CREATE FUNCTION `AddOrUpdatePage`(`p_id` bigint(10), `p_course_id` bigint(10), `p_section_id` bigint(10), `p_key` varchar(100), `p_html` longtext, `p_visible` tinyint(1), `p_indent` smallint(3), `p_name` varchar(255)) RETURNS bigint(10)
NEWPAGE: BEGIN

# p_id: Existing known module.id OR 0 (force add page) OR -1 (check for matching page - if not found add page)
# p_courseid and p_sectionid (source and section in which to locate the page)
# p_key: Key to match on idnumber and to be added to a tag id in the HTML text
# p_html: Raw HTML to be inserted. Processed to final HTML to add p_key etc.
# p_visible: Visibility setting for the page.
# p_indent: Indent setting for the page.
# p_name: The page name (i.e. title)
# RETURNS module.id for the found or created course_module (look up instance for the page.id)

declare `v_page_id` bigint(10);
declare `v_module_id` bigint(10);
declare `v_htmla`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
declare `v_htmlb` longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
declare `v_html`  longtext  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
declare `v_exists` tinyint(1);

	INSERT INTO `mdl_elp_log` (added,task,info,value1,value2,value3,value4)
		SELECT UNIX_Timestamp(),'AddOrUpdatePage',CONCAT('START:',' K:',`p_key`,' N:',`p_name`),`p_id`,`p_course_id`,`p_section_id`,0;

  
  
IF trim(p_html) rlike '<[a-z][a-z0-9]*>' THEN
	SET `v_htmla`=SUBSTRING_INDEX(p_html,'>',1);
 	IF RIGHT(`v_htmla`,1)='/' THEN
  		SET `v_htmla`=LEFT(`v_htmla`,LENGTH(`p_htmla`)-1);
 	END IF;
 	SET `v_htmlb`=MID(`p_html`,LENGTH(`v_htmla`)+1);
 	SET `v_html`=CONCAT(`v_htmla`,' id="',`p_key`,'"',`v_htmlb`);
ELSE
	SET `v_html`=CONCAT('<p id="',`p_key`,'">',`p_html`,'</p>');
END IF;

IF `p_id`=-1 THEN
	SET `p_id`=(SELECT MIN(`id`) FROM `mdl_course_modules` WHERE `idnumber` = `p_key` AND `course`=`p_course_id` AND `section`=`p_section_id` AND `module`=15);
	IF ISNULL(`p_id`) THEN
		SET `p_id`=(SELECT MIN(`id`) FROM `mdl_course_modules` WHERE `idnumber` like CONCAT('%/',SUBSTRING_INDEX(`p_key`,'/',-1)) AND `course`=`p_course_id` AND `section`=`p_section_id` AND `module`=15);
		IF ISNULL(`p_id`) THEN
			INSERT INTO `mdl_elp_log` (added,task,info,value1,value2,value3,value4)
	          	SELECT UNIX_Timestamp(),'AddOrUpdatePage',CONCAT('FAIL Match:',' K:',`p_key`,' N:',`p_name`),`p_id`,`p_course_id`,`p_section_id`,0;
			SET `p_id`=0;
	   END IF;
	END IF;
END IF;


IF `p_id`=0 THEN

	INSERT INTO `mdl_page` (`course`,`name`,`intro`,`introformat`,`content`,`contentformat`,`legacyfiles`,`legacyfileslast`,`display`,`displayoptions`,`revision`,`timemodified`)
 		VALUES (`p_course_id`,`p_name`,'',1,`v_html`,1,0,NULL,5,'a:2:{s:12:"printheading";s:1:"0";s:10:"printintro";s:1:"0";}',1,unix_timestamp());

	SET `v_page_id`=last_insert_id();


	INSERT INTO `mdl_course_modules` (`course`,`module`,`instance`,`section`,`idnumber`,`added`,`score`,`indent`,`visible`,`visibleold`,`groupmode`,`groupingid`,`completion`,`completiongradeitemnumber`,`completionview`,`completionexpected`,`showdescription`,`availability`,`deletioninprogress`)
		VALUES (`p_course_id`,15,`v_page_id`,`p_section_id`,`p_key`,unix_timestamp(),0,`p_indent`,`p_visible`,`p_visible`,0,0,0,NULL,0,0,0,NULL,0);
	SET `v_module_id`=last_insert_id();

ELSE

	SET `v_page_id`=(SELECT `instance` FROM `mdl_course_modules` WHERE `id`=`p_id` AND `course`=`p_course_id` AND module=15);

	IF `v_page_id` IS NULL THEN
		return -1;
		LEAVE NEWPAGE;
	END IF;

	SET `v_module_id`=`p_id`;

	UPDATE `mdl_course_modules`
		SET `section`=`p_section_id`,`idnumber`=`p_key`,`indent`=`p_indent`,`visible`=`p_visible`
		,`visibleold`=`p_visible`
		WHERE `id`=`p_id`;

	UPDATE `mdl_page`
		SET `name`=`p_name`,`introformat`=1,`contentformat`=1,
			`legacyfiles`=0,`legacyfileslast`=NULL,`display`=5,
			`displayoptions`='a:2:{s:12:"printheading";s:1:"0";s:10:"printintro";s:1:"0";}',
			`revision`=`revision`+1,`timemodified`=unix_timestamp()
		WHERE `id`=`v_page_id`;
	
	UPDATE `mdl_page`
		SET `content`=`v_html`
		WHERE `id`=`v_page_id`
		  AND (`p_html`!='' OR `content` rlike '^<p[^>]*>$' OR `content`='');

END IF;

return `v_module_id`;

END;;
