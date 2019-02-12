CREATE TABLE `mdl_elp_scorm_track` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `refid` bigint(10) NOT NULL,
  `userid` bigint(10) NOT NULL,
  `modified` bigint(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userid_refid` (`userid`,`refid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
