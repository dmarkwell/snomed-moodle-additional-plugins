DROP TABLE IF EXISTS mdl_elp_named_cohort_members;
CREATE VIEW `mdl_elp_named_cohort_members` AS (select `c`.`name` AS `name`,0 + substr(`c`.`idnumber`,2) AS `courseid`,`c`.`idnumber` AS `idnumber`,`m`.`userid` AS `userid` from (`mdl_cohort` `c` join `mdl_cohort_members` `m` on(`c`.`id` = `m`.`cohortid`)));
