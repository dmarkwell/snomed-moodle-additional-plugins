CREATE TABLE `mdl_elp_metadata` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `filekey` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `fileref` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `metadata` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `timemodified` bigint(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mdl_elpmeta_filekey_uix` (`filekey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=COMPRESSED COMMENT='Presentation metadata source';
