-- Table: users
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
);


-- Table: companies
CREATE TABLE `companies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `industry` enum('Technology','Education','Business') NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

-- Table: institutions
CREATE TABLE `institutions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `type` enum('Primary','Secondary','Higher Education') NOT NULL,
  `location` varchar(100) NOT NULL,
  `year_founded` year NOT NULL,
  PRIMARY KEY (`id`)
);

-- Table: user_company_affiliations
CREATE TABLE `user_company_affiliations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `company_id` int NOT NULL,
  `title` varchar(128) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ucf_user` (`user_id`),
  KEY `fk_ucf_company` (`company_id`),
  CONSTRAINT `fk_ucf_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ucf_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- Table: user_institution_affiliations
CREATE TABLE `user_institution_affiliations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `institution_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `degree` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ui_user` (`user_id`),
  KEY `fk_ui_institution` (`institution_id`),
  CONSTRAINT `fk_ui_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ui_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- Table: user_connections
CREATE TABLE `user_connections` (
  `user_id_a` int NOT NULL,
  `user_id_b` int NOT NULL,
  `connected_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id_a`,`user_id_b`),
  KEY `fk_uc_user_b` (`user_id_b`),
  CONSTRAINT `fk_uc_user_a` FOREIGN KEY (`user_id_a`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_uc_user_b` FOREIGN KEY (`user_id_b`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_user_order` CHECK ((`user_id_a` < `user_id_b`))
);
