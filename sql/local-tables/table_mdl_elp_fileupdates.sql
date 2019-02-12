CREATE TABLE `mdl_elp_fileupdates` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `filekey` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fileref` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created` bigint(10) NOT NULL,
  `modified` bigint(10) NOT NULL,
  `filesize` bigint(10) NOT NULL,
  `logtime` bigint(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `filekey_type_modified` (`filekey`,`type`,`modified`),
  KEY `filekey` (`filekey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
