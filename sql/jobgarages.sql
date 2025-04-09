CREATE TABLE IF NOT EXISTS `job_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `job` varchar(50) DEFAULT NULL,
  `plate` varchar(15) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `fuel` float DEFAULT 100,
  `body` float DEFAULT 1000,
  `engine` float DEFAULT 1000,
  `properties` longtext DEFAULT NULL,
  `out` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `job` (`job`),
  KEY `plate` (`plate`),
  KEY `citizenid` (`citizenid`),
  KEY `out` (`out`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
