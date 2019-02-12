DELIMITER ;;
DROP FUNCTION IF EXISTS `AddOrUpdateScorm`;;
CREATE FUNCTION `AddOrUpdateScorm`(`p_id` bigint(10), `p_course_id` bigint(10), `p_section_id` bigint(10), `p_key` varchar(100), `p_html` longtext, `p_visible` tinyint(1), `p_indent` smallint(3), `p_reference` varchar(255)) RETURNS bigint(10)
NEWLABEL: BEGIN

declare `v_scorm_id` bigint(10);
declare `v_module_id` bigint(10);
declare `v_htmla` longtext;
declare `v_htmlb`longtext;
declare `v_html` longtext;

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

INSERT INTO mdl_scorm (`course`,`name`,`scormtype`,`reference`,`intro`,`introformat`,`version`,`maxgrade`,`grademethod`,`whatgrade`,`maxattempt`,`forcecompleted`,`forcenewattempt`,`lastattemptlock`,`masteryoverride`,`displayattemptstatus`,`displaycoursestructure`,`updatefreq`,`sha1hash`,`md5hash`,`revision`,`launch`,`skipview`,`hidebrowse`,`hidetoc`,`nav`,`navpositionleft`,`navpositiontop`,`auto`,`popup`,`options`,`width`,`height`,`timeopen`,`timeclose`,`timemodified`,`completionstatusrequired`,`completionscorerequired`,`completionstatusallscos`,`displayactivityname`,`autocommit`)
SELECT `p_course_id`, `p_reference`,'local',CONCAT(`p_reference`,'.zip'),`v_html`,1,'SCORM_1.2',100,0,0,0,0,0,0,1,2,0,3,'','',1,0,0,1,3,1,-100,-100,0,1,'scrollbars=0,directories=0,location=0,menubar=0,toolbar=0,status=0',90,90,0,0,unix_timestamp(),6,NULL,NULL,1,1;

	SET `v_scorm_id`=last_insert_id();


	INSERT INTO `mdl_course_modules` (`course`,`module`,`instance`,`section`,`idnumber`,`added`,`score`,`indent`,`visible`,`visibleold`,`groupmode`,`groupingid`,`completion`,`completiongradeitemnumber`,`completionview`,`completionexpected`,`showdescription`,`availability`,`deletioninprogress`)
	VALUES (`p_course_id`,18,`v_scorm_id`,`p_section_id`,`p_key`,
		unix_timestamp(),0,`p_indent`,`p_visible`,`p_visible`,0,0,2,NULL,1,0,0,NULL,0);

	SET `v_module_id`=last_insert_id();

ELSE

	SET `v_scorm_id`=(SELECT `instance` FROM `mdl_course_modules` WHERE `id`=`p_id` AND `course`=`p_course_id` AND module=18);

	IF `v_scorm_id` IS NULL THEN
		return -1;
		LEAVE NEWLABEL;
	END IF;

	SET `v_module_id`=`p_id`;


	UPDATE `mdl_course_modules`
		SET `section`=`p_section_id`,`idnumber`=`p_key`,`indent`=`p_indent`,
                `visible`=`p_visible`,`visibleold`=`p_visible`,
                `completion` = '2', `completionview` = '1'
		WHERE `id`=`p_id`;

	UPDATE `mdl_scorm`
		SET `name`=`p_reference`,`reference`=CONCAT(`p_reference`,'.zip'),`introformat`=1,`timemodified`=unix_timestamp(),`completionstatusrequired`=6
		WHERE `id`=`v_scorm_id`;

	UPDATE `mdl_scorm`
		SET `intro`=`v_html`
		WHERE `id`=`v_scorm_id`
	AND (`p_html`!='' OR `intro` rlike '^<p[^>]*p>$' OR `intro`='');

END IF;

return `v_module_id`;

END;;
