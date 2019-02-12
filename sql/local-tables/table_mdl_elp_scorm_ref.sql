CREATE TABLE `mdl_elp_scorm_ref` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'The internal refid',
  `reference` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'The SCORM zip file referenced',
  PRIMARY KEY (`id`),
  UNIQUE KEY `reference` (`reference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=COMPRESSED COMMENT='Lookup for refid to the reference  for the presentation.';
