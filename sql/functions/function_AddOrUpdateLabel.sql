DROP FUNCTION IF EXISTS `AddOrUpdateLabel`;;
CREATE FUNCTION `AddOrUpdateLabel`(`p_id` bigint(10),`p_course_id` bigint(10), `p_section_id` bigint(10), `p_key` varchar(100), `p_html` longtext, `p_visible` tinyint(1), `p_indent` smallint(3)) RETURNS bigint(10)
NEWLABEL: BEGIN

declare `v_label_id` bigint(10);
declare `v_module_id` bigint(10);
declare `v_htmla` longtext;
declare `v_htmlb`longtext;
declare `v_html` longtext;
declare `v_exists` tinyint(1);

IF trim(p_html) rlike '<[a-z][a-z0-9]*>' THEN
	SET `v_htmla`=SUBSTRING_INDEX(p_html,'>',1);
 	IF RIGHT(`v_htmla`,1)='/' THEN
  		SET `v_htmla`=LEFT(`v_htmla`,LENGTH(`p_htmla`)-1);
 	END IF;
 	SET `v_htmlb`=MID(`p_html`,LENGTH(`v_htmla`+1));
 	SET `v_html`=CONCAT(`v_htmla`,' id="',`p_key`,'"',`v_htmlb`);
ELSE
	SET `v_html`=CONCAT('<p id="',`p_key`,'">',`p_html`,'</p>');
END IF;

IF `p_id`=0 THEN

	INSERT INTO `mdl_label` (`course`,`name`,`intro`,`introformat`,`timemodified`)
 		VALUES (`p_course_id`,`p_key`,`v_html`,1,unix_timestamp());

	SET `v_label_id`=last_insert_id();


	INSERT INTO `mdl_course_modules` (`course`,`module`,`instance`,`section`,`idnumber`,`added`,`score`,`indent`,`visible`,`visibleold`,`groupmode`,`groupingid`,`completion`,`completiongradeitemnumber`,`completionview`,`completionexpected`,`showdescription`,`availability`,`deletioninprogress`)
		VALUES (`p_course_id`,12,`v_label_id`,`p_section_id`,`p_key`,unix_timestamp(),0,`p_indent`,`p_visible`,`p_visible`,0,0,0,NULL,0,0,0,NULL,0);

	SET `v_module_id`=last_insert_id();

ELSE

	SET `v_label_id`=(SELECT `instance` FROM `mdl_course_modules` WHERE `id`=`p_id` AND `course`=`p_course_id` AND module=12);

	IF `v_label_id` IS NULL THEN
		return -1;
		LEAVE NEWLABEL;
	END IF;

	SET `v_module_id`=`p_id`;


	UPDATE `mdl_course_modules`
		SET `section`=`p_section_id`,`idnumber`=`p_key`,`indent`=`p_indent`,`visible`=`p_visible`
		,`visibleold`=`p_visible`
		WHERE `id`=`p_id`;

	UPDATE `mdl_label`
		SET `name`=`p_key`,`introformat`=1,`timemodified`=unix_timestamp()
		WHERE `id`=`v_label_id`;
	
	UPDATE `mdl_label`
		SET `intro`=`v_html`
		WHERE `id`=`v_label_id`
		  AND (`p_html`!='' OR `intro` rlike '^<p[^>]*p>$' OR `intro`='');

END IF;

return `v_module_id`;

END;;
