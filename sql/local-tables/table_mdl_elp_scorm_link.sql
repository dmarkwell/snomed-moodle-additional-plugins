CREATE TABLE `mdl_elp_scorm_link` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `refid` bigint(10) NOT NULL COMMENT 'The refid to used by plugin. The refid links to all the scormid, sooid and moduleid values that use this package.',
  `scormid` bigint(10) NOT NULL COMMENT 'ID of a linked mdl_scorm ro',
  `scoid` bigint(10) NOT NULL COMMENT 'The SCOID for the mdl_scorm row.',
  `moduleid` bigint(10) NOT NULL COMMENT 'ID of the mdl_course_modules row for the linked scorm package.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `scormid` (`scormid`),
  UNIQUE KEY `moduleid` (`moduleid`),
  UNIQUE KEY `scoid` (`scoid`),
  KEY `refid` (`refid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='A reference to all activities that use the same SCORM package.';
