DROP PROCEDURE IF EXISTS `AddAttemptResult`;;
CREATE PROCEDURE `AddAttemptResult`(IN `attemptid` bigint(10), IN `seqnum` bigint(10), IN `maxmark` decimal(12,7), IN `mark` decimal(12,7))
begin
declare `v_step_id` bigint(10) default 0;
declare `v_marker_user_id` bigint(10) default 3;
declare `v_state` varchar(13);

set `v_state`=if(`mark`=`maxmark`,'mangrright',if(`mark`=0,'mangrwrong','mangrpartial'));

INSERT INTO `mdl_question_attempt_steps`
(`questionattemptid`,`sequencenumber`,`state`,`fraction`,`timecreated`,`userid`)
VALUES
(`attemptid`,`seqnum`,`v_state`,`mark`/`maxmark`, unix_timestamp(),`v_marker_user_id`);

set `v_step_id`=last_insert_id();

INSERT INTO `mdl_question_attempt_step_data`
(`attemptstepid`,`name`,`value`)
VALUES
(`v_step_id`,'-comment', ''),
(`v_step_id`,'-commentformat', '1'),
(`v_step_id`,'-mark', `mark`),
(`v_step_id`,'-maxmark', `maxmark`);

end;;
