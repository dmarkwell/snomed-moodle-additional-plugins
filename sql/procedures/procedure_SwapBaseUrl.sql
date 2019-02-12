DROP PROCEDURE IF EXISTS `SwapBaseUrl`;;
CREATE PROCEDURE `SwapBaseUrl`(IN `ChangeTo_uat_or_prod` varchar(4))
SWAPBASE: BEGIN
DECLARE `v_source`varchar(253);
DECLARE `v_target` varchar(253);
DECLARE `v_match`varchar(255);

CALL FixUrlHttps('u');
CALL FixUrlHttps('p');
IF `ChangeTo_uat_or_prod` REGEXP '^(U|u|UAT|uat|Uat)$' THEN
  SET `v_source`='https://elearning.ihtsdotools.org';
  SET `v_target`='https://uat-elearning.ihtsdotools.org';
ELSEIF `ChangeTo_uat_or_prod` REGEXP '^(P|p|PROD|prod|Prod)$' THEN
  SET `v_source`='https://uat-elearning.ihtsdotools.org';
  SET `v_target`='https://elearning.ihtsdotools.org';
ELSE
  SELECT 'ChangeTo_uat_or_prod must be uat or prod (alt: Abbreviate as u or p )';
  LEAVE SWAPBASE;
END IF;
SET `v_match`=CONCAT('%',`v_source`,'%');

UPDATE `mdl_book`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match`;

UPDATE `mdl_book_chapters`
SET `content`=REPLACE(`content`,`v_source`,`v_target`)
WHERE `content` LIKE `v_match`;

UPDATE `mdl_course`
SET `summary`=REPLACE(`summary`,`v_source`,`v_target`)
WHERE `summary` LIKE `v_match`;

UPDATE `mdl_course_sections`
SET `summary`=REPLACE(`summary`,`v_source`,`v_target`)
WHERE `summary` LIKE `v_match`;

UPDATE `mdl_assign`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match`;

UPDATE `mdl_folder`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match`;

UPDATE `mdl_label`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match`;

UPDATE `mdl_page`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`),
`content`=REPLACE(`content`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match` OR `content` LIKE `v_match`;

UPDATE `mdl_scheduler`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match`;

UPDATE `mdl_quiz`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match`;

UPDATE `mdl_report_customsql_queries`
SET `description`=REPLACE(`description`,`v_source`,`v_target`)
WHERE `description` LIKE `v_match`;

UPDATE `mdl_scorm`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match`;

UPDATE `mdl_url`
SET `intro`=REPLACE(`intro`,`v_source`,`v_target`),
`externalurl`=REPLACE(`externalurl`,`v_source`,`v_target`)
WHERE `intro` LIKE `v_match` OR  `externalurl` LIKE `v_match` ;

UPDATE `mdl_user_info_field`
SET `description`=REPLACE(`description`,`v_source`,`v_target`)
WHERE `description` LIKE `v_match`;

UPDATE `mdl_config`
SET `value`=REPLACE(`value`,`v_source`,`v_target`)
WHERE `value` LIKE `v_match`;

UPDATE `mdl_elp_lookup`
SET `value`=REPLACE(`value`,`v_source`,`v_target`)
WHERE `value` LIKE `v_match`;

END;;
