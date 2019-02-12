CREATE TABLE `mdl_elp_log` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `added` bigint(10) NOT NULL,
  `task` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `info` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `value1` bigint(10) DEFAULT NULL,
  `value2` bigint(10) DEFAULT NULL,
  `value3` bigint(10) DEFAULT NULL,
  `value4` bigint(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=COMPRESSED;
