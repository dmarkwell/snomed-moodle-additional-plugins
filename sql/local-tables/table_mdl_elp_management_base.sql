CREATE TABLE `mdl_elp_management_base` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userid` bigint(20) NOT NULL,
  `info_country` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `info_organization` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `info_role` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `info_expertise` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `info_interests` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `info_last_date` datetime DEFAULT NULL,
  `view_count` int(4) DEFAULT NULL,
  `view_first_date` datetime DEFAULT NULL,
  `view_last_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userid` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
