DROP PROCEDURE IF EXISTS `AddedAttemptsRegrade`;;
CREATE PROCEDURE `AddedAttemptsRegrade`(IN `p_quizid` bigint)
begin

drop table if exists `tmp_quizgrades`;
create temporary table `tmp_quizgrades`
(`attemptid` bigint(10) NOT NULL,
  `newmark` decimal(10,5) default 0,
  `oldmark` decimal(10,5) default NULL,
  PRIMARY KEY (`attemptid`))
  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO tmp_quizgrades (`attemptid`, `newmark`,`oldmark`)
SELECT `qza`.`id`,SUM(`qas`.`fraction`*`qa`.`maxmark`),`qza`.`sumgrades`
FROM `mdl_quiz_attempts` `qza`
JOIN `mdl_question_usages` `qu` ON `qu`.`id` = `qza`.`uniqueid`
JOIN `mdl_question_attempts` `qa` ON `qa`.`questionusageid` = `qu`.`id`
JOIN `mdl_question_attempt_steps` `qas` ON `qa`.`id`=`qas`.`questionattemptid`
WHERE `qza`.`quiz`=`p_quizid`
AND NOT isnull(`qas`.`fraction`)
AND `qas`.`id` IN (SELECT MAX(`qas2`.`id`) FROM  `mdl_question_attempt_steps` `qas2` WHERE `qas2`.`questionattemptid`=`qas`.`questionattemptid` AND not isnull(`qas2`.`fraction`))
GROUP BY `qza`.`id`;

SELECT count(`qza`.`id`) 'attempts updated'
FROM `mdl_quiz_attempts` `qza`,`tmp_quizgrades` `qg`
WHERE `qza`.`id`=`qg`.`attemptid` AND `qza`.`sumgrades`<>`qg`.`newmark` AND `qza`.`sumgrades`=`qg`.`oldmark`;

SET SQL_SAFE_UPDATES = 0;

UPDATE `mdl_quiz_attempts` `qza`,`tmp_quizgrades` `qg`
SET `qza`.`sumgrades`=`qg`.`newmark`
WHERE `qza`.`id`=`qg`.`attemptid` AND `qza`.`sumgrades`<>`qg`.`newmark` AND `qza`.`sumgrades`=`qg`.`oldmark`;

SET SQL_SAFE_UPDATES = 1;

drop table if exists `tmp_quizgrades`;

end;;
