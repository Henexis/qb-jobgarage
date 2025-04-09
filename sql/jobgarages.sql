CREATE TABLE IF NOT EXISTS `job_vehicles` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) DEFAULT NULL,
    `job` varchar(50) DEFAULT NULL,
    `plate` varchar(15) DEFAULT NULL,
    `model` varchar(50) DEFAULT NULL,
    `fuel` int(11) DEFAULT 100,
    `body` float DEFAULT 1000.0,
    `engine` float DEFAULT 1000.0,
    `out` tinyint(1) DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
