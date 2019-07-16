DELIMITER ;;
DROP PROCEDURE IF EXISTS `SurveyToProfileUpdate`;;
CREATE PROCEDURE `SurveyToProfileUpdate` (IN `p_startDate` varchar(12))
BEGIN
DECLARE `v_name` varchar(32);
DECLARE `v_fieldid` bigint(10);
DECLARE `v_questionnaires` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_questions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_userid` bigint(10);
DECLARE `v_update_required` tinyint(2);
DECLARE `v_multi` tinyint(2);
DECLARE `v_submitted` bigint(10);
DECLARE `v_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DECLARE `v_prevuserid` bigint(10);
DECLARE `v_startdate` bigint(10);
DECLARE `v_lastmodified` bigint(10);
DECLARE `done` tinyint(2);

DECLARE `cur1` CURSOR FOR SELECT `name`,`questionnaire_idlist`,`question_idlist`,`fieldid`,`multi`
	FROM `tmp_elp_questionnaire_lists`;

DECLARE `cur2` CURSOR FOR SELECT `userid`,`name`,`fieldid`,`value`,`submitted`
	FROM `tmp_update` ORDER BY `userid`,`submitted`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` = TRUE;

DROP TABLE IF EXISTS `tmp_elp_questionnaire_lists`;
CREATE TEMPORARY TABLE `tmp_elp_questionnaire_lists` (
  `name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `questionnaire_idlist` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_idlist` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `fieldid` bigint(10) NOT NULL DEFAULT '0',
  `multi` tinyint(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tmp_elp_questionnaire_lists` (`name`,`questionnaire_idlist`,`question_idlist`,`fieldid`,`multi`)
SELECT 'institution',GROUP_CONCAT(DISTINCT `q`.`id`), GROUP_CONCAT(DISTINCT `qq`.`id` ),0,0
FROM `mdl_questionnaire_question` `qq`
JOIN `mdl_questionnaire` `q` ON `q`.`sid`=`qq`.`surveyid`
WHERE `qq`.`name`regexp '[Ee]mployer'
UNION
SELECT 'country',GROUP_CONCAT(DISTINCT `q`.`id`), GROUP_CONCAT(DISTINCT `qq`.`id` ),0,0
FROM `mdl_questionnaire_question` `qq`
JOIN `mdl_questionnaire` `q` ON `q`.`sid`=`qq`.`surveyid`
WHERE `qq`.`name`regexp '[Cc]ountry'
UNION
SELECT 'role',GROUP_CONCAT(DISTINCT `q`.`id`), GROUP_CONCAT(DISTINCT `qq`.`id` ),MIN(`f`.`id`),0
FROM `mdl_questionnaire_question` `qq`
JOIN `mdl_user_info_field` `f` ON `f`.`shortname`='role'
JOIN `mdl_questionnaire` `q` ON `q`.`sid`=`qq`.`surveyid`
WHERE `qq`.`name`regexp '[Rr]ole|[Pp]osition'
UNION
SELECT 'expertise',GROUP_CONCAT(DISTINCT `q`.`id`), GROUP_CONCAT(DISTINCT `qq`.`id` ),MIN(`f`.`id`),1
FROM `mdl_questionnaire_question` `qq`
JOIN `mdl_user_info_field` `f` ON `f`.`shortname`='expertise'
JOIN `mdl_questionnaire` `q` ON `q`.`sid`=`qq`.`surveyid`
WHERE `qq`.`name`regexp '[Ss]kill|[Ee]xperti[sz]e'
UNION
SELECT 'interest',GROUP_CONCAT(DISTINCT `q`.`id`), GROUP_CONCAT(DISTINCT `qq`.`id` ),MIN(`f`.`id`),1
FROM `mdl_questionnaire_question` `qq`
JOIN `mdl_user_info_field` `f` ON `f`.`shortname`='interests'
JOIN `mdl_questionnaire` `q` ON `q`.`sid`=`qq`.`surveyid`
WHERE `qq`.`name`regexp '[Bb]ackground|[Ii]nterest'

GROUP BY CASE LOWER(LEFT(`qq`.`name`,3)) WHEN 'emp' THEN 1 WHEN 'cou'  THEN 2 WHEN 'rol' THEN 3 WHEN 'pos' THEN 3 WHEN 'ski' THEN 4 WHEN 'exp' THEN 4 ELSE 5 END;



CASE LOWER(LEFT(`p_startDate`,1))
  WHEN 'd' THEN SET `v_startDate`=UNIX_TIMESTAMP(SUBDATE(Now(),INTERVAL 1 DAY));
  WHEN 'w' THEN SET `v_startDate`=UNIX_TIMESTAMP(SUBDATE(Now(),INTERVAL 7 DAY));
  WHEN 'm' THEN SET `v_startDate`=UNIX_TIMESTAMP(SUBDATE(Now(),INTERVAL 1 MONTH));
  WHEN 'y' THEN SET `v_startDate`=UNIX_TIMESTAMP(SUBDATE(Now(),INTERVAL 1 YEAR));
  ELSE
	SET `v_startDate`=IFNULL(UNIX_TIMESTAMP(DATE(`p_startDate`)),0);
END CASE;

DROP TABLE IF EXISTS `tmp_update`;
CREATE TABLE `tmp_update`
(`userid` bigint(10),
 `name` varchar(32) COLLATE utf8mb4_unicode_ci,
 `fieldid` bigint(10),
 `value` text COLLATE utf8mb4_unicode_ci,
 `submitted` bigint(10),
 KEY `userid` (`userid`,`submitted`)
);

OPEN `cur1`;
cur_loop: LOOP
	FETCH `cur1` INTO `v_name`,`v_questionnaires`,`v_questions`,`v_fieldid`,`v_multi`;
	IF `done` THEN
		LEAVE cur_loop;
	END IF;

	IF `v_name`='country' THEN

		INSERT INTO `tmp_update` (`userid`,`name`,`fieldid`,`value`,`submitted`)
		SELECT `r`.`userid`,`v_name`,`v_fieldid`,`x`.`code`,`r`.`submitted`
			FROM `mdl_questionnaire_resp_single` `t`
			JOIN `mdl_questionnaire_quest_choice` `c` ON `c`.`id`=`t`.`choice_id` AND `t`.`question_id`=`c`.`question_id`
			JOIN `mdl_questionnaire_response` `r` ON `t`.`response_id`=`r`.`id`
			JOIN `mdl_elp_lookup_country` `x` ON `c`.`content`=`x`.`name`
			WHERE FIND_IN_SET(`t`.`question_id`,`v_questions`)>0
				AND `r`.`complete`='y'
				AND `r`.`submitted`>`v_startdate`
				AND `r`.`submitted`=(SELECT MAX(`submitted`) FROM `mdl_questionnaire_response` WHERE FIND_IN_SET(`r`.`questionnaireid`,`v_questionnaires`)>0)
				AND `r`.`submitted`>(SELECT `timemodified` FROM `mdl_user` WHERE `id`=`r`.`userid`);
	ELSEIF `v_multi` !=0 THEN
		INSERT INTO `tmp_update` (`userid`,`name`,`fieldid`,`value`,`submitted`)
			SELECT `r`.`userid`,`v_name`,`v_fieldid`,GROUP_CONCAT(If(`c`.`value` = NULL,`c`.`content`,SUBSTRING_INDEX(`c`.`content`,'=',-1)) SEPARATOR ', '),`r`.`submitted`
			FROM `mdl_questionnaire_resp_multiple` `t`
			JOIN `mdl_questionnaire_quest_choice` `c` ON `c`.`id`=`t`.`choice_id` AND `t`.`question_id`=`c`.`question_id`
			JOIN `mdl_questionnaire_response` `r` ON `t`.`response_id`=`r`.`id`
			WHERE FIND_IN_SET(`t`.`question_id`,`v_questions`)>0
				AND `r`.`complete`='y'
				AND `r`.`submitted`>`v_startdate`
				AND `r`.`submitted`=(SELECT MAX(`submitted`) FROM `mdl_questionnaire_response` WHERE FIND_IN_SET(`r`.`questionnaireid`,`v_questionnaires`)>0)
				AND `r`.`submitted`>(SELECT `timemodified` FROM `mdl_user` WHERE `id`=`r`.`userid`)
			GROUP BY `r`.`userid`,`t`.`question_id`,`t`.`response_id`;
	ELSE

		INSERT INTO `tmp_update` (`userid`,`name`,`fieldid`,`value`,`submitted`)
			SELECT `r`.`userid`,`v_name`,`v_fieldid`,`t`.`response`,`r`.`submitted`
			FROM `mdl_questionnaire_response_text` `t`
			JOIN `mdl_questionnaire_response` `r` ON `t`.`response_id`=`r`.`id`
			WHERE FIND_IN_SET(`t`.`question_id`,`v_questions`)>0
				AND `r`.`complete`='y'
				AND `r`.`submitted`>`v_startdate`
				AND `r`.`submitted`=(SELECT MAX(`submitted`) FROM `mdl_questionnaire_response` WHERE FIND_IN_SET(`r`.`questionnaireid`,`v_questionnaires`)>0)
				AND `r`.`submitted`>(SELECT `timemodified` FROM `mdl_user` WHERE `id`=`r`.`userid`);
	END IF;

END LOOP;

SET `done` = FALSE;

SET `v_prevuserid`=0;

OPEN `cur2`;
cur_loop2: LOOP
	FETCH `cur2` INTO `v_userid`,`v_name`,`v_fieldid`,`v_value`,`v_submitted`;
	IF `done` THEN
		LEAVE cur_loop2;
	END IF;

	IF `v_userid`!=`v_prevuserid` THEN
		SET `v_userid`=`v_prevuserid`;
		IF `v_update_required`!=0 THEN
			UPDATE `mdl_user` SET `timemodified`=`v_lastmodified` WHERE `id`=`v_userid`;
			SET `v_update_required`=0;
		END IF;
		SET `v_lastmodified`=(SELECT `timemodified` FROM `mdl_user` WHERE `id`=`userid`);
	END IF;

	IF `v_submitted`>=`v_lastmodified` THEN
		IF `v_fieldid`>0 THEN
			INSERT INTO `mdl_user_info_data` (`userid`,`fieldid`,`data`)
			SELECT `v_userid`,`v_fieldid`,`v_value` FROM `tmp_update` WHERE `type`=`name`
				ON DUPLICATE KEY UPDATE `data`=`value`;
			IF ROW_COUNT()=1 THEN
				SET `v_update_required`=1;
			END IF;
		ELSEIF `v_name`='country' THEN
			UPDATE `mdl_user` SET `country`=`v_value`, `timemodified`=`v_lastmodified`
				WHERE `id`=`v_userid` AND `timemodified`<=`v_lastmodified` AND `country`!=`v_value`;
			SET `v_update_required`=0;
		ELSEIF `v_name`='institution' THEN
			UPDATE `mdl_user` SET `institution`=`v_value`, `timemodified`=`v_lastmodified`
				WHERE `id`=`v_userid` AND `timemodified`<=`v_lastmodified` AND `institution`!=`v_value`;
			SET `v_update_required`=0;
		END IF;
	END IF;
END LOOP;
DROP TABLE IF EXISTS `tmp_update`;
DROP TABLE IF EXISTS `tmp_elp_questionnaire_lists`;

END;;
DELIMITER ;