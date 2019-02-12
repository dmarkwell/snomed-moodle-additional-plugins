CREATE TABLE `mdl_elp_management_course` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userid` double NOT NULL,
  `courseid` double NOT NULL,
  `intake_cohort` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_group` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_group` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `complete_date` datetime DEFAULT NULL,
  `feedback_rating` double DEFAULT NULL,
  `feedback_recommend` double DEFAULT NULL,
  `feedback_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userid_courseid` (`userid`,`courseid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
