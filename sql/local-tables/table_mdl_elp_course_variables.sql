CREATE TABLE `mdl_elp_course_variables` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `effective_time` bigint(10) NOT NULL COMMENT 'Time at which this course data replaced an earlier version',
  `courseid` bigint(10) NOT NULL COMMENT 'Course id as in mdl_course',
  `key` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Key used as group prefix',
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Short name of the course',
  `progress_report` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1 = include in progress reports',
  `final_assess` int(10) NOT NULL DEFAULT 1 COMMENT 'Number of final assessment parts',
  `mod_assess` int(10) NOT NULL DEFAULT 3 COMMENT 'Number of module assessments',
  `mark_assign` int(10) NOT NULL DEFAULT 0 COMMENT 'Number of marked assignments',
  `webinars` int(10) NOT NULL DEFAULT 0 COMMENT 'Number of webinars',
  `prestart` int(10) NOT NULL COMMENT 'If value is 1 allow start in month before formal start',
  `formal_duration` int(10) NOT NULL COMMENT 'Duration in months (set 1 month greater than stated duration)',
  `extended_duration` int(10) NOT NULL COMMENT 'Extended duration in months formal+standard extension period (for courses which have a fixed period optional extension)',
  `course_data` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Additional course data in a CSV or JSON format',
  `feedback_survey` bigint(10) NOT NULL COMMENT 'Id of the survey used to collect feedback.',
  `feedback_overall` bigint(10) NOT NULL COMMENT 'id of the survey question collecting overall rating of the course',
  `feedback_recommend` bigint(10) NOT NULL COMMENT 'Id of the survey question used for question on recommendation to others',
  `feedback_data` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Additional feedback reference data in a CSV or JSON format',
  `modified` bigint(10) NOT NULL COMMENT 'Date this record was modified',
  PRIMARY KEY (`id`),
  UNIQUE KEY `effective_time_courseid` (`effective_time`,`courseid`),
  KEY `key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Data about courses that is used in custom processes and progress reporting.';
