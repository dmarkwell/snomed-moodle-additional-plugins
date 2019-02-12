DROP TABLE IF EXISTS mdl_elp_named_group_members;
CREATE VIEW `mdl_elp_named_group_members` AS (select `g`.`name` AS `name`,`g`.`courseid` AS `courseid`,`g`.`idnumber` AS `idnumber`,`m`.`userid` AS `userid`,`c`.`shortname` AS `course` from ((`mdl_groups` `g` join `mdl_groups_members` `m` on(`g`.`id` = `m`.`groupid`)) join `mdl_course` `c` on(`c`.`id` = `g`.`courseid`)));
