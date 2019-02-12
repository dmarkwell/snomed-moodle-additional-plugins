DELIMITER ;;
DROP PROCEDURE IF EXISTS `QuizAttemptExport`;;
CREATE PROCEDURE `QuizAttemptExport`(IN `p_option` varchar(12) CHARACTER SET 'utf8mb4')
BEGIN

# PARAMETER p_option INCLUDED FOR POSSIBLE FUTURE USE. 
# ADDED FOR GENERAL COMPATIBILITY SO ALL CRON PROCS HAVE A STRING ARGUMENT.
# DEFAULT VALUE OF BLANK STRING IS USED UNLESS OTHER OPTIONS ARE REQUIRED.

drop table if exists `tmp_answer`;
drop table if exists `tmp_markingstatus`;
drop table if exists `tmp_seq`;
drop table if exists `mdl_elp_quiz_attempt_export`;

create table  IF NOT EXISTS `mdl_elp_quiz_attempt_export`
(`id` bigint(10) NOT NULL AUTO_INCREMENT,
  `attemptid` bigint(10) NOT NULL,
  `quiz` bigint(10),
  `userid` bigint(10),
  `attempt` mediumint(6),
  `slot` bigint(10),
  `questionid` bigint(10),
  `answer` longtext,
  `seq` bigint(10) default 0,
  `maxmark` decimal(12,7) default 0,
  `fraction` decimal(12,7) default NULL,
  `flag` smallint default 0,
  `attempttime` bigint(10),
  `timemodified` bigint(10),
  `attemptstate` text,
  `group` text,
  PRIMARY KEY (`id`),
  UNIQUE (`attemptid`))
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

create temporary table `tmp_answer`
(`eid` bigint(10) NOT NULL,
  `answer` longtext,
  PRIMARY KEY (`eid`))
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

create temporary table `tmp_markingstatus`
(`eid` bigint(10) NOT NULL,
  `fraction` decimal(12,7) default NULL,
  `state` text,
  `timemodified` bigint(10),
  PRIMARY KEY (`eid`))
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
  
create temporary table `tmp_seq`
(`eid` bigint(10) NOT NULL,
  `seq` bigint(10),
  PRIMARY KEY (`eid`))
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
  

INSERT INTO `mdl_elp_quiz_attempt_export` (`attemptid`,`quiz`,`userid`,`attempt`, `slot` ,`questionid`,`maxmark`,`attemptstate`,`attempttime`,`group`)
SELECT `qa`.`id`, `qza`.`quiz`,`qza`.`userid`,`qza`.`attempt`,`qa`.`slot`,`qa`.`questionid`,`qa`.`maxmark`,`qza`.`state`,`qa`.`timemodified`,`g`.`name`
FROM `mdl_quiz` `q`
JOIN  `mdl_quiz_attempts` `qza` ON `q`.`id`=`qza`.`quiz`
JOIN `mdl_question_usages` `qu` ON `qu`.`id` = `qza`.`uniqueid`
JOIN `mdl_question_attempts` `qa` ON `qa`.`questionusageid` = `qu`.`id`
JOIN `mdl_groups_members` `gm` ON `qza`.`userid` =`gm`.`userid`
JOIN `mdl_groups` `g` ON `g`.`id`=`gm`.`groupid`
JOIN `mdl_groupings_groups` `gg` ON `gg`.`groupid`=`g`.`id`
JOIN `mdl_groupings` `gs` ON `gs`.`id`=`gg`.`groupingid`
WHERE `gs`.`name` REGEXP '_Active$'
AND `qa`.`maxmark`>0
AND `q`.`intro` regexp 'id\s*=\s*"export-for-marking"'
AND `q`.`course`=`g`.`courseid`;



# Get most recently provided answer for each question attempt

INSERT INTO `tmp_answer` (`eid`,`answer`)
SELECT `e`.`id`,`qasd`.`value`
    FROM `mdl_question_attempt_steps` `qas`
    JOIN `mdl_question_attempt_step_data` `qasd` ON `qasd`.`attemptstepid`=`qas`.`id`
    JOIN `mdl_elp_quiz_attempt_export` `e` ON `e`.`attemptid`=`qas`.`questionattemptid`
WHERE `qasd`.`name`='answer'
AND `qas`.`id`=(SELECT MAX(qas2.id) FROM `mdl_question_attempt_steps` `qas2`
JOIN `mdl_question_attempt_step_data` `qasd2` ON `qasd2`.`attemptstepid`=`qas2`.`id`
    WHERE `qas2`.`questionattemptid`=`qas`.`questionattemptid`
AND `qasd2`.`name`='answer');

# Update mdl_elp_quiz_attempt_export with latest answer for each question attempt

UPDATE `mdl_elp_quiz_attempt_export` `e`,`tmp_answer` `a`
SET `e`.`answer`=`a`.`answer`
WHERE `e`.`id`=`a`.`eid`;


# Get most recent -finish or -mark data for latest mark fraction  and stated of each question attempt
# Take account of the pmatch question type which gets marked but needs to be remarked
# Other question types with different patterns could be handled by modifying this query

INSERT INTO `tmp_markingstatus` (`eid`,`state`,`fraction`,`timemodified`)
SELECT `e`.`id`,IF(`q`.`qtype`='pmatch' and`qas`.`fraction`=0,'needsgrading',`qas`.`state`),IF(`q`.`qtype`='pmatch' and`qas`.`fraction`=0,NULL,`qas`.`fraction`),`qas`.`timecreated`
    FROM `mdl_question_attempt_steps` `qas`
    JOIN `mdl_question_attempt_step_data` `qasd` ON `qasd`.`attemptstepid`=`qas`.`id`
    JOIN `mdl_elp_quiz_attempt_export` `e` ON `e`.`attemptid`=`qas`.`questionattemptid`
	JOIN `mdl_question` `q` ON `q`.`id`=`e`.`questionid`
WHERE `qasd`.`name` IN ('-mark','-finish')
AND `qas`.`id`=(SELECT MAX(qas2.id) FROM `mdl_question_attempt_steps` `qas2`
JOIN `mdl_question_attempt_step_data` `qasd2` ON `qasd2`.`attemptstepid`=`qas2`.`id`
    WHERE `qas2`.`questionattemptid`=`qas`.`questionattemptid`
AND `qasd2`.`name` IN ('-mark','-finish'));


# Update mdl_elp_quiz_attempt_export with latest mark fraction and state flag values
# Note special handling to reduce the key state values to an integer flag 
# 0 unrecognized value (should not occur - but here for exceptions)
# 1 gave up not answered (These should be marked for completeness)
# 2 ready to be marked (Key value for export)
# 3 manually marked (Just in case remarking is required)
# 4 auto marked (This should not occur but is here just in case exceptions occur)

UPDATE `mdl_elp_quiz_attempt_export` `e`,`tmp_markingstatus` `m`
SET `e`.`fraction`=`m`.`fraction`, 
`e`.`timemodified`=`m`.`timemodified`,
`e`.`flag`=IF(`m`.`state`='needsgrading',2,IF(`m`.`state`='gaveup',1,IF(`m`.`state` REGEXP '^mangr',3,IF(`m`.`state` REGEXP '^graded',4,0))))
WHERE `e`.`id`=`m`.`eid`;


# Get the maximum step sequence number+1 for the question attempt
# Required as the sequence value for the manual marking response
INSERT INTO `tmp_seq` (`eid`,`seq`)
SELECT `e`.`id`,max(`qas`.`sequencenumber`)+1
    FROM `mdl_question_attempt_steps` `qas`
	JOIN `mdl_elp_quiz_attempt_export` `e` ON `e`.`attemptid`=`qas`.`questionattemptid`
    GROUP BY `e`.`id`;

# Update mdl_elp_quiz_attempt_export with the maximum step sequence number+1 for the question attempt
# Required as the sequence value for the manual marking response step

UPDATE `mdl_elp_quiz_attempt_export` `e`,`tmp_seq` `s`
SET `e`.`seq`=`s`.`seq`
WHERE `e`.`id`=`s`.`eid`;

# Just report the number of rows in mdl_elp_quiz_attempt_export for information 
#SELECT COUNT(`id`) 'attempt items' FROM `mdl_elp_quiz_attempt_export`;

END;;
