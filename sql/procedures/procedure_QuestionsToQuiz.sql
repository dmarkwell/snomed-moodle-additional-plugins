DROP PROCEDURE IF EXISTS `QuestionsToQuiz`;;
CREATE PROCEDURE `QuestionsToQuiz`(IN `p_quizid` bigint(10), IN `p_quiz_categoryid` bigint(10), IN `p_added` bigint(10))
proc: BEGIN

DECLARE `v_questionid` bigint(10);
DECLARE `v_sub_category_id` bigint(10);
DECLARE `v_qcount` int(4);
DECLARE `v_category_path` varchar(255);
DECLARE `v_subcategory_name` varchar(255);
DECLARE `v_quiz_name` varchar(255);


DECLARE `done` BOOLEAN DEFAULT FALSE;
DECLARE `cur` CURSOR FOR SELECT `id` FROM `mdl_question_categories` WHERE `parent`=`p_quiz_categoryid` AND `name` regexp '[0-9]$' ORDER BY `name`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` := TRUE;

IF `p_added`>unix_timestamp()+10 OR`p_added`<unix_timestamp()-10 THEN
    INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'QuestionsToQuiz','Invalid timestamp parameter',`p_quizid`,`p_quiz_categoryid`,unix_timestamp());
	LEAVE proc;
	END IF;

SET `v_quiz_name` = (SELECT `name` FROM `mdl_quiz` WHERE `id`=`p_quizid`);

SET `v_qcount`=0;

SET `v_category_path`= (SELECT CONCAT(`p`.`name` ,'/',`c`.`name`) FROM `mdl_question_categories` `c` JOIN `mdl_question_categories` `p` ON `p`.`id`=`c`.`parent` WHERE `c`.`id`=`p_quiz_categoryid`);

OPEN `cur`;

  catLoop: LOOP
    FETCH `cur` INTO `v_sub_category_id`;
    IF done THEN
      LEAVE catLoop;
    END IF;

   SET `v_subcategory_name`=(SELECT `name` FROM `mdl_question_categories` WHERE `id`=`v_sub_category_id`);

    INSERT INTO `mdl_elp_log` (`added`,`task`,`info`,`value1`,`value2`,`value3`)
    VALUES (`p_added`,'QuestionsToQuiz',CONCAT('Added Question Category:',`v_subcategory_name`,' to quiz: ',`v_quiz_name`),`p_quizid`,`v_sub_category_id`,unix_timestamp());
	
   INSERT INTO `mdl_question` (`category`,`parent`,`name`,`questiontext`,`questiontextformat`,`generalfeedback`,`generalfeedbackformat`,`defaultmark`,`penalty`,`qtype`,`length`,`stamp`,`version`,`hidden`,`timecreated`,`timemodified`,`createdby`,`modifiedby`)
      VALUES (`v_sub_category_id`,0,CONCAT('Random (',`v_category_path`,'/',`v_subcategory_name`,')'),'',0,'',0,1,0,'random',1,MoodleStamp(),MoodleStamp(),0,unix_timestamp(),unix_timestamp(),3,3);

   SET `v_questionid`=LAST_INSERT_ID();

   UPDATE `mdl_question`
       SET `parent`=`v_questionid`
        WHERE `id`= `v_questionid`;
     
    SET `v_qcount`=`v_qcount`+1;

    INSERT INTO `mdl_quiz_slots` (`slot`,`quizid`,`page`,`requireprevious`,`questionid`,`maxmark`)
            VALUES(`v_qcount`,`p_quizid`,`v_qcount`,0,`v_questionid`,1.0000000);


  END LOOP catLoop;
  CLOSE cur;

  UPDATE `mdl_quiz`
    SET  `sumgrades`= `v_qcount`,
             `grade`=`v_qcount`
    WHERE `id`=`p_quizid`;

END proc;;
